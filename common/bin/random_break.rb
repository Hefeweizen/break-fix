#!/usr/bin/ruby

# Break Fix Exercises
# Copyright (C) 2015 Dan Klopp
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


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

def self.run_script(script, dry_run=false, verbose=false)
  if dry_run or verbose
    puts script
  end
  if !dry_run
    output = `#{script}`
    if verbose
      puts output
    end
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
run_script(file_array.sample, options[:dry_run], options[:verbose])
