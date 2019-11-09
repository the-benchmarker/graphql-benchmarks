#!/usr/bin/env ruby

require 'etc'
require 'net/http'
require 'oj'
require 'optparse'
require 'yaml'

$verbose = 1
$connections = 1000
$threads = Etc.nprocessors() / 3
$duration = 20
$record = false

opts = OptionParser.new(%{Usage: benchmarker.rb [options] <target>...

Run benchmarks on targets specified.
})
opts.on('-v', 'increase verbosity')                                      { $verbose += 1 }
opts.on('-c', '--connections NUMBER', Integer, 'number of connections')  { |c| $connections = c }
opts.on('-d', '--duration SECONDS', Integer, 'duration in seconds')      { |d| $duration = d }
opts.on('-t', '--threads NUMBER', Integer, 'ignored')                    { |t| $threads = t }
opts.on('-r', '--record', 'record to README.md')                         { $record = true }

opts.on('-h', '--help', 'Show this display')                             { puts opts.help; Process.exit!(0) }

$target_names = opts.parse(ARGV)
$languages = {}

# Serves as the collector of results and description of a target.
class Target
  attr_accessor :name
  attr_accessor :lang
  attr_accessor :langver
  attr_accessor :version
  attr_accessor :link
  attr_accessor :duration
  attr_accessor :requests
  attr_accessor :bytes
  attr_accessor :adjust
  attr_accessor :code_files
  attr_accessor :verbosity

  def initialize(info)
    @name = info['name']
    @version = info['version']
    @lang = info['language']
    @langver = info['language-version']
    if info.has_key?('github')
      @link = "github.com/#{info['github']}"
    else info.has_key?('website')
      @link = info['website']
    end
    @adjust = info['bench-adjust']
    @adjust = 1.0 if @adjust.nil?
    @experimental = info['experimental']
    @post_format = info['post-format']
    @code_files = info['code'].split(',').map { |name| name.strip }

    @duration = 0.0
    @requests = 0
    @bytes = 0
    @lat_ave = 0.0
    @lat_mean = 0.0
    @lat_stdev = 0.0
    @lat_90 = 0.0
    @lat_99 = 0.0
    @lat_999 = 0.0
    @lat_cnt = 0
    @verbosity = 0
  end

  def to_s
    "Target{ lang: #{@lang} name: #{@name} version: #{@version} link: #{@link} duration: #{@duration} requests: #{@requests} }"
  end

  def add_latency(average, mean, stdev, l90, l99, l999)
    @lat_ave += average
    @lat_mean += mean
    @lat_stdev += stdev
    @lat_90 += l90
    @lat_99 += l99
    @lat_999 += l999
    @lat_cnt += 1
  end

  def latency_average
    return 0 if @lat_cnt <= 0
    @lat_ave.to_f / @lat_cnt.to_f
  end

  def latency_mean
    return 0 if @lat_cnt <= 0
    @lat_mean.to_f / @lat_cnt.to_f
  end

  def latency_stdev
    return 0 if @lat_cnt <= 0
    @lat_stdev.to_f / @lat_cnt.to_f
  end

  def latency_90
    return 0 if @lat_cnt <= 0
    @lat_90.to_f / @lat_cnt.to_f
  end

  def latency_99
    return 0 if @lat_cnt <= 0
    @lat_99.to_f / @lat_cnt.to_f
  end

  def latency_999
    return 0 if @lat_cnt <= 0
    @lat_999.to_f / @lat_cnt.to_f
  end

  def rate
    return 0 if @duration <= 0
    @requests.to_f / @duration.to_f
  end

  def throughput
    return 0 if @duration <= 0
    (@bytes / 1024 / 1024).to_f / @duration.to_f
  end

end

### Collect the frameworks ########################################################

$targets = []

root = File.expand_path('../frameworks', __FILE__)
Dir.glob(root + '/*').each { |dir|
  base = File.basename(dir)
  info = YAML.load(File.read(dir + "/info.yml"))
  next if !$all && info['experimental']
  if $target_names.nil? || 0 == $target_names.size || $target_names.include?(info['name']) || $target_names.include?(info['language'])
    $targets << Target.new(info)
  end
}

### Running the benchmarks ####################################################

def benchmark(target, ip)
  thread_count = ($threads * target.adjust).to_i
  thread_count = 1 if 1 > thread_count
  complex = '/graphql?query={artists{name,origin,songs{name,duration,likes}},__schema{types{name,fields{name}}}}'

  # query
  # Multiple paths can be used. For just the graphql part use only the
  # 'complex' path.
  #['/', complex].each { |route|
  #[complex].each { |route|
  [].each { |route|
    # throughput: First run at full throttle to get the maximum rate and throughput.
    out = `perfer -d #{$duration} -c #{$connections} -t #{thread_count} -k -b 5 -j "http://#{ip}:3000#{route}"`
    puts "#{target.name} - #{route} maximum rate output: #{out}" if 2 < $verbose
    bench = Oj.load(out, mode: :strict)

    target.duration += bench['options']['duration'].to_f
    target.requests += bench['results']['requests']
    target.bytes += bench['results']['totalBytes']

    # latency
    # Make a separate run for latency are a leisurely rate to determine the
    # latency when under normal load.
    out = `perfer -d #{$duration} -c 10 -t 1 -k -b 1 -j -m 1000 -l 50,90,99,99.9 "http://#{ip}:3000#{route}"`
    puts "#{target.name} - #{route} latency output: #{out}" if 2 < $verbose
    bench = Oj.load(out, mode: :strict)

    results = bench['results']
    spread = results['latencySpread']
    target.add_latency(results['latencyAverageMilliseconds'],
		       results['latencyMeanMilliseconds'],
		       results['latencyStdev'],
		       spread['90.00'],
		       spread['99.00'],
		       spread['99.90'])
  }

  # mutation
  ['/graphql'].each { |route|
    # throughput
    out = `perfer -d #{$duration} -c #{$connections} -t #{thread_count} -k -b 3 -j -a 'Content-Type: application/graphql' -p 'mutation{like(artist:"Fazerdaze",song:"Jennifer"){likes}}' http://#{ip}:3000#{route}`
    puts "#{target.name} - POST #{route} maximum rate output: #{out}" if 2 < $verbose
    bench = Oj.load(out, mode: :strict)

    target.duration += bench['options']['duration']
    target.requests += bench['results']['requests']
    target.bytes += bench['results']['totalBytes']

    # latency
    # Make a separate run for latency are a leisurely rate to determine the
    # latency when under normal load.
    out = `perfer -d #{$duration} -c 10 -t 1 -k -b 1 -j -m 1000 -l 50,90,99,99.9 http://#{ip}:3000#{route}`
    puts "#{target.name} - #{route} latency output: #{out}" if 2 < $verbose
    bench = Oj.load(out, mode: :strict)

    results = bench['results']
    spread = results['latencySpread']
    target.add_latency(results['latencyAverageMilliseconds'],
		       results['latencyMeanMilliseconds'],
		       results['latencyStdev'],
		       spread['90.00'],
		       spread['99.00'],
		       spread['99.90'])
  }
  [target.rate, target.latency_mean]
end

def count_lines(filenames)
  cnt = 0
  filenames.each { |filename|
    next unless File.readable?(filename)
    f = File.new(filename)
    f.each_line do |line|
      line.strip!
      next if line.length == 0
      # skip comments
      next if line[0] == '#'
      next if line[0] == '/' && 1 < line.length && line[1] == '/'
      cnt += 1 + line.length / 80
    end
  }
  cnt
end

$targets.each { |target|
  begin
    target.verbosity = count_lines(target.code_files)

    puts "#{target.name}" if 1 < $verbose
    cid = `docker run -td #{target.name}`.strip
    remote_ip = nil
    # Dual purpose, get the IP address in the container for the server and
    # detect when the container is available. That avoids using a simple sleep
    # which sets up a race condition.
    20.times do
      remote_ip = `docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' #{cid}`.strip
      break if nil != remote_ip && 0 < remote_ip.size()
      sleep 1
    end
    raise StandardError.new("failed to start docker for #{target.name}") if remote_ip.nil? || remote_ip.empty?
    puts "Docker container for #{target.name} is #{cid} at #{remote_ip}." if 2 < $verbose

    # Wait for the server in the container to be up and responsive before
    # continuing using the same technique of avoiding a race condition.
    error = nil
    20.times do
      begin
	uri = URI("http://#{remote_ip}:3000")
	content = Net::HTTP.get(uri)
	error = nil
	break if nil != content
      rescue Exception => e
	error = e
	sleep 1
      end
    end
    raise error unless error.nil?
    puts "Server on #{target.name} has responded." if 2 < $verbose

    sleep 2

    benchmark(target, remote_ip)
    puts "  Benchmarks for #{target.name} - rate: #{target.rate.to_i} req/sec  latency: #{target.latency_mean.round(2)} ms." if 1 < $verbose
  ensure
    puts "Stopping Docker container #{cid} for #{target.name}." if 2 < $verbose
    `docker stop #{cid}`
  end
}

### Display results ###########################################################

$emojis = [ 'one', 'two', 'three', 'four', 'five' ]

lats = $targets.sort{ |ta, tb| ta.latency_mean <=> tb.latency_mean }
rates = $targets.sort{ |ta, tb| tb.rate <=> ta.rate }
verbs = $targets.sort{ |ta, tb| tb.verbosity <=> ta.verbosity }

def add_params(out)
  out.puts('#### Parameters')
  out.puts("- Last updated: #{Time.now.strftime("%Y-%m-%d")}")
  out.puts("- OS: #{`uname -s`.rstrip} (version: #{`uname -r`.rstrip}, arch: #{`uname -m`.rstrip})")
  out.puts("- CPU Cores: #{Etc.nprocessors}")
  out.puts("- Connections: #{$connections}")
  out.puts("- Duration: #{$duration} seconds")
  out.puts()
end

def add_links(out)
  out.puts("| [Latency](latency.md) | [Throughput](rates.md) | [Verbosity](verbosity.md) | [README](README.md) |")
  out.puts("| --------------------- | --------------------------- | ------------------------- | ------------------- |")
end

# TBD use functions for common stuff

$out = StringIO.new()

$out.puts('### Top 5 Ranking')
$out.puts('|     | Requests/second |     | Latency (milliseconds) | Verbosity |')
$out.puts('|:---:| --------------- |:---:| ---------------------- | --------- |')

lats[0..4].size.times { |i|
  lt = lats[i]
  rt = rates[i]
  vt = verbs[i]
  $out.puts("| :%s: | %s (%s) | %s (%s) | %s (%s) |" %
	    [$emojis[i], rt.name, rt.lang, lt.name, lt.lang, vt.name, vt.lang])
}
$out.puts()

add_params($out)

$out.puts('### Rate (requests per second)')
$out.puts('| Language | Framework | Requests/second | Throughput (MB/sec) |')
$out.puts('| -------------------| ---------------------- | ---------------:| -------------------:|')
rates.each { |t|
  $out.puts("| %s (%s) | [%s](%s) (%s) | %d | %.2f MB/sec |" % [t.lang, t.langver, t.name, t.link, t.version, t.rate.to_i, t.throughput])
}
$out.puts()

$out.puts('### Latency')
$out.puts('| Language | Framework | Average Latency | Mean Latency | 90th percentile | 99th percentile | 99.9th percentile | Standard Deviation | Rate | Verbosity |')
$out.puts('| ------------------ | ---------------------- | ---------------:| ------------:| ---------------:| ---------------:| -----------------:| ------------------:| ------:| ------:|')
lats.each { |t|
  $out.puts("| %s (%s) | [%s](%s) (%s) | %.2f ms | **%.2f ms** | %.2f ms | %.2f ms | %.2f ms | %.2f | %.2f | %d |" %
	     [t.lang, t.langver, t.name, t.link, t.version, t.latency_average, t.latency_mean, t.latency_90, t.latency_99, t.latency_999, t.latency_stdev, t.throughput, t.verbosity])
}
$out.puts()

puts $out.string

def update_readme(lats, rates, verbs)
  out = StringIO.new()
  out.puts('### Top 5 Ranking')
  out.puts('|     | Requests/second |     | Latency (milliseconds) | Verbosity |')
  out.puts('|:---:| --------------- |:---:| ---------------------- | --------- |')

  lats[0..4].size.times { |i|
    lt = lats[i]
    rt = rates[i]
    vt = verbs[i]
    out.puts("| :%s: | %s (%s) | %s (%s) | %s (%s) |" %
	      [$emojis[i], rt.name, rt.lang, lt.name, lt.lang, vt.name, vt.lang])
  }
  out.puts()
  add_params(out)
  add_links(out)

  path = File.expand_path('../README.md', __FILE__)
  readme = File.read(path)
  readme.gsub!(/\<!--\sResult\sfrom\shere\s-->[\s\S]*?<!--\sResult\still\shere\s-->/, "<!-- Result from here -->\n" + out.string + "<!-- Result till here -->")
  File.write(path, readme)
end

def update_latency(lats)
  out = StringIO.new()
  out.puts()
  add_params(out)
  add_links(out)
  out.puts()
  out.puts('### Latency')
  out.puts('| Language | Framework | Average Latency | Mean Latency | 90th percentile | 99th percentile | 99.9th percentile | Standard Deviation | Rate | Verbosity |')
  out.puts('| ------------------ | ---------------------- | ---------------:| ------------:| ---------------:| ---------------:| -----------------:| ------------------:| ------:| ------:|')
  lats.each { |t|
    out.puts("| %s (%s) | [%s](%s) (%s) | %.2f ms | **%.2f ms** | %.2f ms | %.2f ms | %.2f ms | %.2f | %.2f | %d |" %
	     [t.lang, t.langver, t.name, t.link, t.version, t.latency_average, t.latency_mean, t.latency_90, t.latency_99, t.latency_999, t.latency_stdev, t.throughput, t.verbosity])
  }
  path = File.expand_path('../latency.md', __FILE__)
  content = File.read(path)
  content.gsub!(/\<!--\sResult\sfrom\shere\s-->[\s\S]*?<!--\sResult\still\shere\s-->/, "<!-- Result from here -->\n" + out.string + "<!-- Result till here -->")
  File.write(path, content)
end

def update_rates(rates)
  out = StringIO.new()
  out.puts()
  add_params(out)
  add_links(out)
  out.puts()

  out.puts('### Rate (requests per second)')
  out.puts('| Language | Framework | Requests/second | Throughput (MB/sec) | Latency (msecs) | Verbosity |')
  out.puts('| -------------------| ---------------------- | ---------------:| -------------------:| ------:| -----:|')
  rates.each { |t|
    out.puts("| %s (%s) | [%s](%s) (%s) | %d | %.2f MB/sec |" %
	     [t.lang, t.langver, t.name, t.link, t.version, t.rate.to_i, t.throughput, t.latency_mean, t.verbosity])
  }

  path = File.expand_path('../rates.md', __FILE__)
  content = File.read(path)
  content.gsub!(/\<!--\sResult\sfrom\shere\s-->[\s\S]*?<!--\sResult\still\shere\s-->/, "<!-- Result from here -->\n" + out.string + "<!-- Result till here -->")
  File.write(path, content)
end

def update_verbs(verbs)
  out = StringIO.new()
  out.puts()
  add_params(out)
  add_links(out)
  out.puts()

  out.puts('### Verbosity (lines of code)')
  out.puts('| Language | Framework | Requests/second | Throughput (MB/sec) | Latency (msecs) | Verbosity |')
  out.puts('| -------------------| ---------------------- | ---------------:| -------------------:| ------:| -----:|')
  verbs.each { |t|
    out.puts("| %s (%s) | [%s](%s) (%s) | %d | %.2f MB/sec |" %
	     [t.lang, t.langver, t.name, t.link, t.version, t.rate.to_i, t.throughput, t.latency_mean, t.verbosity])
  }

  path = File.expand_path('../verbosity.md', __FILE__)
  content = File.read(path)
  content.gsub!(/\<!--\sResult\sfrom\shere\s-->[\s\S]*?<!--\sResult\still\shere\s-->/, "<!-- Result from here -->\n" + out.string + "<!-- Result till here -->")
  File.write(path, content)
end

if $record
  update_readme(lats, rates, verbs)
  update_latency(lats)
  update_rates(rates)
  update_verbs(verbs)
end
