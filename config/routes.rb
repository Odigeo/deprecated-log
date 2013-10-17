Log::Application.routes.draw do

  scope "/v1" do
  	post   "log_excerpts"           => "log_excerpts#create"
    get    "log_excerpts/:from/:to" => "log_excerpts#show"
    delete "log_excerpts/:from/:to" => "log_excerpts#destroy"
  end

end
