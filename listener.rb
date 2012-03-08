require 'rubygems'
require 'redis'

redis = Redis.new

redis.psubscribe('live:*') do |on|
  on.psubscribe do |channel, subscriptions|
    puts "Subscribed to #{channel} (#{subscriptions} subscriptions)"
  end

  on.pmessage do |pchannel, channel, message|
    puts "#{pchannel}, #{channel}: #{message}"
    redis.unsubscribe if message == "exit"
  end

  on.punsubscribe do |channel, subscriptions|
    puts "Unsubscribed from #{channel} (#{subscriptions} subscriptions)"
  end
end

