SPARQL Lexer and Parser for RDF.rb
==================================

This is a [Ruby][] implementation of a [SPARQL][] lexer and parser for
[RDF.rb][]. (Currently in pre-alpha state.)

* <http://github.com/bendiken/sparql-grammar>

Features
--------

* 100% free and unencumbered [public domain](http://unlicense.org/) software.
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
  * {SPARQL::Grammar::Parser}
  * {SPARQL::Grammar::Lexer}

Dependencies
------------

* [Ruby](http://ruby-lang.org/) (>= 1.8.7) or (>= 1.8.1 with [Backports][])
* [RDF.rb](http://rubygems.org/gems/rdf) (>= 0.3.0)

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

Author
------

* [Arto Bendiken](mailto:arto.bendiken@gmail.com) - <http://ar.to/>

Contributors
------------

Refer to the accompanying {file:CREDITS} file.

Contributing
------------

* Do your best to adhere to the existing coding conventions and idioms.
* Don't use hard tabs, and don't leave trailing whitespace on any line.
* Do document every method you add using [YARD][] annotations. Read the
  [tutorial][YARD-GS] or just look at the existing code for examples.
* Don't touch the `.gemspec`, `VERSION` or `AUTHORS` files. If you need to
  change them, do so on your private branch only.
* Do feel free to add yourself to the `CREDITS` file and the corresponding
  list in the the `README`. Alphabetical order applies.
* Do note that in order for us to merge any non-trivial changes (as a rule
  of thumb, additions larger than about 15 lines of code), we need an
  explicit [public domain dedication][PDD] on record from you.

License
-------

This is free and unencumbered public domain software. For more information,
see <http://unlicense.org/> or the accompanying {file:UNLICENSE} file.

[Ruby]:       http://ruby-lang.org/
[RDF]:        http://www.w3.org/RDF/
[SPARQL]:     http://en.wikipedia.org/wiki/SPARQL
[SPARQL 1.0]: http://www.w3.org/TR/rdf-sparql-query/
[SPARQL 1.1]: http://www.w3.org/TR/sparql11-query/
[grammar]:    http://www.w3.org/TR/rdf-sparql-query/#grammar
[RDF.rb]:     http://rdf.rubyforge.org/
[YARD]:       http://yardoc.org/
[YARD-GS]:    http://rubydoc.info/docs/yard/file/docs/GettingStarted.md
[PDD]:        http://unlicense.org/#unlicensing-contributions
[Backports]:  http://rubygems.org/gems/backports
