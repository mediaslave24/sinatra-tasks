require 'sinatra/base'
require 'haml'
require 'active_record'

if Sinatra::Base.development?
  require 'sinatra/reloader' 
  require 'pry'
end

class Task < ActiveRecord::Base
  attr_accessible :title, :description, :pos, :done
  validates_presence_of :title

  default_scope  ->{ order("pos DESC").order("created_at DESC") }
  scope :done,   ->{ where(done: true) }
  scope :undone, ->{ where(done: false) }
end

class Tasks < Sinatra::Base
  enable :inline_templates

  configure :development do
    register Sinatra::Reloader
    enable :reloader
  end

  configure :production do
    ActiveRecord::Base.establish_connection
  end

  configure :development, :test do
    ActiveRecord::Base.establish_connection("sqlite3:///sinatra-tasks-#{environment}.sqlite3")
  end

  get '/' do
    tasks = Task.all
    haml :tasks, locals: { tasks: tasks }
  end

  post '/' do
    Task.create(params[:task])
    redirect '/'
  end

  get "/filter/:cond" do |cond|
    tasks = case cond
    when "done" then Task.done
    when "undone" then Task.undone
    when "all" then redirect('/')
    end
    haml :tasks, locals: { tasks: tasks }
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
    .container
      = yield
    = haml :javascripts

@@ nav
.container
  .navbar
    .navbar-inner.topnav
      %a.brand{href: "/"} Tasks
      %ul.nav
        %li
          %a{href: "/filter/undone"} Undone
        %li
          %a{href: "/filter/all"} All
        %li
          %a{href: "/filter/done"} Done
      %form.form-inline.top-form{method: 'post'}
        %input{type: "text", name: "task[title]"}
        %input.btn.btn-primary{type: "submit", value: "Send"}
      %ul.pull-right.nav
        %li.dropdown
          %a.dropdown-toggle{href: "javascript:void(0);", "data-toggle" => "dropdown"} Action
          %ul.dropdown-menu
            %li
              %a{href: "javascript:void(0);", "data-confirm" => "Are you shure?"} Logout
@@ css
%link{href: "/css/bootstrap.min.css", type: "text/css", rel: "stylesheet"}
%link{href: "/css/bootstrap-responsive.min.css", type: "text/css", rel: "stylesheet"}
:css
  .top-form {
    display: inline-block;
  }
  .top-form input[type=text] {
    margin-top:6px;
  }
  .topnav {
    height: 50px;
  }
  

@@ javascripts
%script{src: "/js/jquery.min.js", type: "text/javascript"}
%script{src: "/js/bootstrap.min.js", type: "text/javascript"}
%script{src: "/js/app.js", type: "text/javascript"}

@@ tasks
#tasks
  - tasks.each do |task|
    .task
      %h3= task.title
