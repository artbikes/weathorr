require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass' 
require 'heroku' 
require 'hpricot' 
require 'open-uri'

get '/' do
  doc = open("public/data/KBOS.xml") do |f|
    Hpricot.XML(f)
  end
  @temp1 = (doc/"temp_f").inner_html
  @temp2 = (doc/"temp_c").inner_html
  @chill1 = (doc/"windchill_f").inner_html
  @chill2 = (doc/"windchill_c").inner_html
  @clouds = (doc/"weather").inner_html
  @wind = (doc/"wind_dir").inner_html
  @windspeed = (doc/"wind_mph").inner_html
   
  haml :index
end
get '/style.css' do
  content_type "text/css", :charset => "utf-8"
  sass :style
end
get('/response'){ "Hello from the server" }
get('/time'){ "The time is " + Time.now.to_s }
post('/reverse'){ params[:word].reverse }

__END__
