require 'sinatra/base'
require 'sinatra/reloader'
require 'haml'
require File.expand_path('./ruby/griddable')
require File.expand_path("./ruby/twitter")
require "pry"

class App < Sinatra::Base
  enable :inline_templates
  register Sinatra::Reloader
  enable :reloader
  set :public_dir, File.dirname(__FILE__)
  helpers do
    def get_grids(fname)
      Marshal.load(IO.read(%Q{./#{fname}.marshal}))
    end
  end

  before do
    system("coffee -c .")
  end

  get '/' do
    @grids = get_grids "grid-bulgaria"
    haml ""
  end
end

__END__
@@ layout
!!!
%html
  %head
  %body
    #map-canvas{style: "width: 900px; height: 600px;"}

    %script{type: "text/javascript", src: "https://maps.googleapis.com/maps/api/js?key=AIzaSyBfCvgH3uq19q9kywAa2Xj3vHR3GuT9R64&sensor=false"}
    :javascript
      var grids = #{@grids.to_json};
    %script{type: "text/javascript", src: "app.js"}
