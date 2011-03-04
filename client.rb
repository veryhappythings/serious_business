require 'rubygems'
require 'sinatra'
require 'redis'
require 'yaml'

get '/' do
  redis = Redis.new
  sensors = {}
  redis.keys('backlog/sensors/*').each do |key|
    sensors[key] = redis.get key
  end
  sensors.to_yaml
end

