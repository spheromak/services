require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rdoc/task"

task default: 'test:quick'


RDoc::Task.new do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_files.include("lib   /*.rb")
end

namespace :test do
  RSpec::Core::RakeTask.new("spec") do |t|
    t.rspec_opts = '--color --fail-fast'
  end

  begin
    require 'rubocop/rake_task'
    RuboCop::RakeTask.new do |task|
      task.fail_on_error = true
    end
  rescue LoadError
    warn 'Rubocop gem not installed, now the code will look like crap!'
  end

  desc 'Run all of the quick tests.'
  task :quick do
    Rake::Task['test:rubocop'].invoke
    Rake::Task['test:spec'].invoke
  end
end
