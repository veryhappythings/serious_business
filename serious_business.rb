#!/usr/bin/env ruby

require 'rubygems'
require 'date'
require 'thread'
require 'logger'
require 'json'
require 'redis'
require 'pathname'

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
business_path = Pathname.new(File.dirname(__FILE__))
Dir.glob(File.join(File.dirname(__FILE__), 'sensors', sensors, '**', '*.rb')).each do |sensor|
  unless File.directory? sensor
    date = DateTime.now

    sensor_name = Pathname.new(sensor).relative_path_from(business_path).to_s

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
      sensor_config = (config.has_key?(key) ? config[key] : {})
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

      sensor_name = sensor_name.to_s.gsub /\//, ':'
      sensor_name = sensor_name.to_s.gsub /.rb$/, ''
      redis.publish "live:#{sensor_name}:#{key}", result
      redis.lpush "backlog:#{sensor_name}:#{key}", result
      redis.set "config:#{sensor_name}:#{key}", sensor_config.to_json
    end
  end
end

