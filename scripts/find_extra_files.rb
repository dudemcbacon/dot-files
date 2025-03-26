require 'optparse'

def extract_year(text)
  # Match years between 1900-2099
  match = text.match(/\b(19|20)\d{2}\b/)
  match ? match[0] : nil
end

def check_files_in_directory(dir_path, dir_name, allowed_extensions, full_path, ignore_years)
  files = Dir.entries(dir_path).select do |file| 
    file_path = File.join(dir_path, file)
    next false unless File.file?(file_path)

    if file.end_with?(*allowed_extensions)
      # Get base filename without extension
      extension = if file.end_with?('.en.srt')
                   '.en.srt'
                 elsif file.end_with?('.en.hi.srt')
                   '.en.hi.srt'
                 else
                   File.extname(file)
                 end
      base_name = File.basename(file, extension)
      
      # Show files that don't match the directory name
      # Normalize both strings by removing hyphens and extra spaces
      normalized_dir = dir_name.gsub(/[-\s]+/, ' ').strip
      normalized_file = base_name.gsub(/[-\s]+/, ' ').strip

      if ignore_years
        # Extract years from both strings
        dir_year = extract_year(normalized_dir)
        file_year = extract_year(normalized_file)
        
        # If both have years and they're different, remove them for comparison
        if dir_year && file_year
          normalized_dir = normalized_dir.gsub(dir_year, '').strip
          normalized_file = normalized_file.gsub(file_year, '').strip
        end
      end

      normalized_file != normalized_dir
    else
      # Show all other files
      true
    end
  end
  
  unless files.empty?
    puts "\nDirectory: #{dir_path}"
    files.each do |file|
      file_to_show = full_path ? File.join(dir_path, file) : file
      puts "  \e[31m#{file_to_show}\e[0m"
    end
  end
end

def count_extensions(dir_path)
  extension_counts = Hash.new(0)
  
  Dir.entries(dir_path).each do |file|
    file_path = File.join(dir_path, file)
    next unless File.file?(file_path)
    
    extension = if file.end_with?('.en.srt')
                 '.en.srt'
               elsif file.end_with?('.en.hi.srt')
                 '.en.hi.srt'
               else
                 File.extname(file)
               end
    
    extension_counts[extension] += 1 unless extension.empty?
  end
  
  extension_counts
end

def display_extension_table(extension_counts)
  puts "\nFile Extension Counts:"
  puts "====================="
  puts "Extension | Count"
  puts "----------|-------"
  extension_counts.each do |ext, count|
    printf "%-9s | %d\n", ext, count
  end
  puts "====================="
end

def check_directory_files(base_dir, num_dirs = nil, single_dir = false, allowed_extensions, full_path, ignore_years, show_extensions)
  if single_dir
    if show_extensions
      extension_counts = count_extensions(base_dir)
      display_extension_table(extension_counts)
    end
    check_files_in_directory(base_dir, File.basename(base_dir), allowed_extensions, full_path, ignore_years)
    return
  end

  entries = Dir.entries(base_dir).select do |entry|
    path = File.join(base_dir, entry)
    File.directory?(path) && !['.', '..'].include?(entry)
  end

  entries = entries.take(num_dirs) if num_dirs

  if show_extensions
    total_extension_counts = Hash.new(0)
    entries.each do |entry|
      path = File.join(base_dir, entry)
      count_extensions(path).each do |ext, count|
        total_extension_counts[ext] += count
      end
    end
    display_extension_table(total_extension_counts)
  end

  entries.each do |entry|
    path = File.join(base_dir, entry)
    check_files_in_directory(path, entry, allowed_extensions, full_path, ignore_years)
  end
end

# Parse command line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options] [directory]"
  opts.on("-n", "--num-dirs NUMBER", Integer, "Number of directories to check") do |n|
    options[:num_dirs] = n
  end
  opts.on("-s", "--single", "Check only the specified directory (no subdirectories)") do
    options[:single_dir] = true
  end
  opts.on("-e", "--extensions EXTENSIONS", "Comma-separated list of additional extensions to ignore") do |exts|
    options[:additional_extensions] = exts.split(',').map { |ext| ext.strip }
  end
  opts.on("-f", "--full-path", "Display full path for extra files") do
    options[:full_path] = true
  end
  opts.on("-y", "--ignore-years", "Ignore year mismatches between directory and file names") do
    options[:ignore_years] = true
  end
  opts.on("-c", "--count-extensions", "Display a table of file extensions and their counts") do
    options[:show_extensions] = true
  end
end.parse!

# Get directory from command line or use current directory
dir = ARGV[0] || Dir.pwd

# Combine default extensions with any additional ones
allowed_extensions = ['.mkv', '.en.srt', '.en.hi.srt']
allowed_extensions += options[:additional_extensions] if options[:additional_extensions]

check_directory_files(dir, options[:num_dirs], options[:single_dir], allowed_extensions, options[:full_path], options[:ignore_years], options[:show_extensions])