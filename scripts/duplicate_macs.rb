# Run docker command and capture output
cmd = "docker ps -q | xargs -n 1 docker inspect --format '{{range .NetworkSettings.Networks}}{{.MacAddress}}{{end}}   {{.Name}}' | sort"
output = `#{cmd}`

# Parse output into hash of mac addresses -> container names
mac_map = {}
output.each_line do |line|
  mac, name = line.strip.split(/\s+/, 2)
  next if mac.empty? # Skip empty MAC addresses
  mac_map[mac] ||= []
  mac_map[mac] << name
end

# Print results, highlighting duplicates in red
mac_map.each do |mac, names|
  if names.length > 1
    # Red text for duplicates
    puts "\e[31m#{mac}   #{names.join("\n#{' ' * mac.length}   ")}\e[0m"
  else
    # Normal text for unique MACs
    puts "#{mac}   #{names.first}"
  end
end
