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

get '/' do
  redis = Redis.new
  sensors = {}
  redis.keys('backlog/sensors/*').each do |key|
    sensors[key] = get_list redis, key, :length => 10
  end
  @sensors = sensors.to_json
  haml :index
end

