#!/usr/bin/env ruby

require 'rubygems'
require 'thread'
require 'logger'
require 'redis'

log = Logger.new(STDOUT)
log.level = Logger::DEBUG

sensors = ARGV[0]

redis = Redis.new

log.info("Running #{sensors} sensors")
Dir.glob(File.join('sensors', sensors, '**', '*')).each do |sensor|
  unless File.directory? sensor
    log.info "Running #{sensor}"
    output = %x[#{sensor}]
    output = output.to_i rescue output.chomp
    log.info "Received output:"
    log.info output
    redis.publish "live/#{sensor}", output
    redis.lpush "backlog/#{sensor}", output
  end
end

