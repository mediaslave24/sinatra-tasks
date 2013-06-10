require 'sinatra/base'
require 'haml'

if Sinatra::Base.development?
  require 'sinatra/reloader' 
  require 'pry'
end

class Tasks < Sinatra::Base
  enable :inline_templates

  configure :development do
    register Sinatra::Reloader
    enable :reloader
  end

  get '/' do
    haml ""
  end
end

__END__
@@ layout
!!!
%html
  %head
    = haml :css
  %body
    = haml :nav
    = haml :javascripts

@@ nav
.container
  .navbar
    .navbar-inner
      %a.brand{href: "/"} Tasks
      %ul.nav
        %li
          %a{href: "javascript:void(0);"} Undone
        %li
          %a{href: "javascript:void(0);"} All
        %li
          %a{href: "javascript:void(0);"} Done
      %ul.pull-right.nav
        %li.dropdown
          %a.dropdown-toggle{href: "javascript:void(0);", "data-toggle" => "dropdown"} Action
          %ul.dropdown-menu
            %li
              %a{href: "javascript:void(0);", "data-confirm" => "Are you shure?"} Logout
@@ css
%link{href: "/css/bootstrap.min.css", type: "text/css", rel: "stylesheet"}
%link{href: "/css/bootstrap-responsive.min.css", type: "text/css", rel: "stylesheet"}

@@ javascripts
%script{src: "/js/jquery.min.js", type: "text/javascript"}
%script{src: "/js/bootstrap.min.js", type: "text/javascript"}
%script{src: "/js/app.js", type: "text/javascript"}
