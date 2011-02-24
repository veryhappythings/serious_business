require 'rubygems'
require 'redis'

redis = Redis.new

while 1 do
  Dir.glob(File.join('sensors', '*')).each do |sensor|
    puts "Running #{sensor}"
    output = %x[#{sensor}]
    puts "Received output:"
    puts output
    redis.publish sensor, output
  end
  sleep(20)
end

