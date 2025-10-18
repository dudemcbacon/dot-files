-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  -- import/override with your plugins folder
  { import = "astrocommunity.colorscheme.rose-pine" },
  { import = "astrocommunity.colorscheme.solarized-osaka-nvim" },
  { import = "astrocommunity.completion.avante-nvim" },
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  { import = "astrocommunity.motion.nvim-surround" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.java" },
  { import = "astrocommunity.pack.kotlin" },
  { import = "astrocommunity.pack.ruby" },
  { import = "astrocommunity.pack.terraform" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.recipes.vscode" },
  { import = "astrocommunity.test.neotest" },
}
