require 'yaml'
require 'terminal-table'

# 1. Get the list of projects and their config files
# Format: "project_name|config_file_path"
format_str = '{{ index .Config.Labels "com.docker.compose.project" }}|{{ index .Config.Labels "com.docker.compose.project.config_files" }}'
cmd = "docker inspect $(docker ps -aq) --format '#{format_str}' 2>/dev/null"

# Create a unique mapping of Project -> Config Path
project_configs = `#{cmd}`.split("\n")
                          .reject { |line| line.strip.empty? || line.include?("<no value>") }
                          .map { |line| line.split('|') }
                          .uniq

if project_configs.empty?
  puts "No Docker Compose projects found."
  exit
end

rows = []

# 2. Process each project using `docker compose config`
project_configs.each do |project_name, file_path|
  next unless File.exist?(file_path)

  begin
    # Use docker compose config to get a normalized, resolved YAML
    # We specify the file explicitly to ensure we are looking at the right project
    resolved_yaml = `docker compose -f "#{file_path}" config 2>/dev/null`
    next if resolved_yaml.empty?

    config = YAML.safe_load(resolved_yaml)
    services = config['services'] || {}

    services.each do |service_name, details|
      # Resolve Networks (Normalized to Hash by 'config' command)
      networks = details['networks'] ? details['networks'].keys.join("\n") : 'default'

      # Filter Labels for "swag"
      # 'docker compose config' normalizes labels to a Hash
      raw_labels = details['labels'] || {}
      swag_labels = raw_labels.select { |k, _v| k.include?('swag') }
                              .map { |k, v| "#{k}: #{v}" }
                              .join("\n")

      rows << [
        project_name,
        service_name,
        details['container_name'] || '-',
        details['restart'] || 'no',
        networks,
        swag_labels.empty? ? "-" : swag_labels
      ]
    end
  rescue => e
    puts "Error processing project #{project_name}: #{e.message}"
  end
end

# 3. Sort by Project Name (Column 0)
rows.sort_by! { |row| row[0].to_s.downcase }

# 4. Generate Table
table = Terminal::Table.new do |t|
  t.headings = ['Project', 'Service', 'Container Name', 'Restart', 'Networks', 'Swag Labels']
  t.rows = rows
  t.style = { all_separators: true }
end

puts table
