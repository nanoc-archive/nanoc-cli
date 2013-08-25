# encoding: utf-8

$LOAD_PATH.unshift(File.expand_path('../lib/', __FILE__))
require 'nanoc/cli/version'

Gem::Specification.new do |s|
  s.name        = 'nanoc-cli'
  s.version     = Nanoc::CLI::VERSION
  s.homepage    = 'http://nanoc.ws/'
  s.summary     = 'CLI for nanoc'
  s.description = s.summary

  s.author  = 'Denis Defreyne'
  s.email   = 'denis.defreyne@stoneship.org'
  s.license = 'MIT'

  s.required_ruby_version = '>= 1.9.3'

  s.files              = Dir['[A-Z]*'] +
                         Dir['{bin,lib,test}/**/*'] +
                         [ 'nanoc-cli.gemspec' ]
  s.executables        = [ 'nanoc' ]
  s.require_paths      = [ 'lib' ]

  s.rdoc_options     = [ '--main', 'README.md' ]
  s.extra_rdoc_files = [ 'LICENSE', 'README.md', 'NEWS.md' ]

  s.add_runtime_dependency('cri',        '~> 2.0')
  s.add_runtime_dependency('nanoc-core', '~> 4.0.0a1')
end
