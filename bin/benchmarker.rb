#!/usr/bin/env ruby

require 'etc'
require 'net/http'
require 'oj'
require 'optparse'
require 'yaml'

$verbose = 1
$connections = 1000
$duration = 15
$record = false

opts = OptionParser.new(%{Usage: benchmarker.rb [options] <target>...

Run benchmarks on targets specified.
})
opts.on('-v', 'increase verbosity')                               { $verbose += 1 }
opts.on('-c', '--connections', Integer, 'number of connections')  { |c| $connections = c }
opts.on('-d', '--duration', Integer, 'duration in seconds')       { |d| $duration = d }
opts.on('-t', '--threads', Integer, 'ignored')                    { }
opts.on('-r', '--record', 'record to README.md')                  { $record = true }

opts.on('-h', '--help', 'Show this display')                      { puts opts.help; Process.exit!(0) }

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

  def initialize(lang, name, info)
    @name = name
    @lang = lang
    @version = info['version']
    @langver = info['language']
    if info.has_key?('github')
      @link = "github.com/#{info['github']}"
    else info.has_key?('website')
      @link = info['website']
    end
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

### Get up the targets ########################################################

YAML.load(File.read("FRAMEWORKS.yml")).each { |lang, frameworks|
  frameworks.each { |name, info|
    target = Target.new(lang, name, info)
    if $languages.has_key?(lang)
      language_targets = $languages[lang]
    else
      language_targets = {}
      $languages[lang] = language_targets
    end
    language_targets[name] = target
  }
}

$targets = []

$target_names.each { |target_name|
  if target_name.include?(':')
    lang, name = target_name.split(':')
    target = $languages[lang][name] if $languages.has_key?(lang)
    raise StandardException.new("#{target_name} not found") if target.nil?
    $targets << target
  elsif $languages.has_key?(target_name) # could be name of framework or language
    $languages[target_name].each { |_, target|
      $targets << target
    }
  else
    $languages.each { |_, frameworks|
      $targets << frameworks[target_name] if frameworks.has_key?(target_name)
    }
    raise StandardError.new("#{target_name} not found") if $targets.empty?
  end
}

if $targets.empty?
  $languages.each { |_, frameworks|
    frameworks.each { |_, target|
      $targets << target
    }
  }
end

### Running the benchmarks ####################################################

def benchmark(target, ip)
  ['/', '/graphql?query={hello\(name:"world"\)}'].each { |route|

    # First run at full throttle to get the maximum rate and throughput.
    out = `perfer -d #{$duration} -c #{$connections} -t 1 -k -b 4 -j http://#{ip}:3000#{route}`
    puts "#{target.name} - #{route} maximum rate output: #{out}" if 2 < $verbose
    bench = Oj.load(out, mode: :strict)

    target.duration += bench['options']['duration']
    target.requests += bench['results']['requests']
    target.bytes += bench['results']['totalBytes']

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

  ['/graphql'].each { |route|
    out = `perfer -d #{$duration} -c #{$connections} -t 1 -k -b 4 -j -a 'Content-Type: application/graphql' -p 'mutation { repeat(word: "Hello")}' http://#{ip}:3000#{route}`
    puts "#{target.name} - POST #{route} maximum rate output: #{out}" if 2 < $verbose
    bench = Oj.load(out, mode: :strict)

    target.duration += bench['options']['duration']
    target.requests += bench['results']['requests']
    target.bytes += bench['results']['totalBytes']

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
end

$targets.each { |target|
  begin
    puts "starting #{target.name}" if 1 < $verbose
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
    puts "Docker container for #{target.name} is #{cid}." if 1 < $verbose

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
    puts "Server on #{target.name} has responded." if 1 < $verbose

    benchmark(target, remote_ip)

  ensure
    puts "Stopping Docker container #{cid} for #{target.name}." if 1 < $verbose
    `docker stop #{cid}`
  end
  puts "Benchmarks for #{target.name} are done." if 1 < $verbose
}

### Display results ###########################################################

emojis = [ 'one', 'two', 'three', 'four', 'five' ]

lats = $targets.sort{ |ta, tb| ta.latency_mean <=> tb.latency_mean }
rates = $targets.sort{ |ta, tb| ta.rate <=> tb.rate }

$out = StringIO.new()

$out.puts('### Top 5 Ranking')
$out.puts('|     | Requests/second |     | Latency (milliseconds) |')
$out.puts('|:---:| --------------- |:---:| ---------------------- |')

lats[0..4].size.times { |i|
  lt = lats[i]
  rt = rates[i]
  $out.puts("| :%s: | %s (%s) | :%s: | %s (%s) |" % [emojis[i], rt.name, rt.lang, emojis[i], lt.name, lt.lang])
}
$out.puts()

$out.puts('#### Parameters')
$out.puts("- Last updates: #{Time.now.strftime("%Y-%m-%d")}")
$out.puts("- OS: #{`uname -s`.rstrip} (version: #{`uname -r`.rstrip}, arch: #{`uname -m`.rstrip})")
$out.puts("- CPU Cores: #{Etc.nprocessors}")
$out.puts("- Connections: #{$connections}")
$out.puts("- Duration: #{$duration} seconds")
$out.puts()

$out.puts('### Rate (requests per second)')
$out.puts('| Language (Runtime) | Framework (Middleware) | Requests/second | Throughput (MB/sec) |')
$out.puts('| -------------------| ---------------------- | ---------------:| -------------------:|')
rates.each { |t|
  $out.puts("| %s (%s) | [%s](%s) (%s) | %d | %.2f MB/sec |" % [t.lang, t.langver, t.name, t.link, t.version, t.rate.to_i, t.throughput])
}

$out.puts()
$out.puts('### Latency')
$out.puts('| Language (Runtime) | Framework (Middleware) | Average | Mean | 90th percentile | 99th percentile | 99.9th percentile | Standard Deviation |')
$out.puts('| ------------------ | ---------------------- | -------:| ----:| ---------------:| ---------------:| -----------------:| ------------------:|')
lats.each { |t|
  $out.puts("| %s (%s) | [%s](%s) (%s) | %.2f ms | %.2f ms | %.2f ms | %.2f ms | %.2f ms | %.2f |" %
	    [t.lang, t.langver, t.name, t.link, t.version, t.latency_average, t.latency_mean, t.latency_90, t.latency_99, t.latency_999, t.latency_stdev])
}

puts $out.string

if $record
  path = File.expand_path('../../README.md', __FILE__)
  readme = File.read(path)
  readme.gsub!(/\<!--\sResult\sfrom\shere\s-->[\s\S]*?<!--\sResult\still\shere\s-->/, "<!-- Result from here -->\n" + $out.string + "<!-- Result till here -->")
  File.write(path, readme)
end
