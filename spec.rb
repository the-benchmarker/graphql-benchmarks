
require 'rspec'
require 'net/http'
require 'yaml'

class TestClient
  def initialize(name)
    @name = name
    @cid = `docker run -td #{@name}`.strip
    # Dual purpose, get the IP address in the container for the server and
    # detect when the container is available. That avoids using a simple sleep
    # which sets up a race condition.
    remote_ip = nil
    20.times do
      remote_ip = `docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' #{@cid}`.strip
      break if nil != remote_ip && 0 < remote_ip.size()
      sleep 1
    end
    raise StandardError.new("failed to start docker for #{@name}") if remote_ip.nil? || remote_ip.empty?
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
    @ip = `docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' #{@cid}`.strip
  end

  def stop
    `docker stop #{@cid}`unless @cid.nil?
  end

  def get(path)
    uri = URI("http://#{@ip}:3000#{path}")
    req = Net::HTTP::Get.new(uri)
    res = Net::HTTP.start(uri.hostname, uri.port) { |h|
      h.request(req)
    }
  end

  def post(content, type)
    uri = URI("http://#{@ip}:3000/graphql")
    req = Net::HTTP::Post.new(uri)
    req['Accept-Encoding'] = '*'
    req['Content-Type'] = type
    req.body = content
    res = Net::HTTP.start(uri.hostname, uri.port) { |h|
      h.request(req)
    }
  end

end

if ENV["FRAMEWORK"].nil?
  $targets = []
else
  $targets = ENV["FRAMEWORK"].split(',')
end

root = File.expand_path('../frameworks', __FILE__)

Dir.glob(root + '/*').each { |dir|
  base = File.basename(dir)
  info = YAML.load(File.read(dir + "/info.yml"))
  if $targets.nil? || 0 == $targets.size || $targets.include?(info['name']) || $targets.include?(info['language'])
    puts "Testing #{base}"
    begin
      tc = TestClient.new('agoo')

      describe "#{base} get on /" do
	res = tc.get('/')
	it 'should return a status code of 200' do
	  expect(res.code).to eq '200'
	end
	it 'should return an empty body' do
	  expect(res.body).to eq ''
	end
      end

      describe "#{base} get on /graphql?query={hello}" do
	res = tc.get('/graphql?query={hello(name:"World")}')
	it 'should return a status code of 200' do
	  expect(res.code).to eq '200'
	end
	it %|should return {"data":{"hello":"Hello World"}}| do
	  expect(res.body).to eq %|{"data":{"hello":"Hello World"}}|
	end
      end

      describe "#{base} post on /graphql" do
	10.times { |i|
	  res = tc.post(%|mutation { like }|, 'application/graphql')
	  it 'should return a status code of 201' do
	    expect(res.code).to eq '200'
	  end
	  it %|should return {"data":{"like":#{i+1}}}| do
	    expect(res.body).to eq %|{"data":{"like":#{i+1}}}|
	  end
	}
      end

    ensure
      tc.stop
    end
  end
}
