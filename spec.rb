
require 'net/http'
require 'rspec'
require 'yaml'
require 'oj'

Oj.default_options = { mode: :strict, indent: 2, symbol_keys: true }

class GetPoster
  attr_accessor :ip

  def initialize(ip)
    @ip = ip
  end

  def get(path)
    uri = URI("http://#{@ip}:3000#{path}")
    req = Net::HTTP::Get.new(uri)
    Net::HTTP.start(uri.hostname, uri.port) { |h|
      h.request(req)
    }
  end

  def post(content, type)
    uri = URI("http://#{@ip}:3000/graphql")
    req = Net::HTTP::Post.new(uri)
    req['Accept-Encoding'] = '*'
    req['Content-Type'] = type
    req.body = content
    Net::HTTP.start(uri.hostname, uri.port) { |h|
      h.request(req)
    }
  end

end

class TestClient < GetPoster
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

end

$local = nil
if ENV["LOCAL_FRAMEWORK"].nil?
  if ENV["FRAMEWORK"].nil?
    $targets = []
  else
    $targets = ENV["FRAMEWORK"].split(',')
  end
else
  $local = ENV["LOCAL_FRAMEWORK"]
end

root = File.expand_path('../frameworks', __FILE__)

$query = '/graphql?query={artists{name,origin,songs{name,duration,likes}},__schema{types{name,fields{name}}}}'

def check_tree(path, exp, act)
  case exp
  when Hash
    exp.each { |k,v| check_tree("#{path}.#{k}", v, act[k]) }
  when Array
    # If elements are Hashs then use name to match otherwise assume order is
    # important.
    if 0 < exp.size
      if exp[0].is_a?(Hash)
	exp.each_with_index { |v,i|
	  name = v[:name]
	  p2 = "#{path}.@name=#{name}"
	  found = false
	  act.each { |av|
	    if name == av[:name]
	      check_tree(p2, v, av)
	      found = true
	      break
	    end
	  }
	  describe "value at #{p2}" do
	    it "should not be nil" do
	      expect(found).to eq true
	    end
	  end
	}
      else
	exp.each_with_index { |v,i| check_tree("#{path}.#{i}", v, act[i]) }
      end
    end
  else
    describe "value at #{path} should be #{exp}" do
      it "should match" do
	expect(act).to eq exp
      end
    end
  end
end

$expect_result = {
  data: {
    artists: [
      {name: 'Fazerdaze', origin: ['Morningside', 'Auckland', 'New Zealand'],
       songs: [
	 {name: 'Jennifer', duration: 240, likes: 0},
	 {name: 'Lucky Girl', duration: 170, likes: 0},
	 {name: 'Friends', duration: 194, likes: 0},
	 {name: 'Reel', duration: 193, likes: 0}
       ]
      },
      {name: 'Viagra Boys', origin: ['Stockholm', 'Sweden'],
       songs: [
	 {name: 'Down In The Basement', duration: 216, likes: 0},
	 {name: 'Frogstrap', duration: 195, likes: 0},
	 {name: 'Worms', duration: 208, likes: 0},
	 {name: 'Amphetanarchy', duration: 346, likes: 0}
       ]
      }
    ],
    __schema: {
      types: [
	{
	  name: '__EnumValue',
	  fields: [
	    {name: 'name'},
	    {name: 'description'},
	    {name: 'isDeprecated'},
	    {name: 'deprecationReason'}
	  ]
	},
	{name: 'Int'},
	{name: 'I64'},
	{name: '__DirectiveLocation'},
	{name: 'Time'},
	{name: '__Schema',
	 fields: [
	   {name: 'types'},
	   {name: 'queryType'},
	   {name: 'mutationType'},
	   {name: 'subscriptionType'},
	   {name: 'directives'}
	 ]
	},
	{name: 'Mutation',
	 fields: [
	   {name: 'like'}
         ]
        },
        {name: 'Date'},
        {name: 'Uuid'},
        {name: 'Boolean'},
        {name: 'schema',
	 fields: [
           {name: 'query'},
           {name: 'mutation'}
         ]
        },
        {name: 'String'},
        {name: 'Song',
         fields: [
           {name: 'name'},
           {name: 'artist'},
           {name: 'duration'},
           {name: 'release'},
           {name: 'likes'}
         ]
        },
        {name: 'ID'},
        {name: 'Artist',
         fields: [
           {name: 'name'},
           {name: 'songs'},
           {name: 'origin'}
         ]
        },
        {name: '__Directive',
         fields: [
           {name: 'name'},
           {name: 'description'},
           {name: 'locations'},
           {name: 'args'}
         ]
        },
        {name: '__Field',
         fields: [
           {name: 'name'},
           {name: 'description'},
           {name: 'args'},
           {name: 'type'},
           {name: 'isDeprecated'},
           {name: 'reason'}
         ]
        },
        {name: '__TypeKind'},
        {name: 'Query',
         fields: [
           {name: 'artist'},
           {name: 'artists'}
         ]
        },
        {name: '__InputValue',
         fields: [
           {name: 'name'},
           {name: 'description'},
           {name: 'type'},
           {name: 'defaultValue'}
         ]
        },
        {name: '__Type',
         fields: [
           {name: 'kind'},
           {name: 'name'},
           {name: 'description'},
           {name: 'fields'},
           {name: 'interfaces'},
           {name: 'possibleTypes'},
           {name: 'enumValues'},
           {name: 'inputFields'},
           {name: 'ofType'}
         ]
        },
        {name: 'Float'}
      ]
    }
  }
}

def run_test(base, client)
  puts "Testing #{base}"
  describe "#{base} get on /" do
    res = client.get('/')
    it 'should return a status code of 200' do
      expect(res.code).to eq '200'
    end
    it 'should return an empty body' do
      expect(res.body).to eq ''
    end
  end

  describe "#{base} get on #{$query}" do
    res = client.get($query)
    it 'should return a status code of 200' do
      expect(res.code).to eq '200'
    end
    result = Oj.load(res.body)
    check_tree('result', $expect_result, result)
  end

  describe "#{base} post on /graphql" do
    10.times { |i|
      res = client.post(%|mutation{like(artist:"Fazerdaze",song:"Jennifer"){likes}}|, 'application/graphql')
      it 'should return a status code of 200' do
	expect(res.code).to eq '200'
      end
      it %|should return {"data":{"like":{"likes":#{i+1}}}}| do
	expect(res.body).to eq %|{"data":{"like":{"likes":#{i+1}}}}|
      end
    }
  end
end

if $local.nil?
  Dir.glob(root + '/*').each { |dir|
    base = File.basename(dir)
    info = YAML.load(File.read(dir + "/info.yml"))
    if $targets.nil? || 0 == $targets.size || $targets.include?(info['name']) || $targets.include?(info['language'])
      begin
	tc = TestClient.new(base)
	run_test(base, tc)
      ensure
	tc.stop
      end
    end
  }
else
  c = GetPoster.new('127.0.0.1')
  run_test($local, c)
end
