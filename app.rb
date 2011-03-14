%w[rubygems sinatra haml sass heroku].each{ |gem| require gem }

get('/'){ haml :index }
get '/style.css' do
  content_type "text/css", :charset => "utf-8"
  sass :style
end
get('/response'){ "Hello from the server" }
get('/time'){ "The time is " + Time.now.to_s }
post('/reverse'){ params[:word].reverse }

__END__
