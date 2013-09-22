# encoding: utf-8

require 'bundler'
Bundler.setup

require 'minitest'
require 'minitest/autorun'

# (disabled until colorize/colored issue is resolved)
#require 'coveralls'
#Coveralls.wear!

# Load nanoc
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
require 'nanoc/core'
require 'nanoc/cli'

Nanoc::CLI.setup

# Load miscellaneous requirements
require 'stringio'

module Nanoc::TestHelpers

  def in_site(params={})
    # Build site name
    site_name = params[:name]
    if site_name.nil?
      @site_num ||= 0
      site_name = "site-#{@site_num}"
      @site_num += 1
    end

    # Create site
    unless File.directory?(site_name)
      FileUtils.mkdir_p(site_name)
      FileUtils.cd(site_name) do
        create_site_here(params)
      end
    end

    # Yield site
    FileUtils.cd(site_name) do
      yield
    end
  end

  def site_here
    Nanoc::SiteLoader.new.load
  end

  def compile_site_here
    Nanoc::Compiler.new(site_here).run
  end

  def create_site_here(params={})
    # Build rules
    rules_content = <<EOS
compile '/**/*' do
  {{compilation_rule_content}}

  if item.binary?
    write item.identifier, :snapshot => :last
  elsif item.identifier.match?('/index.*')
    write '/index.html', :snapshot => :last
  else
    write item.identifier.without_ext + '/index.html', :snapshot => :last
  end
end

layout '/**/*', :erb
EOS
    rules_content.gsub!('{{compilation_rule_content}}', params[:compilation_rule_content] || '')

    FileUtils.mkdir_p('content')
    FileUtils.mkdir_p('layouts')
    FileUtils.mkdir_p('lib')
    FileUtils.mkdir_p('output')

    if params[:has_layout]
      File.open('layouts/default.html', 'w') do |io|
        io.write('... <%= @yield %> ...')
      end
    end

    File.write('nanoc.yaml', 'stuff: 12345')
    File.write('Rules', rules_content)
  end

  def setup
    # Clean up
    GC.start

    # Go quiet
    unless ENV['QUIET'] == 'false'
      $stdout = StringIO.new
      $stderr = StringIO.new
    end

    # Enter tmp
    FileUtils.mkdir_p('tmp')
    @orig_wd = FileUtils.pwd
    FileUtils.cd('tmp')

    # Let us get to the raw errors
    Nanoc::CLI::ErrorHandler.disable
  end

  def teardown
    # Restore normal error handling
    Nanoc::CLI::ErrorHandler.enable

    # Exit tmp
    FileUtils.cd(@orig_wd)
    FileUtils.rm_rf('tmp')

    # Go unquiet
    unless ENV['QUIET'] == 'false'
      $stdout = STDOUT
      $stderr = STDERR
    end
  end

end

class Nanoc::TestCase < Minitest::Test

  include Nanoc::TestHelpers

end

# Unexpected system exit is unexpected
::Minitest::Test::PASSTHROUGH_EXCEPTIONS.delete(SystemExit)
