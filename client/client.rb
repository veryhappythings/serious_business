require 'rubygems'
require 'sinatra'
require 'redis'
require 'haml'

require 'json'

def get_list(redis, key)
  [].tap do |array|
    (0..redis.llen(key)-1).each do |i|
      array << redis.lindex(key, i)
    end
  end
end

get '/' do
  redis = Redis.new
  sensors = {}
  redis.keys('backlog/sensors/*').each do |key|
    sensors[key] = get_list redis, key
  end
  @sensors = sensors.to_json
  haml :index
end

