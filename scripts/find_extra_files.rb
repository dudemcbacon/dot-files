require 'optparse'

def check_files_in_directory(dir_path, dir_name, allowed_extensions)
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
      normalized_file != normalized_dir
    else
      # Show all other files
      true
    end
  end
  
  unless files.empty?
    puts "\nDirectory: #{dir_path}"
    files.each do |file|
      puts "  \e[31m#{file}\e[0m"
    end
  end
end

def check_directory_files(base_dir, num_dirs = nil, single_dir = false, allowed_extensions)
  if single_dir
    check_files_in_directory(base_dir, File.basename(base_dir), allowed_extensions)
    return
  end

  entries = Dir.entries(base_dir).select do |entry|
    path = File.join(base_dir, entry)
    File.directory?(path) && !['.', '..'].include?(entry)
  end

  entries = entries.take(num_dirs) if num_dirs

  entries.each do |entry|
    path = File.join(base_dir, entry)
    check_files_in_directory(path, entry, allowed_extensions)
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
end.parse!

# Get directory from command line or use current directory
dir = ARGV[0] || Dir.pwd

# Combine default extensions with any additional ones
allowed_extensions = ['.mkv', '.en.srt', '.en.hi.srt']
allowed_extensions += options[:additional_extensions] if options[:additional_extensions]

check_directory_files(dir, options[:num_dirs], options[:single_dir], allowed_extensions)