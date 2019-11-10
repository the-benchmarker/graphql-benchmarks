#!/usr/bin/env ruby

require 'optparse'
require 'yaml'

$verbose = 1
$all = false

opts = OptionParser.new(%{Usage: build.rb [options] [<target>...]

Build the specified frameworks in the 'frameworks' directory. If no framework
is specified then all will be built. The target can also be a language.
})
opts.on('-v', 'increase verbosity')                { $verbose += 1 }
opts.on('-a', 'build all including experimental')  { $all = true }
opts.on('-h', '--help', 'Show this display')       { puts opts.help; Process.exit!(0) }

$targets = opts.parse(ARGV)

root = File.expand_path('../frameworks', __FILE__)

Dir.glob(root + '/*').each { |dir|
  base = File.basename(dir)
  info = YAML.load(File.read(dir + "/info.yml"))
  next if !$all && info['experimental']
  if $targets.nil? || 0 == $targets.size || $targets.include?(info['name']) || $targets.include?(info['language'])
    Dir.chdir(dir) {
      puts "running: docker build -t #{base} ." if 2 <= $verbose
      out = `docker build -t #{base} .`
      if 0 != $?.exitstatus
	puts "*-*-* Docker build for #{base} failed."
	puts out if 2 <= $verbose
      else
	puts "#{base} built successfully" if 2 <= $verbose
	puts out if 3 <= $verbose
      end
    }
  end
}
