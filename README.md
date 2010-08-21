SPARQL Parser for RDF.rb
========================

This is a pure-Ruby implementation of a [SPARQL][] lexer and parser for
[RDF.rb][]. (Currently in pre-alpha state.)

* <http://github.com/bendiken/sparql-grammar>

Features
--------

* Implements a complete lexical analyzer for the [SPARQL 1.0][]
  [grammar][] (a full parser is in the works).
* Compatible with Ruby 1.8.7+, Ruby 1.9.x, and JRuby 1.4/1.5.
* Supports Unicode query strings both on Ruby 1.8.x and 1.9.x.

Examples
--------

    require 'rubygems'
    require 'sparql/grammar'

### Tokenizing a SPARQL query string

    lexer = SPARQL::Grammar.tokenize("SELECT * WHERE { ?s ?p ?o }")
    lexer.each_token do |token|
      puts token.inspect
    end

Documentation
-------------

<http://sparql.rubyforge.org/grammar/>

* {SPARQL::Grammar}

Dependencies
------------

* [Ruby](http://ruby-lang.org/) (>= 1.8.7) or (>= 1.8.1 with [Backports][])
* [RDF.rb](http://rubygems.org/gems/rdf) (>= 0.2.0)

Installation
------------

The recommended installation method is via [RubyGems](http://rubygems.org/).
To install the latest official release of the `SPARQL::Grammar` gem, do:

    % [sudo] gem install sparql-grammar

Download
--------

To get a local working copy of the development repository, do:

    % git clone git://github.com/bendiken/sparql-grammar.git

Alternatively, you can download the latest development version as a tarball
as follows:

    % wget http://github.com/bendiken/sparql-grammar/tarball/master

Authors
-------

* [Arto Bendiken](mailto:arto.bendiken@gmail.com) - <http://ar.to/>

License
-------

`SPARQL::Grammar` is free and unencumbered public domain software. For more
information, see <http://unlicense.org/> or the accompanying UNLICENSE file.

[RDF]:        http://www.w3.org/RDF/
[SPARQL]:     http://en.wikipedia.org/wiki/SPARQL
[SPARQL 1.0]: http://www.w3.org/TR/rdf-sparql-query/
[SPARQL 1.1]: http://www.w3.org/TR/sparql11-query/
[grammar]:    http://www.w3.org/TR/rdf-sparql-query/#grammar
[RDF.rb]:     http://rdf.rubyforge.org/
[Backports]:  http://rubygems.org/gems/backports
