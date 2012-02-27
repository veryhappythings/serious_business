#!/usr/bin/env ruby
require 'json'
require 'net/ping'

if ARGV[0] == 'config'
  puts({
    'google_ping' => {
      'alert' => {
        'min' => 1,
        'max' => 9000
      }
    }
  }.to_json)
  exit
end
ping = Net::Ping::HTTP.new('http://www.google.com')
if ping.ping?
  result = ping.duration * 1000
else
  result = 0
end

puts({'google_ping' => result.to_i}.to_json)
