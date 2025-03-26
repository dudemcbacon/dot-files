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
      File.file?(File.join(path, file)) && 
      (!file.end_with?('.mkv', '.en.srt') || 
       File.basename(file, File.extname(file)).gsub('-', '') != entry.gsub('-', ''))
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