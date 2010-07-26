require 'db_tasks'

def fixture_dir
  ENV['FIXTURE_DIR'] || "#{RAILS_ROOT}/tmp"
end

def schema_name
  ENV["SCHEMA"] || "core"
end

def dump_tables( tables )
 tables.each do |table_name|
    i = 0
    File.open("#{fixture_dir}/#{table_name}.yml", 'wb') do |file|
      print("Dumping #{table_name}\n")
      const_name = :"DUMP_SQL_FOR_#{table_name.gsub('.','_')}"
      if Object.const_defined?(const_name)
        sql = Object.const_get(const_name)
      else
        sql = "SELECT * FROM #{table_name}"
      end

      dump_class = Class.new( ActiveRecord::Base ) do
        set_table_name table_name
      end

      records = YAML::Omap.new
      dump_class.find_by_sql( sql ).collect do |record|
        records["r#{i += 1}"] = record.attributes
      end

      file.write records.to_yaml
    end
  end
end

def load_tables( tables, dir = fixture_dir )
  raise "Fixture directory #{dir} does not exist" unless File.exists?( dir )
  ActiveRecord::Base.connection.transaction do
    Fixtures.create_fixtures( dir, tables )
  end
end

def setup_conn
  DbTasks.setup_connection( DbTasks::Config.environment )
end

def tables_for_schema( schema = schema_name )
  if schema
    begin
      tables = "#{schema}OrderedTables".constantize
    rescue
      raise "Unknown schema #{schema}"
    end
  else
    tables = ActiveRecord::Base.connection.tables
  end

  tables
end

task 'dbt:environment' do
  require(File.join(RAILS_ROOT, 'config', 'environment'))
end

desc 'Load a single fixture into the db from yaml fixtures.'
task "dbt:load:fixture".to_sym => 'dbt:environment' do
  setup_conn
  table = ENV['FIXTURE']
  raise "Missing FIXTURE environment var" if table.nil?
  puts "Loading Fixtures\nFIXTURE=#{table}\nFIXTURE_DIR=#{fixture_dir}\n"
  load_tables( [ table ] )
end

desc 'Load a fixtures for a schema into the db from yaml fixtures.'
task "dbt:load:fixtures".to_sym => 'dbt:environment' do
  setup_conn
  load_tables(tables_for_schema, "#{DbTasks.databases_dir}/#{schema_name}/fixtures")
end

desc 'Dump a single fixture from the db to yaml fixture.'
task "dbt:dump:fixture".to_sym => 'dbt:environment' do
  setup_conn
  table_name = ENV['FIXTURE']
  raise "Missing FIXTURE environment var" if table_name.nil?
  dump_tables([table_name])
end

desc 'Dump the fixtures from all tables in a database to yaml fixtures.'
task "dbt:dump:fixtures".to_sym => 'dbt:environment' do
  setup_conn
  dump_tables(tables_for_schema)
end
