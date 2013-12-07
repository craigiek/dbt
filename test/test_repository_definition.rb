require File.expand_path('../helper', __FILE__)

class TestRepositoryDefinition < Dbt::TestCase

  def test_defaults
    definition = Dbt::RepositoryDefinition.new
    assert_equal definition.schema_overrides, {}
    assert_equal definition.table_map, {}
    assert_equal definition.modules, []
    assert_equal definition.to_yaml, "---\nmodules: !omap []\n"
  end

  def test_from_yaml
    definition = Dbt::RepositoryDefinition.new
    definition.from_yaml(<<-CONFIG)
---
modules: !omap
- CodeMetrics:
    schema: CodeMetrics
    tables:
    - '[CodeMetrics].[tblCollection]'
    - '[CodeMetrics].[tblMethodMetric]'
- Geo:
    schema: Geo
    tables:
    - '[Geo].[tblMobilePOI]'
    - '[Geo].[tblPOITrack]'
    - '[Geo].[tblSector]'
    - '[Geo].[tblOtherGeom]'
- TestModule:
    schema: TM
    tables:
    - '[TM].[tblBaseX]'
    - '[TM].[tblFoo]'
    - '[TM].[tblBar]'
    CONFIG

    assert_equal definition.modules, ['CodeMetrics', 'Geo', 'TestModule']
    assert_equal definition.schema_overrides.size, 1
    assert_equal definition.schema_name_for_module('TestModule'), 'TM'
    assert_equal definition.table_ordering('Geo'), ['[Geo].[tblMobilePOI]', '[Geo].[tblPOITrack]', '[Geo].[tblSector]', '[Geo].[tblOtherGeom]']
  end

  def test_to_yaml
    definition = Dbt::RepositoryDefinition.new
    definition.modules = ['CodeMetrics', 'Geo', 'TestModule']
    definition.schema_overrides = {'TestModule' => 'TM'}
    definition.table_map = {
      'TestModule' => ['[TM].[tblBaseX]', '[TM].[tblFoo]', '[TM].[tblBar]'],
      'Geo' => ['[Geo].[tblMobilePOI]', '[Geo].[tblPOITrack]', '[Geo].[tblSector]', '[Geo].[tblOtherGeom]'],
      'CodeMetrics' => ['[CodeMetrics].[tblCollection]', '[CodeMetrics].[tblMethodMetric]']
    }
    assert_equal definition.to_yaml, <<YAML
---
modules: !omap
- CodeMetrics:
    schema: CodeMetrics
    tables:
    - '[CodeMetrics].[tblCollection]'
    - '[CodeMetrics].[tblMethodMetric]'
- Geo:
    schema: Geo
    tables:
    - '[Geo].[tblMobilePOI]'
    - '[Geo].[tblPOITrack]'
    - '[Geo].[tblSector]'
    - '[Geo].[tblOtherGeom]'
- TestModule:
    schema: TM
    tables:
    - '[TM].[tblBaseX]'
    - '[TM].[tblFoo]'
    - '[TM].[tblBar]'
YAML
  end

end
