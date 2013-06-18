#
# The path /alive is implemented solely for the benefit of Varnish,
# which is set up to use it for health checking. Due to the routing
# implemented in Varnish, /alive can never be reached from the outside.
#

class AliveController < ApplicationController
  
  skip_before_filter :require_x_api_token
  skip_before_filter :authorize_action


  def index
    # Call the DB to ensure it too is healthy
    $redis.zcard 'log'
    # Render the reply
    render :text => "ALIVE", :status => 200
  end
  
end
