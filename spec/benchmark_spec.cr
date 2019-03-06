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
  it "should rerturn an empty body" { r.body.should eq "" }
end

describe "get on /graphql?query={hello}" do
  name = ENV["FRAMEWORK"]
  remote_ip = get_ip(name)
  r = HTTP::Client.get "http://#{remote_ip}:3000/graphql?query={hello}"
  it "should reply with a 200 status code" { r.status_code.should eq 200 }
  it "should return <0>" { r.body.should eq %|{"data":{"hello":"Hello"}}| }
end
