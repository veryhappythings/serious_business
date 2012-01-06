require 'rubygems'
require 'sinatra'
require 'redis'
require 'haml'

require 'json'

def get_list(redis, key, options={})
  [].tap do |array|
    unless options[:length] && redis.llen(key) > options[:length]
      options[:length] = redis.llen(key)
    end

    (0..options[:length]-1).each do |i|
      array << redis.lindex(key, i)
    end
  end.reverse
end

def get_json_sensors
  redis = Redis.new
  sensors = {}
  redis.keys('backlog:sensors:*').each do |key|
    sensors[key] = get_list redis, key, :length => 10
  end
  sensors.to_json
end

get '/' do
  @sensors = get_json_sensors
  haml :index
end

get '/big_numbers' do
  @sensors = get_json_sensors
  haml :big_numbers
end

get '/demo' do
  erb :demo
end

get '/alerts' do
  @sensors = get_json_sensors
  haml :alerts
end
