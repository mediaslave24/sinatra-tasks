require 'rake'
require File.expand_path("../app.rb", __FILE__)
migrator = ActiveRecord::Migration

namespace :db do
  namespace :migrate do
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

    task :down do
      migrator.drop_table :tasks
    end
  end

  task :reset do
    begin
      Rake::Task[:"db:migrate:down"].invoke
    rescue StandardError
    end
    Rake::Task[:"db:migrate:up"].invoke
  end
end
