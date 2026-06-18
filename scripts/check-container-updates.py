#!/usr/bin/env python3
"""
check-container-updates.py

Inspect running containers, compare each container's deployed image against the
current version in its registry, and report which ones need updating along with
how far behind the running image is.

How it works
------------
For every running container it:
  1. reads the deployed image reference and the local image's digest + build date
     (via `docker image inspect`), and
  2. asks the registry for the digest + build date of the comparison tag
     (via `skopeo inspect`, which does NOT download the image).

If the local image's content digest is not among the digests the registry
currently serves for that tag, an update is available. When it is, the script
prints the build date of each image and the gap between them.

Comparison tag
--------------
By default each container is compared against the *same tag it is running*
(e.g. a container on `nginx:1.25` is checked against `nginx:1.25` in the
registry) -- this answers "has the tag I'm running been rebuilt since I pulled
it?". Use --latest to instead compare against the `:latest` tag of the same
repository ("am I behind latest?").

Requirements: docker (or podman) and skopeo on PATH.

Exit status: 0 if nothing needs updating, 1 if at least one update is available,
2 on a usage/tooling error. Use --exit-zero to always exit 0.
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone


# --------------------------------------------------------------------------- #
# Shell helpers
# --------------------------------------------------------------------------- #

def run(cmd: list[str], timeout: int = 60) -> str:
    """Run a command, return stdout. Raise RuntimeError with stderr on failure."""
    try:
        proc = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
    except FileNotFoundError as exc:
        raise RuntimeError(f"command not found: {cmd[0]}") from exc
    except subprocess.TimeoutExpired as exc:
        raise RuntimeError(f"timed out after {timeout}s: {' '.join(cmd)}") from exc
    if proc.returncode != 0:
        raise RuntimeError((proc.stderr or proc.stdout).strip())
    return proc.stdout


# --------------------------------------------------------------------------- #
# Image-reference parsing
# --------------------------------------------------------------------------- #

def split_ref(ref: str) -> tuple[str, str | None, str | None]:
    """Split an image reference into (name, tag, digest).

    Handles registry host:port, repository path, optional :tag and @digest.
    Examples:
      nginx:1.25                  -> ('nginx', '1.25', None)
      ghcr.io/foo/bar             -> ('ghcr.io/foo/bar', None, None)
      reg:5000/app:v2@sha256:ab.. -> ('reg:5000/app', 'v2', 'sha256:ab..')
    """
    name_part, _, digest = ref.rpartition("@")
    if not name_part:  # no '@' present; rpartition put everything in `digest`
        name_part, digest = digest, None

    last_slash = name_part.rfind("/")
    last_colon = name_part.rfind(":")
    # A colon is a tag separator only if it comes after the final slash
    # (otherwise it's a registry port, e.g. localhost:5000/app).
    if last_colon > last_slash:
        name = name_part[:last_colon]
        tag = name_part[last_colon + 1:]
    else:
        name = name_part
        tag = None
    return name, tag, digest


def comparison_ref(running_ref: str, use_latest: bool) -> str:
    """Build the registry reference to compare against."""
    name, tag, _digest = split_ref(running_ref)
    if use_latest:
        return f"{name}:latest"
    return f"{name}:{tag or 'latest'}"


# --------------------------------------------------------------------------- #
# Timestamps & durations
# --------------------------------------------------------------------------- #

_TS_RE = re.compile(
    r"(\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2})(\.\d+)?(Z|[+-]\d{2}:?\d{2})?"
)


def parse_ts(value: str | None) -> datetime | None:
    """Parse an RFC3339/ISO8601 timestamp (with optional nanoseconds) to UTC."""
    if not value:
        return None
    m = _TS_RE.search(value)
    if not m:
        return None
    base, frac, tz = m.groups()
    base = base.replace(" ", "T")
    # datetime only supports microseconds; truncate any extra fractional digits.
    micro = ""
    if frac:
        micro = "." + frac[1:7].ljust(6, "0")
    if tz in (None, "Z"):
        offset = "+00:00"
    else:
        offset = tz if ":" in tz else f"{tz[:3]}:{tz[3:]}"
    try:
        dt = datetime.fromisoformat(f"{base}{micro}{offset}")
    except ValueError:
        return None
    return dt.astimezone(timezone.utc)


def human_duration(seconds: float) -> str:
    """Render a duration as an approximate human string (e.g. '5 months')."""
    seconds = abs(int(seconds))
    units = (
        ("year", 365 * 24 * 3600),
        ("month", 30 * 24 * 3600),
        ("day", 24 * 3600),
        ("hour", 3600),
        ("minute", 60),
    )
    for name, size in units:
        if seconds >= size:
            n = seconds // size
            return f"{n} {name}{'s' if n != 1 else ''}"
    return "less than a minute"


def ago(dt: datetime | None, now: datetime) -> str:
    if dt is None:
        return "unknown"
    delta = (now - dt).total_seconds()
    suffix = "ago" if delta >= 0 else "from now"
    return f"{dt.date()} ({human_duration(delta)} {suffix})"


# --------------------------------------------------------------------------- #
# Data gathering
# --------------------------------------------------------------------------- #

@dataclass
class Container:
    cid: str
    name: str
    image_ref: str
    image_id: str = ""
    local_created: datetime | None = None
    started_at: datetime | None = None
    local_digests: set[str] = field(default_factory=set)
    os: str = ""
    arch: str = ""
    variant: str = ""

    # Filled in during the remote comparison phase:
    compare_ref: str = ""
    remote_digest: str | None = None
    remote_created: datetime | None = None
    status: str = ""          # one of: update, current, unknown, local
    detail: str = ""          # human-readable note for unknown/local


def list_running(engine: str) -> list[Container]:
    out = run([engine, "ps", "--format", "{{.ID}}\t{{.Names}}\t{{.Image}}"])
    containers: list[Container] = []
    for line in out.splitlines():
        if not line.strip():
            continue
        cid, name, image = (line.split("\t") + ["", "", ""])[:3]
        containers.append(Container(cid=cid, name=name, image_ref=image))
    return containers


def load_local_metadata(engine: str, c: Container) -> None:
    """Populate the container with local image + runtime metadata."""
    # Container runtime info (the image it actually runs + when it started).
    try:
        cinfo = json.loads(run([engine, "container", "inspect", c.cid]))[0]
        c.image_id = cinfo.get("Image", "")
        c.started_at = parse_ts(cinfo.get("State", {}).get("StartedAt"))
    except (RuntimeError, json.JSONDecodeError, IndexError):
        pass

    target = c.image_id or c.image_ref
    try:
        iinfo = json.loads(run([engine, "image", "inspect", target]))[0]
    except (RuntimeError, json.JSONDecodeError, IndexError):
        return
    c.local_created = parse_ts(iinfo.get("Created"))
    c.os = iinfo.get("Os", "") or ""
    c.arch = iinfo.get("Architecture", "") or ""
    c.variant = iinfo.get("Variant", "") or ""
    for rd in iinfo.get("RepoDigests") or []:
        _name, _tag, digest = split_ref(rd)
        if digest:
            c.local_digests.add(digest)


def skopeo_inspect(
    ref: str, os_: str, arch: str, variant: str, authfile: str | None
) -> tuple[dict | None, str]:
    """Inspect a remote image, pinning the platform to match the local image.

    macOS hosts make skopeo default to an `os=darwin` instance that does not
    exist in (linux-only) manifest lists, so we always pin os/arch. A short
    retry ladder copes with variant mismatches and odd manifest layouts.
    """
    base = ["skopeo", "inspect", "--no-tags"]
    if authfile:
        base += ["--authfile", authfile]

    attempts: list[list[str]] = []
    if os_ and arch and variant:
        attempts.append(["--override-os", os_, "--override-arch", arch,
                         "--override-variant", variant])
    if os_ and arch:
        attempts.append(["--override-os", os_, "--override-arch", arch])
    attempts.append(["--override-os", "linux", "--override-arch", "amd64"])
    attempts.append([])  # last resort: let skopeo decide

    last_err = "no inspect attempt succeeded"
    for extra in attempts:
        try:
            return json.loads(run(base + extra + [f"docker://{ref}"], timeout=45)), ""
        except RuntimeError as exc:
            last_err = _short(str(exc))
        except json.JSONDecodeError:
            last_err = "could not parse skopeo output"
    return None, last_err


def load_remote_metadata(c: Container, use_latest: bool, authfile: str | None) -> None:
    """Query the registry for the comparison tag and decide if an update is due.

    The update decision is based on image *build dates*: if the registry's image
    for the comparison tag was built more recently than the running image, an
    update is available. This is robust across single- and multi-arch images,
    where manifest-list vs per-platform digests cannot be compared directly.
    """
    c.compare_ref = comparison_ref(c.image_ref, use_latest)
    name, _tag, _digest = split_ref(c.image_ref)

    if name in ("<none>", "") or c.image_ref.endswith("<none>:<none>"):
        c.status, c.detail = "local", "no image reference"
        return
    if not c.local_digests:
        # No RepoDigest -> image was built locally and never pushed/pulled.
        c.status, c.detail = "local", "locally-built image (no registry digest)"
        return

    info, err = skopeo_inspect(c.compare_ref, c.os, c.arch, c.variant, authfile)
    if info is None:
        c.status, c.detail = "unknown", err
        return

    c.remote_digest = info.get("Digest")
    c.remote_created = parse_ts(info.get("Created"))

    if c.local_created and c.remote_created:
        # 1s tolerance avoids flapping on sub-second timestamp rounding.
        if c.remote_created > c.local_created + timedelta(seconds=1):
            c.status = "update"
        else:
            c.status = "current"
    else:
        c.status, c.detail = "unknown", "could not determine image build dates"


def _short(msg: str, limit: int = 120) -> str:
    msg = " ".join(msg.split())
    return msg if len(msg) <= limit else msg[: limit - 1] + "…"


# --------------------------------------------------------------------------- #
# Output
# --------------------------------------------------------------------------- #

class C:
    """ANSI colors, disabled when not a tty or --no-color."""
    enabled = True

    @classmethod
    def wrap(cls, code: str, text: str) -> str:
        return f"\033[{code}m{text}\033[0m" if cls.enabled else text


def bold(t): return C.wrap("1", t)
def red(t): return C.wrap("31", t)
def green(t): return C.wrap("32", t)
def yellow(t): return C.wrap("33", t)
def dim(t): return C.wrap("2", t)


def report(containers: list[Container], use_latest: bool, now: datetime) -> int:
    updates = [c for c in containers if c.status == "update"]
    current = [c for c in containers if c.status == "current"]
    skipped = [c for c in containers if c.status in ("unknown", "local")]

    target_word = "latest" if use_latest else "the running tag"
    print(bold(f"\nContainer image update check  ·  comparing against {target_word}"))
    print(dim(f"{len(containers)} running · "
              f"{len(updates)} need update · {len(current)} up to date · "
              f"{len(skipped)} skipped\n"))

    if updates:
        print(bold(red("UPDATES AVAILABLE")))
        for c in sorted(updates, key=lambda x: x.name):
            print(f"\n  {bold(c.name)}  {dim('(' + c.image_ref + ')')}")
            print(f"    compared to : {c.compare_ref}")
            print(f"    running     : built {ago(c.local_created, now)}")
            print(f"    registry    : built {ago(c.remote_created, now)}")
            print(f"    {yellow(_gap_text(c, now))}")
            print(dim(f"    digests     : running {_digest_short(c.local_digests)}"
                      f"  ·  registry {_digest_short({c.remote_digest} if c.remote_digest else set())}"))
            if c.started_at:
                print(dim(f"    container running for {human_duration((now - c.started_at).total_seconds())}"))

    if current:
        print(bold(green("\nUP TO DATE")))
        for c in sorted(current, key=lambda x: x.name):
            built = ago(c.local_created, now)
            print(f"  {green('✓')} {c.name}  {dim('(' + c.image_ref + ')')}  built {built}")

    if skipped:
        print(bold(dim("\nSKIPPED")))
        for c in sorted(skipped, key=lambda x: x.name):
            print(dim(f"  - {c.name}  ({c.image_ref}): {c.detail}"))

    print()
    return 1 if updates else 0


def _digest_short(digests: set[str]) -> str:
    if not digests:
        return dim("(none)")
    d = sorted(digests)[0]
    short = d.split(":", 1)[-1][:12] if ":" in d else d[:12]
    extra = f" +{len(digests) - 1} more" if len(digests) > 1 else ""
    return f"sha256:{short}{extra}"


def _gap_text(c: Container, now: datetime) -> str:
    if c.local_created and c.remote_created:
        delta = (c.remote_created - c.local_created).total_seconds()
        if delta > 0:
            return f"→ running image is {human_duration(delta)} behind the registry image"
        if delta < 0:
            return f"→ running image is {human_duration(delta)} NEWER than the registry tag (rolled back?)"
        return "→ images built at the same time but digests differ (rebuild/different platform)"
    return "→ update available (build dates unavailable)"


# --------------------------------------------------------------------------- #
# Main
# --------------------------------------------------------------------------- #

def detect_engine(preferred: str) -> str:
    if preferred != "auto":
        if not shutil.which(preferred):
            raise RuntimeError(f"container engine '{preferred}' not found on PATH")
        return preferred
    for candidate in ("docker", "podman"):
        if shutil.which(candidate):
            return candidate
    raise RuntimeError("no container engine found (looked for docker, podman)")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        description="Check running containers for available image updates.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--latest", action="store_true",
                        help="compare against the ':latest' tag instead of the running tag")
    parser.add_argument("--engine", default="auto",
                        help="container engine: auto (default), docker, or podman")
    parser.add_argument("--authfile", default=None,
                        help="auth file passed to skopeo for private registries")
    parser.add_argument("--filter", default=None,
                        help="only check containers whose name or image contains this substring")
    parser.add_argument("--workers", type=int, default=8,
                        help="parallel registry lookups (default: 8)")
    parser.add_argument("--no-color", action="store_true", help="disable colored output")
    parser.add_argument("--exit-zero", action="store_true",
                        help="always exit 0, even when updates are available")
    args = parser.parse_args(argv)

    C.enabled = sys.stdout.isatty() and not args.no_color

    if not shutil.which("skopeo"):
        print(red("error: skopeo is required but was not found on PATH.\n"
                  "Install it (e.g. `brew install skopeo`) and try again."),
              file=sys.stderr)
        return 2

    try:
        engine = detect_engine(args.engine)
    except RuntimeError as exc:
        print(red(f"error: {exc}"), file=sys.stderr)
        return 2

    try:
        containers = list_running(engine)
    except RuntimeError as exc:
        print(red(f"error: could not list containers: {exc}"), file=sys.stderr)
        return 2

    if args.filter:
        containers = [c for c in containers
                      if args.filter in c.name or args.filter in c.image_ref]

    if not containers:
        print(dim("No running containers to check."))
        return 0

    # Phase 1: local metadata (cheap, but parallelize anyway for many containers).
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        list(pool.map(lambda c: load_local_metadata(engine, c), containers))

    # Phase 2: remote registry lookups (the slow part).
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        list(pool.map(
            lambda c: load_remote_metadata(c, args.latest, args.authfile),
            containers,
        ))

    now = datetime.now(timezone.utc)
    exit_code = report(containers, args.latest, now)
    return 0 if args.exit_zero else exit_code


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1:]))
    except KeyboardInterrupt:
        sys.exit(130)
