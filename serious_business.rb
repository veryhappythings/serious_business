#!/usr/bin/env ruby

require 'rubygems'
require 'date'
require 'thread'
require 'logger'
require 'json'

require 'redis'

class SeriousBusiness
  @@log = Logger.new(STDOUT)
  @@log.level = Logger::DEBUG

  def self.log
    @@log
  end
end
log = SeriousBusiness.log

sensors = ARGV[0]

redis = Redis.new

def process_config(config)
  JSON.parse(config.chomp) rescue {}
end

def process_sensor(sensor)
  begin
    JSON.parse(sensor.chomp)
  rescue Exception => ex
    SeriousBusiness.log.error(ex)
    {}
  end
end

log.info("Running #{sensors} sensors")
Dir.glob(File.join('sensors', sensors, '**', '*.rb')).each do |sensor|
  unless File.directory? sensor
    date = DateTime.now

    log.info "Running #{sensor}"

    config = %x[#{sensor} config]
    config = process_config(config)
    log.info 'Config:'
    log.info config

    output = %x[#{sensor}]
    output = process_sensor(output)
    log.info "Received output:"
    log.info output

    output.each_pair do |key, data|
      sensor_config = config[key]
      result = {
        :date => date,
        :output => data
      }

      if sensor_config
        if sensor_config['alert']
          if sensor_config['alert']['min'] && data < sensor_config['alert']['min'].to_i
            result[:alert] = true
          end
          if sensor_config['alert']['max'] && data > sensor_config['alert']['max'].to_i
            result[:alert] = true
          end
        end
      end


      result = result.to_json
      log.info result

      sensor = sensor.to_s.gsub /\//, ':'
      sensor = sensor.to_s.gsub /.rb$/, ''
      redis.publish "live:#{sensor}:#{key}", result
      redis.lpush "backlog:#{sensor}:#{key}", result
      redis.set "config:#{sensor}:#{key}", sensor_config
    end
  end
end

