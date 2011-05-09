require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass' 
require 'heroku' 
require 'hpricot' 
require 'open-uri'
require 'nokogiri'

get '/' do
  doc = open("public/data/KBOS.xml") do |f|
    Nokogiri::XML(f)
  end
  @temp1 = (doc/"temp_f").inner_text
  @temp2 = (doc/"temp_c").inner_text
  @chill1 = (doc/"windchill_f").inner_text
  @chill2 = (doc/"windchill_c").inner_text
  @clouds = (doc/"weather").inner_text
  @wind = (doc/"wind_dir").inner_text
  @windspeed = (doc/"wind_mph").inner_text

  f = File.open("public/data/sfo.forecast")
  doc = Nokogiri::HTML(f)
  index = 0
  text = ""
  doc.at_css("body").traverse do |node|
     if node.text?
       index += 1
       next if ( index < 4 )
       break if node.content == " &&"
  		 if node.content =~ /^ \./
         node.content = node.content.sub(/ .(.*)\.\.\./, '<span class="day">\1...</span>')
         node.content = node.content.sub(/^/, "\n<br>")
       end	
       text << node.content.downcase!
     end
  end

  @forecast = text

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
