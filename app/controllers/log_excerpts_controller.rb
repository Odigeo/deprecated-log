class LogExcerptsController < ApplicationController
  
  def show
    @from = params[:from].to_i
    @to = params[:to].to_i
    to = @to.to_f / 1000.0
    # Cache the response if it's entirely in the past
    expires_in 0, 's-maxage' => 1.hour if to < Time.now.utc.to_f
    count = $redis.zcount "log", "(#{@from}", @to
    # Use the count in the ETag to cover cases where delayed log entries
    # make it into the database after a prolonged wait.
    if stale?(etag: "log_excerpt:#{count}:#{@from}:#{@to}")
      # Do long polling if no entries (yet)  exist, the query arg is there, 
      # and @to is in the future
      if count == 0 && params[:long_polling] == 'true' && to > Time.now.utc.to_f
        @entries = $redis.zrangebyscore "log", "(#{@from}", @to
        while @entries == [] do
          sleep 0.5
          @entries = $redis.zrangebyscore "log", "(#{@from}", @to
        end
      else
        # No long polling, just get the excerpt
        @entries = $redis.zrangebyscore "log", "(#{@from}", @to
      end
    end
    # Return the data
    @entries
  end

  
  def destroy
    @from = params[:from].to_i
    @to = params[:to].to_i
    $redis.zremrangebyscore "log", "(#{@from}", @to
    render_head_204
  end


  def create
    # Check that all mandatory parameters are present
    errors = {}
    ["timestamp", "ip", "pid", "service", "level", "msg"].each do |param|
      errors[param] = ["must be present"] unless params[param]
    end
    ["timestamp", "pid", "level"].each do |param|
      next if params[param].to_i.to_s == params[param]
      errors[param] ||= []
      errors[param] << "must be an integer"
    end
    ["ip", "service", "msg"].each do |param|
      next if params[param].is_a?(String)
      errors[param] ||= []
      errors[param] << "must be a string"
    end
    render json: errors, status: 422 and return unless errors.blank?
    # Create an entry in Redis
    timestamp = params['timestamp'] = params['timestamp'].to_i
    params.delete("controller")
    params.delete("action")
    params['pid'] = params['pid'].to_i
    params['level'] = params['level'].to_i
    $redis.zadd "log", timestamp, params.to_json
    # Return a 204 (HEAD)
    render_head_204
  end
  
end
