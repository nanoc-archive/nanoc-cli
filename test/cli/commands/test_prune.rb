# encoding: utf-8

class Nanoc::CLI::Commands::PruneTest < Nanoc::TestCase

  def test_run_without_yes
    in_site do
      # Set output dir
      File.open('nanoc.yaml', 'w') { |io| io.write 'build_dir: output2' }
      FileUtils.mkdir_p('output2')

      # Create source files
      File.open('content/index.html', 'w') { |io| io.write 'stuff' }

      # Create output files
      File.open('output2/foo.html', 'w')   { |io| io.write 'this is a foo.' }
      File.open('output2/index.html', 'w') { |io| io.write 'this is a index.' }

      assert_raises SystemExit do
        Nanoc::CLI.run %w( prune )
      end

      assert File.file?('output2/index.html')
      assert File.file?('output2/foo.html')
    end
  end

  def test_run_with_yes
    in_site do
      # Set output dir
      File.open('nanoc.yaml', 'w') { |io| io.write 'build_dir: output2' }
      FileUtils.mkdir_p('output2')

      # Create source files
      File.open('content/index.html', 'w') { |io| io.write 'stuff' }

      # Create output files
      File.open('output2/foo.html', 'w')   { |io| io.write 'this is a foo.' }
      File.open('output2/index.html', 'w') { |io| io.write 'this is a index.' }

      Nanoc::CLI.run %w( prune --yes )

      assert File.file?('output2/index.html')
      assert !File.file?('output2/foo.html')
    end
  end

  def test_run_with_dry_run
    in_site do
      # Set output dir
      File.open('nanoc.yaml', 'w') { |io| io.write 'build_dir: output2' }
      FileUtils.mkdir_p('output2')

      # Create source files
      File.open('content/index.html', 'w') { |io| io.write 'stuff' }

      # Create output files
      File.open('output2/foo.html', 'w')   { |io| io.write 'this is a foo.' }
      File.open('output2/index.html', 'w') { |io| io.write 'this is a index.' }

      Nanoc::CLI.run %w( prune --dry-run )

      assert File.file?('output2/index.html')
      assert File.file?('output2/foo.html')
    end
  end

  def test_run_with_exclude
     in_site do
      # Set output dir
      File.open('nanoc.yaml', 'w') { |io| io.write "prune:\n  exclude: [ 'good-dir', 'good-file.html' ]" }
      FileUtils.mkdir_p('output')

      # Create source files
      File.open('content/index.html', 'w') { |io| io.write 'stuff' }

      # Create output files
      FileUtils.mkdir_p('build/good-dir')
      FileUtils.mkdir_p('build/bad-dir')
      File.open('build/good-file.html', 'w') { |io| io.write 'stuff' }
      File.open('build/good-dir/blah', 'w')  { |io| io.write 'stuff' }
      File.open('build/bad-file.html', 'w')  { |io| io.write 'stuff' }
      File.open('build/bad-dir/blah', 'w')   { |io| io.write 'stuff' }
      File.open('build/index.html', 'w')     { |io| io.write 'stuff' }

      Nanoc::CLI.run %w( prune --yes )

      assert File.file?('build/index.html')
      assert File.file?('build/good-dir/blah')
      assert File.file?('build/good-file.html')
      assert !File.file?('build/bad-dir/blah')
      assert !File.file?('build/bad-file.html')
    end
  end

  def test_run_with_symlink_to_build_dir
    if 'jruby' == RUBY_ENGINE && '1.7.4' == JRUBY_VERSION
      skip "Symlink behavior on JRuby is known to be broken (see https://github.com/jruby/jruby/issues/1036)"
    end

    in_site do
      # Set output dir
      FileUtils.rm_rf('build')
      FileUtils.mkdir_p('build-real')
      File.symlink('build-real', 'build')

      # Create source files
      File.open('content/index.html', 'w') { |io| io.write 'stuff' }

      # Create output files
      FileUtils.mkdir_p('build-real/some-dir')
      File.open('build-real/some-file.html', 'w') { |io| io.write 'stuff' }
      File.open('build-real/index.html', 'w')     { |io| io.write 'stuff' }

      Nanoc::CLI.run %w( prune --yes )

      assert File.file?('build-real/index.html')
      assert !File.directory?('build-real/some-dir')
      assert !File.file?('build-real/some-file.html')
    end
  end

  def test_run_with_nested_empty_dirs
    in_site do
      # Set build dir
      FileUtils.mkdir_p('build')

      # Create build files
      FileUtils.mkdir_p('build/a/b/c')
      File.open('build/a/b/c/index.html', 'w') { |io| io.write 'stuff' }

      Nanoc::CLI.run %w( prune --yes )

      assert !File.file?('build/a/b/c/index.html')
      assert !File.directory?('build/a/b/c')
      assert !File.directory?('build/a/b')
      assert !File.directory?('build/a')
    end
  end

end
