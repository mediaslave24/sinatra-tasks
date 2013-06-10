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

  helpers do
    def linkify(tasks, length = 3)
      tasks.map! { |task|
        title = task.title
        task.title = %Q{ <a href="javascript:void(0);">#{title[0,length]}</a>} << title[length..-1]
        task
      }
    end
    def back
      env['HTTP_REFERER']
    end
  end

  get '/' do
    tasks = Task.undone
    haml :tasks, locals: { tasks: tasks }
  end

  post '/' do
    Task.create(params[:task])
    redirect back
  end

  get '/change/:action/:id' do |action, id|
    task = Task.find(id) 
    case action
    when "up" then task.increment!(:pos)
    when "down" then  task.decrement!(:pos)
    when "done" then task.toggle!(:done)
    end
    redirect back
  end

  get "/destroy/:id" do |id|
    task = Task.find(id).destroy
    redirect back
  end

  get "/filter/:cond" do |cond|
    tasks = case cond
    when "done" then Task.done
    when "undone" then redirect('/')
    when "all" then Task.all
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
  .done {
    text-decoration: line-through;
  }
  

@@ javascripts
%script{src: "/js/jquery.min.js", type: "text/javascript"}
%script{src: "/js/bootstrap.min.js", type: "text/javascript"}
%script{src: "/js/app.js", type: "text/javascript"}

@@ tasks
#tasks
  - linkify(tasks).each do |task|
    .task.dropdown
      %h3.dropdown-toggle{"data-toggle" => "dropdown", class: ("done muted" if task.done?) }= task.title
      %ul.dropdown-menu
        %li
          %a{href: "/change/done/#{task.id}"} Finish
        %li
          %a{href: "/change/up/#{task.id}"} Move Up
        %li
          %a{href: "/change/down/#{task.id}"} Move Down
        %li
          %a{href: "/destroy/#{task.id}"} Destroy
