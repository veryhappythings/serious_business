require 'rubygems'
require 'logger'
require 'redis'

log = Logger.new(STDOUT)
log.level = Logger::DEBUG

redis = Redis.new

while 1 do
  Dir.glob(File.join('sensors', '*')).each do |sensor|
    log.info "Running #{sensor}"
    output = %x[#{sensor}]
    log.info "Received output:"
    log.info output.chomp
    redis.publish sensor, output
  end
  sleep(20)
end

