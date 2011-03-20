#!/usr/bin/env ruby

require 'rubygems'
require 'date'
require 'thread'
require 'logger'
require 'json'

require 'redis'

log = Logger.new(STDOUT)
log.level = Logger::DEBUG

sensors = ARGV[0]

redis = Redis.new

log.info("Running #{sensors} sensors")
Dir.glob(File.join('sensors', sensors, '**', '*')).each do |sensor|
  unless File.directory? sensor
    date = DateTime.now
    log.info "Running #{sensor}"
    output = %x[#{sensor}]
    output = output.to_i rescue output.chomp
    log.info "Received output:"
    log.info output
    result = {:date => date, :output => output}.to_json
    redis.publish "live/#{sensor}", result
    redis.lpush "backlog/#{sensor}", result
  end
end

