require 'rubygems'
require 'sinatra'
require 'sinatra/cache'
require 'haml'
require 'sass' 
require 'heroku' 
require 'open-uri'
require 'nokogiri'

set :root, '/home/art/Projects/weathorr'
set :public, '/home/art/Projects/weathorr/public'
set :cache_output_dir, '/home/art/Projects/weathorr/system/cache'
set :cache_enabled, true
set :show_exceptions

class Conditions
  attr_accessor :tempf, :tempc, :chillf, :chillc, :clouds, :wind, :windspeed

  def initialize
    doc = open("public/data/KBOS.xml") do |f|
      Nokogiri::XML(f)
    end
    @tempf = (doc/"temp_f").inner_text
    @tempc = (doc/"temp_c").inner_text
    @chillf = (doc/"windchill_f").inner_text
    @chillc = (doc/"windchill_c").inner_text
    @clouds = (doc/"weather").inner_text
    @wind = (doc/"wind_dir").inner_text
    @windspeed = (doc/"wind_mph").inner_text
  end
end

class Forecast
  attr_accessor :summary

  def initialize
    f = File.open("public/data/sfo.forecast")
    doc = Nokogiri::HTML(f)
    index = 0
    @summary = ""
    doc.at_css("body").traverse do |node|
       if node.text?
         index += 1
         next if ( index < 4 )
         break if node.content == " &&"
    		 if node.content =~ /^ \./
           node.content = node.content.sub(/ .(.*)\.\.\./, '<span class="day">\1...</span>')
           node.content = node.content.sub(/^/, "\n<br>")
         end	
         @summary << node.content.downcase!
       end
    end
  end
end

get '/' do
  @cond = Conditions.new
  @forecast = Forecast.new
  haml :index
end

get '/style.css' do
  content_type "text/css", :charset => "utf-8"
  sass :style
end
