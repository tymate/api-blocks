# frozen_string_literal: true

require "rubygems"
require "bundler/gem_tasks"
require "rake/testtask"
require "yard"
require "rubocop/rake_task"

RuboCop::RakeTask.new

YARD::Rake::YardocTask.new do |t|
  t.files = ["lib/**/*.rb"]
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task default: :test
