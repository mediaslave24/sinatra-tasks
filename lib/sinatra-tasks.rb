require 'sinatra/base'
require 'haml'
require 'active_record'
require 'sinatra/namespace'
require 'sinatra/reloader' if Sinatra::Base.development?

begin
  require 'pry'
rescue LoadError
end

module SinatraTasks
  class Task < ActiveRecord::Base
    attr_accessible :title, :description, :pos, :done
    validates_presence_of :title

    default_scope  ->{ order("pos DESC").order("created_at DESC") }
    scope :done,   ->{ where(done: true) }
    scope :undone, ->{ where(done: false) }
  end

  class App < Sinatra::Base
    module ViewHelpers
      def opts_to_attr(*opts)
        opts.map{|k,v|
          %Q[#{k}="#{v}"]
        }.join(" ")
      end

      def url(_url)
        url = "/#{url}" if url.to_s[0] != '/'
        request.script_name + _url
      end

      def link (text, url, opts={})
        (opts[:class] = opts[:class] ? opts[:class].to_s + " active" : "active") if request.path == url
        %Q{<a href="#{opts.delete(:raw_url) ? url : url(url)}" #{opts_to_attr(*opts)}>#{text}</a>} 
      end

      def current_url?(url)
        request.path == url
      end
    end

    enable :inline_templates

    configure :development do
      register Sinatra::Reloader
      enable :reloader
    end

    configure :production do
      Task.establish_connection
    end

    configure :development, :test do
      Task.establish_connection("sqlite3:///sinatra-tasks-#{environment}.sqlite3")
    end

    helpers do
      def back
        env['HTTP_REFERER']
      end
      def task_class(task)
        klass = []
        klass.push "done", "muted" if task.done?
        klass.push "text-warning" if task.highlighted? && !task.done?
        klass.join(' ')
      end
      def public_file_path(basename, ext)
        File.join settings.public_folder, ext, basename
      end
    end
    helpers ViewHelpers

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
      when "highlight" then task.toggle!(:highlighted)
      when "title" then task.update_attribute(:title, params[:title])
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
      when "undone" then redirect(url('/'))
      when "all" then Task.all
      end
      haml :tasks, locals: { tasks: tasks }
    end
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
      = link "Tasks", "/", class: "brand"
      %ul.nav
        %li{class: ("active" if current_url?('/'))}
          = link "Undone", "/filter/undone"
        %li{class: ("active" if current_url?('/filter/all'))}
          = link "All", "/filter/all"
        %li{class: ("active" if current_url?('/filter/done'))}
          = link "Done", "/filter/done"
      %form.form-inline.top-form{action: url('/'), method: 'post'}
        %input{type: "text", name: "task[title]"}
        %input.btn.btn-primary{type: "submit", value: "Send"}
      -#%ul.pull-right.nav
        %li.dropdown
          %a.dropdown-toggle{href: "javascript:void(0);", "data-toggle" => "dropdown"} Action
          %ul.dropdown-menu
            %li
              %a{href: "javascript:void(0);", "data-confirm" => "Are you shure?"} Logout
@@ css
%link{href: url("/css/bootstrap.min.css"), type: "text/css", rel: "stylesheet"}
%link{href: url("/css/bootstrap-responsive.min.css"), type: "text/css", rel: "stylesheet"}
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
  .task h3 {
    cursor: pointer;
  }
  

@@ javascripts
%script{src: url("/js/jquery.min.js"), type: "text/javascript"}
%script{src: url("/js/bootstrap.min.js"), type: "text/javascript"}
%script{src: url("/js/knockout.min.js"), type: "text/javascript"}
%script{src: url("/js/underscore.min.js"), type: "text/javascript"}
%script{src: url("/js/app.js"), type: "text/javascript"}

@@ tasks
#tasks
  - tasks.each do |task|
    .task.dropdown
      %h3.dropdown-toggle{"data-toggle" => "dropdown", class: task_class(task) }= task.title
      %ul.dropdown-menu
        %li
          = link "Finish", "/change/done/#{task.id}"
        %li
          = link "Edit", "javascript:void(0);", "data-action" => "edit", "data-target" => "h3", "data-url" => url("/change/title/#{task.id}"), "data-name" => "title", raw_url: true
        %li
          = link "Highlight", "/change/highlight/#{task.id}"
        %li
          = link "Move Up", "/change/up/#{task.id}"
        %li
          = link "Move Down", "/change/down/#{task.id}"
        %li
          = link "Destroy", "/destroy/#{task.id}"
