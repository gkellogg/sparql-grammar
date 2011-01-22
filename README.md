SPARQL Lexer and Parser for RDF.rb
==================================

This is a [Ruby][] implementation of a [SPARQL][] lexer and parser for
[RDF.rb][]. (Currently in pre-alpha state.)

* <http://github.com/bendiken/sparql-grammar>

Features
--------

* 100% free and unencumbered [public domain](http://unlicense.org/) software.
* Implements a complete parser for the [SPARQL 1.0][]
  [grammar][].
* Generates SPARQL S-Expressions [SSE][] syntax, and implemented in the [SXP][] library for Ruby.
* Compatible with Ruby 1.8.7+, Ruby 1.9.x, and JRuby 1.4/1.5.
* Supports Unicode query strings both on Ruby 1.8.x and 1.9.x.

Examples
--------

    require 'rubygems'
    require 'sparql/grammar'

### Parsing a SPARQL query string

    syntax_tree = SPARQL::Grammar.parse("SELECT * WHERE { ?s ?p ?o }")
    syntax_tree.to_sse

### Command line processing
    sparql2sse input.rq
    sparql2sse -e "SELECT * WHERE { ?s ?p ?o }"

Documentation
-------------

<http://sparql.rubyforge.org/grammar/>

* {SPARQL::Grammar}
  * {SPARQL::Grammar::Parser}
  * {SPARQL::Grammar::Lexer}

Implementation Notes
--------------------
The parser is driven through a rules table contained in lib/sparql/grammar/parser/meta.rb. This includes
branch rules to indicate productions to be taken based on a current production.

The meta.rb file is generated from etc/sparql-selectors.n3 which is the result of parsing
http://www.w3.org/2000/10/swap/grammar/sparql.n3 (along with bnf-token-rules.n3) using cwm using the following command sequence:

    cwm ../grammar/sparql.n3 bnf-token-rules.n3 --think --purge --data > sparql-selectors.n3

sparql-selectors.n3 is itself used to generate lib/sparql/grammar/parser/meta.rb using script/build_meta.

Note that The SWAP version of sparql.n3 is an older version of the grammar with the newest in http://www.w3.org/2001/sw/DataAccess/rq23/parsers/sparql.ttl,
which uses the EBNF form. Sparql.n3 file has been updated by hand to be consistent with the etc/sparql.ttl version.
A future direction will be to generate rules from etc/sparql.ttl to generate branch tables similar to those
expressed in meta.rb, but this requires rules not currently available.

Next Steps for Parsing EBNF
---------------------------
A more modern approach is to use the EBNF grammar (e.g., etc/sparql.bnf) to generate a Turtle/N3 representation of the grammar, transform
this to and LL1 representation and use this to create meta.rb.

Using SWAP utilities, this would seemingly be done as follows:

    python http://www.w3.org/2000/10/swap/grammar/ebnf2turtle.py \
      http://www.w3.org/2001/sw/DataAccess/rq23/parsers/sparql.bnf \
      en \
      'http://www.w3.org/2001/sw/DataAccess/parsers/sparql#' > etc/sparql.ttl
      
    python http://www.w3.org/2000/10/swap/cwm.py etc/sparql.ttl \
      http://www.w3.org/2000/10/swap/grammar/ebnf2bnf.n3 \
      http://www.w3.org/2000/10/swap/grammar/first_follow.n3 \
      --think --data > etc/sparql-ll1.n3
      
At this point, a variation of script/build_meta should be able to extract first/follow information to re-create the meta branch tables.

SPARQL S-Expressions [SSE][]
--------------------------
The SSE generated closely follows that of [OpenJena ARQ](http://openjena.org/ARQ/), which is intended principally for
running the SPARQL rules. However, this syntax does not transform all of the semantic content of a SPARQL query. In particular:

* CONSTRUCT, ASK, and DESCRIBE operate no differently than SELECT.
* Dataset operators are ignored.

The following table illustrates example SPARQL transformations:

<table border="1">
  <tr><th>SPARQL</th><th>SSE</th></tr>
  <tr><td>
    SELECT * WHERE { ?a ?b ?c }
  </td><td>
    (bgp (triple ?a ?b ?c))
  </td></tr>
  <tr><td>
    SELECT * FROM <a> WHERE { ?a ?b ?c }
  </td><td>
    (bgp (triple ?a ?b ?c))
  </td></tr>
  <tr><td>
    SELECT * FROM NAMED <a> WHERE { ?a ?b ?c }
  </td><td>
    (bgp (triple ?a ?b ?c))
  </td></tr>
  <tr><td>
    SELECT DISTINCT * WHERE {?a ?b ?c}
  </td><td>
    (distinct (bgp (triple ?a ?b ?c)))
  </td></tr>
  <tr><td>
    SELECT ?a ?b WHERE {?a ?b ?c}
  </td><td>
    (project (?a ?b) (bgp (triple ?a ?b ?c)))
  </td></tr>
  <tr><td>
    CONSTRUCT {?a ?b ?c} WHERE {?a ?b ?c FILTER (?a)}
  </td><td>
    (filter ?a (bgp (triple ?a ?b ?c)))
  </td></tr>
  <tr><td>
    CONSTRUCT {?a ?b ?c} WHERE {?a ?b ?c FILTER (?a)}
  </td><td>
    (filter ?a (bgp (triple ?a ?b ?c)))
  </td></tr>
</table>

To extend this, so that SPARQL::Algebra does not need independent knowledge of datasets and output formats:

<table border="1">
  <tr><th>SPARQL</th><th>SSE</th></tr>
  <tr><td>
    SELECT * FROM <a> WHERE { ?a ?b ?c }
  </td><td>
    (dataset <a> (bgp (triple ?a ?b ?c)))
  </td></tr>
  <tr><td>
    SELECT * FROM NAMED <a> WHERE { ?a ?b ?c }
  </td><td>
    (dataset (named <a>) (bgp (triple ?a ?b ?c)))
  </td></tr>
</table>

Dependencies
------------

* [Ruby](http://ruby-lang.org/) (>= 1.8.7) or (>= 1.8.1 with [Backports][])
* [RDF.rb](http://rubygems.org/gems/rdf) (>= 0.3.0)
* [SXP](https://rubygems.org/gems/sxp) (>= 0.0.13)

Installation
------------

The recommended installation method is via [RubyGems](http://rubygems.org/).
To install the latest official release of the `SPARQL::Grammar` gem, do:

    % [sudo] gem install sparql-grammar

Download
--------

To get a local working copy of the development repository, do:

    % git clone git://github.com/bendiken/sparql-grammar.git

Alternatively, download the latest development version as a tarball as
follows:

    % wget http://github.com/bendiken/sparql-grammar/tarball/master

Mailing List
------------

* <http://lists.w3.org/Archives/Public/public-rdf-ruby/>

Author
------

* [Gregg Kellogg](http://github.com/gkellogg) - <http://kellogg-assoc.com/>
* [Arto Bendiken](http://github.com/bendiken) - <http://ar.to/>

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
[SSE]:        http://openjena.org/wiki/SSE
[SXP]:        http://sxp.rubyforge.org/
[grammar]:    http://www.w3.org/TR/rdf-sparql-query/#grammar
[RDF.rb]:     http://rdf.rubyforge.org/
[YARD]:       http://yardoc.org/
[YARD-GS]:    http://rubydoc.info/docs/yard/file/docs/GettingStarted.md
[PDD]:        http://unlicense.org/#unlicensing-contributions
[Backports]:  http://rubygems.org/gems/backports
