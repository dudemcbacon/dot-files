#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'

# Status constants for reporting
module Status
  ALREADY_RUNNING = 'ALREADY_RUNNING'
  STARTED = 'STARTED'
  FAILED = 'FAILED'
  UNKNOWN = 'UNKNOWN'
end

# Represents a Docker Compose project parsed from `docker compose ls` output
class ComposeProject
  attr_reader :name, :status, :config_files

  def initialize(name:, status:, config_files:)
    @name = name
    @status = status
    @config_files = config_files
  end

  def running?
    @status.downcase.start_with?('running')
  end
end

# Parses the output of `docker compose ls`
class ComposeListParser
  def self.parse(content)
    lines = content.lines.map(&:strip).reject(&:empty?)
    return [] if lines.empty?

    # Find header line and determine column positions
    header_line = lines.first
    return [] unless header_line.match?(/NAME\s+STATUS/i)

    # Find column boundaries based on header
    name_start = header_line.index(/NAME/i) || 0
    status_start = header_line.index(/STATUS/i)
    config_start = header_line.index(/CONFIG\s*FILES?/i)

    return [] unless status_start

    # Parse data lines
    lines[1..].filter_map do |line|
      next if line.strip.empty?

      parse_line(line, name_start, status_start, config_start)
    end
  end

  def self.parse_line(line, name_start, status_start, config_start)
    # Handle lines that might be shorter than expected
    return nil if line.length < status_start

    name = line[name_start...status_start].strip

    status = if config_start && line.length > config_start
               line[status_start...config_start].strip
             else
               line[status_start..].strip
             end

    config_files = config_start && line.length > config_start ? line[config_start..].strip : ''

    return nil if name.empty?

    ComposeProject.new(name: name, status: status, config_files: config_files)
  end
end

# Manages Docker Compose projects - checking status and starting stopped projects
class ComposeManager
  def initialize(dry_run: false)
    @dry_run = dry_run
  end

  def start_project(project)
    return simulate_start(project) if @dry_run

    # Use the config file if available, otherwise use project name
    cmd = if project.config_files && !project.config_files.empty?
            config_file = project.config_files.split(',').first.strip
            ['docker', 'compose', '-f', config_file, 'up', '-d']
          else
            ['docker', 'compose', '-p', project.name, 'up', '-d']
          end

    stdout, stderr, status = Open3.capture3(*cmd)

    if status.success?
      { success: true, output: stdout }
    else
      { success: false, output: stderr }
    end
  end

  private

  def simulate_start(project)
    puts "  [DRY RUN] Would execute: docker compose -p #{project.name} up -d"
    { success: true, output: 'Dry run - no action taken' }
  end
end

# Generates formatted output report
class ReportGenerator
  COLUMN_WIDTHS = { name: 30, original: 20, result: 20 }.freeze

  def self.generate(results)
    output = []
    output << header
    output << separator
    results.each { |r| output << format_row(r) }
    output << separator
    output << summary(results)
    output.join("\n")
  end

  def self.header
    format("%-#{COLUMN_WIDTHS[:name]}s %-#{COLUMN_WIDTHS[:original]}s %-#{COLUMN_WIDTHS[:result]}s",
           'PROJECT', 'ORIGINAL STATUS', 'RESULT')
  end

  def self.separator
    '-' * (COLUMN_WIDTHS.values.sum + 2)
  end

  def self.format_row(result)
    format("%-#{COLUMN_WIDTHS[:name]}s %-#{COLUMN_WIDTHS[:original]}s %-#{COLUMN_WIDTHS[:result]}s",
           truncate(result[:name], COLUMN_WIDTHS[:name]),
           truncate(result[:original_status], COLUMN_WIDTHS[:original]),
           result[:result])
  end

  def self.truncate(str, max_length)
    str.length > max_length ? "#{str[0...max_length - 3]}..." : str
  end

  def self.summary(results)
    counts = results.group_by { |r| r[:result] }.transform_values(&:count)
    summary_parts = counts.map { |status, count| "#{status}: #{count}" }
    "\nSummary: #{summary_parts.join(', ')}"
  end
end

# Main application logic
class Application
  def initialize(args)
    @args = args
    @dry_run = args.include?('--dry-run')
    @input_file = args.reject { |a| a.start_with?('--') }.first
  end

  def run
    validate_args!
    content = read_input
    projects = ComposeListParser.parse(content)

    if projects.empty?
      puts 'No compose projects found in input.'
      exit 0
    end

    results = process_projects(projects)
    puts ReportGenerator.generate(results)
  end

  private

  def validate_args!
    return if @input_file

    puts 'Usage: compose_manager.rb <input_file> [--dry-run]'
    puts ''
    puts 'Arguments:'
    puts '  input_file    File containing output of `docker compose ls`'
    puts '  --dry-run     Show what would be done without actually starting projects'
    exit 1
  end

  def read_input
    unless File.exist?(@input_file)
      puts "Error: File not found: #{@input_file}"
      exit 1
    end

    File.read(@input_file)
  end

  def process_projects(projects)
    manager = ComposeManager.new(dry_run: @dry_run)

    projects.map do |project|
      process_single_project(project, manager)
    end
  end

  def process_single_project(project, manager)
    result = {
      name: project.name,
      original_status: project.status
    }

    if project.running?
      result[:result] = Status::ALREADY_RUNNING
    else
      puts "Starting project: #{project.name}..."
      start_result = manager.start_project(project)
      result[:result] = start_result[:success] ? Status::STARTED : Status::FAILED
      result[:error] = start_result[:output] unless start_result[:success]
    end

    result
  end
end

# Entry point
if __FILE__ == $PROGRAM_NAME
  Application.new(ARGV).run
end
