# encoding: utf-8

class Nanoc::CLI::Commands::CreateSiteTest < Nanoc::TestCase

  class CustomDataSource < ::Nanoc::DataSource

    identifier :custom

  end

  def test_create_site_with_existing_name
    Nanoc::CLI.run %w( create_site foo )
    assert_raises(::Nanoc::Errors::GenericTrivial) do
      Nanoc::CLI.run %w( create_site foo )
    end
  end

  def test_can_compile_new_site
    Nanoc::CLI.run %w( create_site foo )

    FileUtils.cd('foo') do
      compile_site_here
    end
  end

  def test_can_create_site_with_custom_data_source
    Nanoc::CLI.run %w( create_site --datasource custom foo )
  end

end
