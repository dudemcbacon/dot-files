#!/usr/bin/env ruby

require 'find'
require 'etc'

def count_file_ownership(directory)
  ownership_counts = Hash.new(0)
  
  begin
    Find.find(directory) do |path|
      next unless File.file?(path)  # Only process files, not directories
      
      begin
        stat = File.stat(path)
        uid = stat.uid
        gid = stat.gid
        
        # Get user and group names
        user = Etc.getpwuid(uid).name rescue "#{uid}"
        group = Etc.getgrgid(gid).name rescue "#{gid}"
        
        ownership_key = "#{user}:#{group}"
        ownership_counts[ownership_key] += 1
        
      rescue => e
        # Skip files we can't stat (permission issues, etc.)
        puts "Warning: Could not stat #{path}: #{e.message}" if $VERBOSE
      end
    end
  rescue => e
    puts "Error: Could not access directory #{directory}: #{e.message}"
    exit 1
  end
  
  ownership_counts
end

def display_results(ownership_counts)
  if ownership_counts.empty?
    puts "No files found or no accessible files in the directory."
    return
  end
  
  puts "File ownership counts:"
  puts "=" * 50
  
  # Sort by count (descending) then by ownership string
  sorted_counts = ownership_counts.sort_by { |ownership, count| [-count, ownership] }
  
  sorted_counts.each do |ownership, count|
    puts "#{ownership.ljust(30)} #{count.to_s.rjust(8)} files"
  end
  
  total_files = ownership_counts.values.sum
  puts "=" * 50
  puts "Total files: #{total_files}"
end

def show_usage
  puts "Usage: #{$0} <directory>"
  puts "Recursively counts files by owner:group association in the specified directory."
  puts ""
  puts "Options:"
  puts "  -v, --verbose    Show warnings for files that cannot be accessed"
  puts "  -h, --help       Show this help message"
end

# Main execution
if ARGV.empty? || ARGV.include?('-h') || ARGV.include?('--help')
  show_usage
  exit 0
end

# Handle verbose flag
if ARGV.include?('-v') || ARGV.include?('--verbose')
  $VERBOSE = true
  ARGV.delete('-v')
  ARGV.delete('--verbose')
end

if ARGV.length != 1
  puts "Error: Please provide exactly one directory path."
  show_usage
  exit 1
end

directory = ARGV[0]

unless File.directory?(directory)
  puts "Error: '#{directory}' is not a valid directory."
  exit 1
end

puts "Scanning directory: #{File.expand_path(directory)}"
puts ""

ownership_counts = count_file_ownership(directory)
display_results(ownership_counts)