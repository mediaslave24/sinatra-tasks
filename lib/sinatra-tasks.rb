require 'sinatra/base'
require 'haml'
require 'active_record'
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
        klass.push "text-error" if task.highlighted? && !task.done?
        klass.join(' ')
      end
      def public_file_path(basename, ext)
        File.join settings.public_folder, ext, basename
      end
      def url(_url)
        url = "/" << _url if url.to_s[0] != '/'
        request.script_name + _url
      end
      def link (text, url, opts={})
        %Q{<a href="#{url(url)}" #{opts.map{|k,v|%Q[#{k}=#{v}]}.join(' ')} >#{text}</a>} 
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
      when "highlight" then task.toggle!(:highlighted)
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
        %li
          = link "Undone", "/filter/undone"
        %li
          = link "All", "/filter/all"
        %li
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
          = link "Highlight", "/change/highlight/#{task.id}"
        %li
          = link "Move Up", "/change/up/#{task.id}"
        %li
          = link "Move Down", "/change/down/#{task.id}"
        %li
          = link "Destroy", "/destroy/#{task.id}"
