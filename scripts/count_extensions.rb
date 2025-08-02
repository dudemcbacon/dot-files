#!/usr/bin/env ruby

require 'find'

# Initialize a hash to store extension counts
extension_counts = Hash.new(0)

# Find all files recursively
Find.find('.') do |path|
  next if File.directory?(path)
  next if path.start_with?('./.git') # Skip git directory
  
  # Get the extension (including the dot)
  extension = File.extname(path)
  # If no extension, use 'no extension'
  extension = 'no extension' if extension.empty?
  
  extension_counts[extension] += 1
end

# Sort extensions by count (descending)
sorted_extensions = extension_counts.sort_by { |_, count| -count }

# Print header
puts "\nFile Extension Counts"
puts "===================="
puts "Extension    Count"
puts "----------------"

# Print each extension and count
sorted_extensions.each do |ext, count|
  printf "%-12s %d\n", ext, count
end

puts "----------------" 