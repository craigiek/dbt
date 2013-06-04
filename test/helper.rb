$:.unshift File.expand_path('../../lib', __FILE__)

require 'minitest/autorun'
require 'dbt'
require 'tmpdir'

class Dbt::TestCase < Minitest::Test

  def setup
    Dbt::Config.default_search_dirs = nil
    Dbt::Config.default_no_create = nil
    Dbt::Config.config_filename = nil
    Dbt::Config.datasets_dir_name = nil
    Dbt::Config.repository_config_file = nil
    Dbt::Config.default_up_dirs = nil
    Dbt::Config.default_down_dirs = nil
    Dbt::Config.default_finalize_dirs = nil
    Dbt::Config.default_pre_create_dirs = nil
    Dbt::Config.default_post_create_dirs = nil
    Dbt::Config.default_pre_import_dirs = nil
    Dbt::Config.default_post_import_dirs = nil
    Dbt::Config.index_file_name = nil
    Dbt::Config.default_import = nil
    Dbt::Config.fixture_dir_name = nil
    Dbt::Config.environment = nil
    Dbt::Config.driver = nil
    Dbt::Config.default_migrations_dir_name = nil
    Dbt::Config.default_database = nil
    Dbt::Config.task_prefix = nil

    @cwd = Dir.pwd
    @base_temp_dir = ENV["TEST_TMP_DIR"] || File.expand_path("#{File.dirname(__FILE__)}/../tmp")
    @temp_dir = "#{@base_temp_dir}/#{name}"
    FileUtils.mkdir_p @temp_dir
    Dir.chdir(@temp_dir)
  end

  def teardown
    Dir.chdir(@cwd)
    FileUtils.rm_rf @base_temp_dir if File.exist?(@base_temp_dir)
  end

  def working_dir
    @temp_dir
  end
end
