#
# The directory RUN_TIME_DIR must already exist, and this process
# must have the right to create files in it.
#

require 'rubygems'
require 'daemons'
require 'ffi-rzmq'
load 'config/initializers/log_redis_node.rb'
load 'lib/zero_log_to_redis.rb'

# The number of log workers to keep running at all times
N_WORKERS = 5

# Run time directory
RUN_TIME_DIR = "/var/run/zeromq_logger"

# Ipc socket path
IPC_PULL_SERVER_SOCKET_PATH = "ipc://#{RUN_TIME_DIR}/pull_worker.ipc"


options = {
  dir_mode: :normal,
  dir: RUN_TIME_DIR,
  backtrace: true,
  log_output: false,
  multiple: false,
  monitor: true
}

# The pull server, one per machine instance
Daemons.run_proc("server", options) do
  ZeroLog.new.pull_server(IPC_PULL_SERVER_SOCKET_PATH)
end

# The log workers
(0...N_WORKERS).each do |i| 
  Daemons.run_proc("worker_#{i}", options) do
    ZeroLogToRedis.new.pull_worker(IPC_PULL_SERVER_SOCKET_PATH)
  end
end

# A daemon to remove log entries older than a month (one per machine instance)
Daemons.run_proc("purger", options) do
  ZeroLogToRedis.new.purger
end
