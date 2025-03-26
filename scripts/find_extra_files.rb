require 'optparse'

def check_directory_files(base_dir, num_dirs = nil)
  entries = Dir.entries(base_dir).select do |entry|
    path = File.join(base_dir, entry)
    File.directory?(path) && !['.', '..'].include?(entry)
  end

  entries = entries.take(num_dirs) if num_dirs

  entries.each do |entry|
    path = File.join(base_dir, entry)
    files = Dir.entries(path).select do |file| 
      file_path = File.join(path, file)
      return false unless File.file?(file_path)

      allowed_extensions = ['.mkv', '.en.srt']
      if file.end_with?(*allowed_extensions)
        # Get base filename without extension
        extension = file.end_with?('.en.srt') ? '.en.srt' : File.extname(file)
        base_name = File.basename(file, extension)
        
        # Compare normalized names (without hyphens)
        base_name.gsub('-', '') == entry.gsub('-', '')
      else
        true
      end
    end
    
    unless files.empty?
      puts "\nDirectory: #{path}"
      files.each do |file|
        puts "  \e[31m#{file}\e[0m"
      end
    end
  end
end

# Parse command line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options] [directory]"
  opts.on("-n", "--num-dirs NUMBER", Integer, "Number of directories to check") do |n|
    options[:num_dirs] = n
  end
end.parse!

# Get directory from command line or use current directory
dir = ARGV[0] || Dir.pwd
check_directory_files(dir, options[:num_dirs])