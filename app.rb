%w[rubygems sinatra haml heroku].each{ |gem| require gem }

get('/'){ haml :index }
get('/response'){ "Hello from the server" }
get('/time'){ "The time is " + Time.now.to_s }
get('/reverse'){ params[:word].reverse }
