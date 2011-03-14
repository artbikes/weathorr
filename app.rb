%w[rubygems sinatra haml heroku].each{ |gem| require gem }

get('/'){ haml :index }
get('/response'){ "Hello from the server" }
get('/time'){ "The time is " + Time.now.to_s }
post('/reverse'){ params[:word].reverse }

__END__
@@layout
!!! 5
%script(src="http://rightjs.org/hotlink/right.js")
%script(src="/custom.js")
%html
  %head
    %meta(charset="utf-8")
    %title Sinatra Ajax
  %body
    %h1 Sinatra Ajax
    = yield

@@index
%h2 The Amazing Toggling Title
%h2 and his Sidekick
%form#reverse(action="/reverse" method="POST")
  %input#word(type="text" name="word")
  %input(type="submit" value="Reverse")
%ul
  %li <a id="server" href="/response">Call server-side Function</a>
  %li <a id="time" href="/time">Get the time</a>
  %li <a id="amazing" href="#">Toggle Title</a>
#msg
