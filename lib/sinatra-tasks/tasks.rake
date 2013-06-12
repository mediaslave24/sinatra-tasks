require 'rake'
require 'sinatra-tasks'
require 'pry'

migrator = ActiveRecord::Migration.new
def migrator.connection
  @connection || SinatraTasks::Task.connection
end

namespace :db do
  namespace :migrate do
    desc "Migrate up"
    task :up do
      migrator.create_table :tasks do |t|
        t.string :title
        t.text :description
        t.boolean :done, default: false
        t.integer :pos, default: 0
        t.boolean :highlighted, default: false
        t.timestamps
      end
    end

    desc "Migrate down"
    task :down do
      migrator.drop_table :tasks
    end
  end

  desc "Migrate down and up"
  task :reset do
    begin
      Rake::Task[:"db:migrate:down"].invoke
    rescue StandardError
    end
    Rake::Task[:"db:migrate:up"].invoke
  end
end
