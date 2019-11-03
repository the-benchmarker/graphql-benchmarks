#!/usr/bin/env ruby

def ccnt(args)
  cnt = 0
  args.each do |a|
    Dir.glob(a) { |f| cnt += ccnt_file(f) }
  end
  puts "#{cnt} lines"
end

def ccnt_file(filename)
  return unless File.readable?(filename)
  cnt = 0
  f = File.new(filename)
  f.each_line do |line|
    line.strip!
    next if line.length == 0
    # skip comments
    next if line[0] == '#'
    next if line[0] == '/' && 1 < line.length && lines[1] == '/'
    cnt += 1 + line.length / 80
  end
  cnt
end

begin
  ccnt(ARGV)
rescue Exception => e
  puts "#{e.class}: #{e.message}"
  puts %{Usage:
ccnt [<file pattern>]
  }
end
