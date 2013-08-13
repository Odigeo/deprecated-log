
require 'redis'
require 'json'

#
# This class overloads the ZeroLog#pull_worker to store received
# data in Redis.
#
class ZeroLogToRedis < ZeroLog

  def pull_worker(address=PUSH_ADDRESS)
  	#puts "Starting PULL worker"
  	puller = context.socket(ZMQ::PULL)
  	#puts "Connect to the PUSH socket"
    puller.connect(address)
    trap_int(puller)
    #puts "Initialising the Redis client"
    redis = Redis.new(driver: :hiredis, 
                       host: LOG_REDIS_NODE,
                       port: 6379)

    #puts "Entering work loop..."
  	while true do
  	  s = ''
  	  puller.recv_string(s)
  	  j = JSON.parse(s) #rescue next
  	  timestamp = j['timestamp']
      redis.zadd "log", timestamp, s
  	end
  end
  
  
  #
  # Remove log entries older than a month. Do this once a day.
  #
  def purger
    #puts "Initialising the Redis client (server: #{LOG_REDIS_NODE})"
    redis = Redis.new(driver: :hiredis, 
                      host: LOG_REDIS_NODE,
                      port: 6379)
    #puts "Entering the work loop"
    while true do
      one_month_ago = ((Time.now.utc.to_f - 2592000.0) * 1000).to_i
      redis.zremrangebyscore "log", 0, one_month_ago
      sleep 86400 # Sleep for a day
    end
  end

end
