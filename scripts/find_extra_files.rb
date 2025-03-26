def check_directory_files(base_dir)
  Dir.entries(base_dir).select do |entry|
    path = File.join(base_dir, entry)
    if File.directory?(path) && !['.', '..'].include?(entry)
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
end

# Get directory from command line or use current directory
dir = ARGV[0] || Dir.pwd
check_directory_files(dir)