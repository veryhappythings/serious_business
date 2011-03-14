#!/usr/bin/env ruby

require 'rubygems'
require 'thread'
require 'logger'
require 'redis'

log = Logger.new(STDOUT)
log.level = Logger::DEBUG

sensors = ARGV[0]

redis = Redis.new

Dir.glob(File.join('sensors', sensors, '**', '*')).each do |sensor|
  unless File.directory? sensor
    log.info "Running #{sensor}"
    output = %x[#{sensor}]
    log.info "Received output:"
    log.info output.chomp
    redis.publish "live/#{sensor}", output
    redis.lpush "backlog/#{sensor}", output
  end
end

