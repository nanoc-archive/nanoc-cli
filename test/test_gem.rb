# encoding: utf-8

class Nanoc::GemTest < Nanoc::TestCase

  def setup
    super
    FileUtils.cd(@orig_wd)
  end

  def test_build
    require 'systemu'

    # Require clean environment
    Dir['nanoc-cli-*.gem'].each { |f| FileUtils.rm(f) }

    # Build
    files_before = Set.new Dir['**/*']
    stdout = ''
    stderr = ''
    status = systemu(
      [ 'gem', 'build', 'nanoc-cli.gemspec' ],
      'stdin'  => '',
      'stdout' => stdout,
      'stderr' => stderr)
    assert status.success?
    files_after = Set.new Dir['**/*']

    # Check new files
    diff = files_after - files_before
    assert_equal 1, diff.size
    assert_match(/^nanoc-cli-.*\.gem$/, diff.to_a[0])
  ensure
    Dir['nanoc-cli-*.gem'].each { |f| FileUtils.rm(f) }
  end

end
