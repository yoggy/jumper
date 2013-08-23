#!/usr/bin/ruby
#
#
# $ sudo gem install ruby-osc
#

require 'rubygems'
require 'ruby-osc'
require 'socket'
require 'json'
require "open-uri"
require 'pp'

include OSC

$host = "192.168.122.1"
$port = 8080

def start_preview
	# enable preview
	s = TCPSocket.open($host, $port)
	s.print("POST /sony/camera HTTP/1.1\r\nContent-Length: 60\r\n\r\n{\"method\":\"startRecMode\",\"params\":[],\"id\":5,\"version\":\"1.0\"}")
	s.flush
	body = s.read.split(/\r\n\r\n/)[1]
	p JSON.parse(body)
	s.close
end

def take_picture
	s = TCPSocket.open($host, $port)
	s.print("POST /sony/camera HTTP/1.1\r\nContent-Length: 63\r\n\r\n{\"method\":\"actTakePicture\",\"params\":[],\"id\":10,\"version\":\"1.0\"}")
	s.flush
	body = s.read.split(/\r\n\r\n/)[1]
	doc = JSON.parse(body)
	s.close
	 
	# {"id":10,"result":[["http://192.168.122.1:8080/postview/pict20130614_175010_0.JPG"]]}
	result_url = doc["result"][0][0]
	result_filename = File.split(result_url)[1]
end

#
def main
	start_preview

	OSC.run do
		server = Server.new(12345)
		server.add_pattern '/take_picture' do |*args|
			pp args
			take_picture
		end
	end
end

if __FILE__ == $0
	main
end



