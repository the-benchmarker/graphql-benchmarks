require "./spec_helper"

def get_ip(name)
  cid = `docker run -td #{name}`.strip
  sleep 20 # due to external program usage
  ip = `docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' #{cid}`.strip
  ip
end

describe "get on /" do
  name = ENV["FRAMEWORK"]
  remote_ip = get_ip(name)
  r = HTTP::Client.get "http://#{remote_ip}:3000/"
  it "should reply with a 200 status code" { r.status_code.should eq 200 }
  it "should return an empty body" { r.body.should eq "" }
end

describe "get on /graphql?query={hello}" do
  name = ENV["FRAMEWORK"]
  remote_ip = get_ip(name)
  r = HTTP::Client.get %|http://#{remote_ip}:3000/graphql?query={hello(name:"World")}|
  it "should reply with a 200 status code" { r.status_code.should eq 200 }
  it %|should return {"data":{"hello":"Hello World"}}| { r.body.should eq %|{"data":{"hello":"Hello World"}}| }
end

describe "post on /graphql" do
  name = ENV["FRAMEWORK"]
  body = %|mutation { like }|
  headers = HTTP::Headers { "Content-Type" => "application/graphql" }
  remote_ip = get_ip(name)
  10.times { |i|
    r = HTTP::Client.post("http://#{remote_ip}:3000/graphql", headers: headers, body: body)
    it "should reply with a 200" { r.status_code.should eq 200 }
    it %|should return {"data":{"like":#{i+1}}}| { r.body.should eq %|{"data":{"like":#{i+1}}}| }
  }
end
