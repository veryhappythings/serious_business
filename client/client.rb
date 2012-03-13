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
      array << JSON.parse(redis.lindex(key, i))
    end
  end.reverse
end

def get_config(redis, key)
  JSON.parse(redis.get(key.gsub(/^backlog/, 'config')))
end

def get_json_sensors
  redis = Redis.new
  sensors = {}
  redis.keys('backlog:sensors:*').each do |key|
    sensors[key] = {
      'values' => get_list(redis, key, :length => 10),
      'config' => get_config(redis, key)
    }
  end
  sensors.to_json
end

get '/' do
  @sensors = get_json_sensors
  haml :index
end

get '/sensors' do
  content_type :json
  get_json_sensors
end

get '/graphs' do
  @sensors = get_json_sensors
  haml :graphs
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
