# -*- ruby -*-

require 'bundler'
Bundler.require

require 'rake'
require 'rspec/core/rake_task'

task default: [:spec]

desc 'Run the code in specs'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/**/*_spec.rb"
end
