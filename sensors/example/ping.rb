#!/usr/bin/env ruby
require 'json'
require 'net/ping'

if ARGV[0] == 'config'
  puts({
    'alert' => {
      'min' => 1,
      'max' => 9000
    }
  }.to_json)
  exit
end
ping = Net::Ping::HTTP.new('http://www.google.com')
if ping.ping?
  puts ping.duration
else
  puts 0
end
