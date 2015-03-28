

require 'optparse'

options = {:dry_run => false}

OptionParser.new do |opts|
  opts.banner = "Usage:random_break .rb [options]"
  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  opts.on("-f", "--file FILE", "File of paths to load") do |f|
    options[:file] = f
  end
  opts.on("-n", "--noop", "Enable dry-run, show output but don't execute scripts") do |f|
    options[:dry_run] = f
  end
  opts.on("-h", "--help", "Print help") do |h|
    options[:help] = h
  end

end.parse!

raise ArgumentError, "File #{options[:file]} not found" if ! File.exist?(options[:file])
if options[:help]
  exit
end

def self.run_script(script, dry_run=false)
  if dry_run
    puts script
  else
    puts `#{script}`
  end
end
  
file_array = []
File.open(options[:file], "r").each_line do |line|
  line.chomp!
  if ! File.exists?(line)
    puts "ERROR: The given directory #{line} was not present, skipping."
    next
  end
  if File.directory?(line)
    Dir.glob("#{line}/*.sh") do |script|
      file_array << script
    end
  else
    file_array << line
  end
end
run_script(file_array.sample, options[:dry_run])

