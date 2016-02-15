require 'rubygems'
require 'sinatra'
require 'sinatra/cache'
require 'haml'
require 'sass' 
require 'heroku' 
require 'open-uri'
require 'nokogiri'

set :root, '/var/www/weathorr'
set :public, '/var/www/weathorr/public'
set :cache_output_dir, '/var/www/weathorr/system/cache'
set :cache_enabled, true
set :show_exceptions

class Conditions
  attr_accessor :tempf, :tempc, :chillf, :chillc, :clouds, :wind, :windspeed, :mosaic, :single, :header

  def initialize(city)
    cities = { "sfo"    =>  {:conditions => "KSFO.xml",
                             :mosaic => {:src    => "http://radar.weather.gov/Conus/Loop/pacsouthwest_loop.gif",
				         :alt    => "radar loop",
				         :width  => "300",
				         :height => "285"},
                              :single => {:src    => "http://www.srh.noaa.gov/ridge/lite/N0R/MUX_loop.gif",
				         :alt    => "radar loop", 
				         :width  => "300",
				         :height => "275"},
                              :pretty => "San Francisco"},
               "chicago" => {:conditions => "KMDW.xml",
                             :mosaic => {:src    => "http://radar.weather.gov/Conus/Loop/centgrtlakes_loop.gif",
				         :alt    => "radar loop",
				         :width  => "300",
				         :height => "285"},
                             :single => {:src    => "http://www.srh.noaa.gov/ridge/lite/N0R/LOT_loop.gif",
				         :alt    => "radar loop", 
				         :width  => "300",
				         :height => "275"},
                              :pretty => "Chicago"}    
      }
    begin
      f = File.open("/var/www/weathorr/public/data/#{cities[city][:conditions]}")
    rescue EOFError
    rescue IOError => e
      puts e.exception
    rescue Errno::ENOENT
      puts "no such file #{f}"
    end
    doc =  Nokogiri::XML(f)
    @tempf = (doc/"temp_f").inner_text
    @tempc = (doc/"temp_c").inner_text
    @chillf = (doc/"windchill_f").inner_text
    @chillc = (doc/"windchill_c").inner_text
    @clouds = (doc/"weather").inner_text
    @wind = (doc/"wind_dir").inner_text
    @windspeed = (doc/"wind_mph").inner_text
    @mosaic = cities[city][:mosaic]
    @single = cities[city][:single]
    pretty = cities[city][:pretty]
    @header = "#{pretty} - "
    cities.keys.each do |x|
      @header += "<a href=/city/#{x}>#{cities[x][:pretty]}</a>" unless x == city
    end
  end
end

class Forecast
  attr_accessor :summary

  def initialize(city)
    cities = { "sfo" => "sfo.forecast",
               "chicago" => "mdw.forecast"  
	    }
    f = File.open("/var/www/weathorr/public/data/#{cities[city]}")
    @summary = ""
    if city == "sfo"
      doc = Nokogiri::HTML(f)
      index = 0
      @summary = "NWS San Francisco Peninsula Forecast -- "
      doc.at_css("body").traverse do |node|
        if node.text?
          index += 1
          next if ( index < 4 )
          break if node.content == " &&"
          if node.content =~ /^ \./
            node.content = node.content.sub(/ .(.*)\.\.\./, '<span class="day">\1...</span>')
            node.content = node.content.sub(/^/, "\n<br>")
          end
          @summary << node.content.downcase
        end
      end
    elsif city == "chicago"
        @summary = " NWS Chicago Forecast --"
	contents = f.read
	@summary << contents
    end
  end
end

get '/' do
  city = "sfo"
  redirect "/city/#{city}"
end

get '/city/:city' do
  cities={"sfo" => 1,"chicago" => 1}
  halt 404 unless cities[params[:city]]
  @cond = Conditions.new(params[:city])
  @forecast = Forecast.new(params[:city])
  haml :index
end

get '/city/?' do
  redirect '/'
end

get '/style.css' do
  content_type "text/css", :charset => "utf-8"
  sass :style
end

not_found do
  haml :wtf
end

error do
  haml :wtf
end
