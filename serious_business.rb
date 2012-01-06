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
Dir.glob(File.join('sensors', sensors, '**', '*.rb')).each do |sensor|
  unless File.directory? sensor
    date = DateTime.now

    log.info "Running #{sensor}"

    config = %x[#{sensor} config]
    config = JSON.parse(config.chomp) rescue nil
    log.info 'Config:'
    log.info config

    output = %x[#{sensor}]
    output = output.to_i rescue output.chomp
    log.info "Received output:"
    log.info output

    result = {:date => date, :output => output}

    if config
      if config['alert']
        if output < config['alert']['min'] || output > config['alert']['max'].to_i
          result[:alert] = true
        end
      end
    end


    result = result.to_json
    log.info result

    sensor = sensor.to_s.gsub /\//, ':'
    redis.publish "live:#{sensor}", result
    redis.lpush "backlog:#{sensor}", result
  end
end

