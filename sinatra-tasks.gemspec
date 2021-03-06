# encoding:utf-8

Gem::Specification.new do |gem|
  gem.name         = "sinatra-tasks"
  gem.version      = "0.2.5"

  gem.description  = "Simple task manager with sinatra."
  gem.summary      = gem.description
  gem.homepage     = "https://github.com/mediaslave24/sinatra-tasks"

  gem.authors      = ["Michael Lutsiuk"]
  gem.email        = "mmaccoffe@gmail.com"

  gem.license      = "MIT"

  gem.files        = Dir["lib/**/*"] + ["README.md"]
  gem.require_path = "lib"

  gem.required_ruby_version = ">= 1.9.2"

  gem.add_dependency "sinatra"
  gem.add_dependency "sinatra-contrib"
  gem.add_dependency "haml"
  gem.add_dependency "activerecord", "~> 3.2"
  gem.add_dependency "rake"

  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "pry"
end
