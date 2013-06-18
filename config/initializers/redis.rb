
$redis = Redis.new(driver: :hiredis, 
                   host: LOG_REDIS_NODE,
                   port: 6379)
