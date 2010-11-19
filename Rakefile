#!/usr/bin/env ruby
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))
require 'rubygems'
begin
  require 'rakefile' # @see http://github.com/bendiken/rakefile
rescue LoadError => e
end

require 'sparql/grammar'

desc "Build the sparql-grammar-#{File.read('VERSION').chomp}.gem file"
task :build do
  sh "gem build .gemspec"
end
