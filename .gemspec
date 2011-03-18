#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

GEMSPEC = Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = 'sparql-grammar'
  gem.homepage           = 'http://sparql.rubyforge.org/grammar/'
  gem.license            = 'Public Domain' if gem.respond_to?(:license=)
  gem.summary            = 'SPARQL lexer and parser for RDF.rb.'
  gem.description        = gem.summary
  gem.rubyforge_project  = 'sparql'

  gem.authors            = ['Gregg Kellogg', 'Arto Bendiken']
  gem.email              = 'public-rdf-ruby@w3.org'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS CREDITS README UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.bindir             = %q(bin)
  gem.executables        = %w(sparql sparql2sse)
  gem.default_executable = gem.executables.first
  gem.require_paths      = %w(lib)
  gem.extensions         = %w()
  gem.test_files         = %w()
  gem.has_rdoc           = false

  gem.required_ruby_version      = '>= 1.8.1'
  gem.requirements               = []
  gem.add_runtime_dependency     'rdf',           '>= 0.3.1'
  gem.add_runtime_dependency     'sxp',           '>= 0.0.14'
  gem.add_runtime_dependency     'sparql-algebra' '>= 0.0.6'
  gem.add_development_dependency 'yard' ,         '>= 0.6.0'
  gem.add_development_dependency 'rspec',         '>= 2.1.0'
  gem.add_development_dependency 'rdf-spec',      '>= 0.3.1'
  gem.add_development_dependency 'rdf-n3',        '>= 0.3.1'
  gem.add_development_dependency 'sparql-test',   '>= 0.0.1'
  gem.add_development_dependency 'spira',         '>= 0.0.12'
  gem.post_install_message       = nil
end
