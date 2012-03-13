#!/usr/bin/env ruby
require 'json'
require 'net/ping'

if ARGV[0] == 'config'
  puts({
    'google_ping' => {
      'category' => 'example sensors',
      'name' => 'ping',
      'alert' => {
        'min' => 1,
        'max' => 9000
      }
    }
  }.to_json)
  exit
end

sites = {
  'google_ping' => 'http://www.google.com'
}

result = {}
sites.each_pair do |key, address|
  if address =~ /^[a-z]/
    ping = Net::Ping::HTTP.new(address)
  else
    # Account for IP addresses
    ping = Net::Ping::External.new(address)
  end
  if ping.ping?
    result[key] = ping.duration * 1000
  else
    result[key] = 0
  end
end

puts(result.to_json)
