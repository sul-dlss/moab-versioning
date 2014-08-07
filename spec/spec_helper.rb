#$LOAD_PATH.unshift(File.dirname(__FILE__))
#$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rspec'
require 'rspec/core'
require 'equivalent-xml'
require 'moab_stanford'
require 'spec_config'
require 'ap'

include Stanford

RSpec.configure do |config|
  config.before(:all) {fixture_setup}
  config.alias_example_to :scenario
end

def fixtures_directory
  File.expand_path('fixtures', File.dirname(__FILE__))
end

# Use Gherkin DSL syntax in specs for better readability
# feature "<title>"  do
#    In order to: <achieve benefit>
#    The application needs to: <provide functionality>
#    ...
# end
module RSpec::Core::DSL
  alias feature describe
end

# Use Gherkin DSL syntax in specs for better readability
# scenario "<title>" do
#   given: <inputs>
#   action: <the application does>
#   outcome: <to generate this result>
#   ...
# end

module RSpec::Core::Hooks
  alias background before
end

# Custom matcher that returns difference between expected and actual hash
# Note that enhancements to doing diffs in rspec are in progress:
# @see https://github.com/rspec/rspec-expectations/pull/79
# @see https://github.com/playup/diff_matcher
# @see https://github.com/rspec/rspec-expectations/issues/97
RSpec::Matchers.define :hash_match do |expected|
  diff = nil
  match do |actual|
    expected = expected.is_a?(Hash) ? expected : expected.to_hash
    detected = actual.is_a?(Hash) ? actual : actual.to_hash
    diff = Serializable.deep_diff(:expected, expected, :detected, detected)
    diff == {}
  end
  failure_message_for_should do |actual|
    # ai is a kernel mixin that calls AwesomePrint::Inspector
    "Hash difference found: \n#{diff.ai}"
  end
end

def fixture_setup
  @temp = Pathname.new(File.dirname(__FILE__)).join('temp')
  @temp.mkpath
  @temp = @temp.realpath
  @fixtures = Pathname.new(File.dirname(__FILE__)).join('fixtures')
  @fixtures.mkpath
  @fixtures = @fixtures.realpath
  @obj="jq937jp0017"
  @druid="druid:#{@obj}"
  @data = @fixtures.join("data", @obj)
  @derivatives = @fixtures.join('derivatives')
  @manifests = @derivatives.join('manifests')
  @packages = @derivatives.join('packages')
  @ingests = @derivatives.join('ingests')
  @reconstructs = @derivatives.join('reconstructs')
  @vname=[nil, 'v0001', 'v0002', 'v0003']

  # Inventory data directories
  (1..3).each do |version|
    manifest_dir = @manifests.join(@vname[version])
    manifest_dir.mkpath
    unless FileInventory.xml_pathname_exist?(manifest_dir, 'version')
      inventory = FileInventory.new(
          :type=>'version',
          :digital_object_id => @druid,
          :version_id => version )
      inventory.inventory_from_directory(@data.join(@vname[version]))
      inventory.write_xml_file(manifest_dir)
    end
  end

  # Derive signature catalogs from inventories
  (1..3).each do |version|
    manifest_dir = @manifests.join(@vname[version])
    manifest_dir.mkpath
    unless SignatureCatalog.xml_pathname_exist?(manifest_dir)
      inventory = FileInventory.read_xml_file(manifest_dir,'version')
      case version
        when 1
          catalog = SignatureCatalog.new(:digital_object_id => inventory.digital_object_id)
        else
          catalog = SignatureCatalog.read_xml_file(@manifests.join(@vname[version-1]))
      end
      catalog.update(inventory, @data.join(@vname[version]))
      catalog.write_xml_file(manifest_dir)
    end
  end

  # Generate version addition reports for all version inventories
  (2..3).each do |version|
    manifest_dir = @manifests.join(@vname[version])
    manifest_dir.mkpath
    unless FileInventory.xml_pathname_exist?(manifest_dir,'additions')
      inventory = FileInventory.read_xml_file(manifest_dir,'version')
      catalog = SignatureCatalog.read_xml_file(@manifests.join(@vname[version-1]))
      additions = catalog.version_additions(inventory)
      additions.write_xml_file(manifest_dir)
    end
  end

  # Generate difference reports
  (2..3).each do |version|
    manifest_dir = @manifests.join(@vname[version])
    manifest_dir.mkpath
    unless FileInventoryDifference.xml_pathname_exist?(manifest_dir)
      old_inventory = FileInventory.read_xml_file(@manifests.join(@vname[version-1]),'version')
      new_inventory = FileInventory.read_xml_file(@manifests.join(@vname[version]),'version')
      differences = FileInventoryDifference.new.compare(old_inventory, new_inventory)
      differences.write_xml_file(manifest_dir)
    end
  end
  manifest_dir = @manifests.join('all')
  manifest_dir.mkpath
  unless FileInventoryDifference.xml_pathname_exist?(manifest_dir)
    old_inventory = FileInventory.read_xml_file(@manifests.join(@vname[1]),'version')
    new_inventory = FileInventory.read_xml_file(@manifests.join(@vname[3]),'version')
    differences = FileInventoryDifference.new.compare(old_inventory, new_inventory)
    differences.write_xml_file(manifest_dir)
  end

  # Generate packages from inventories and signature catalogs
  (1..3).each do |version|
    package_dir  = @packages.join(@vname[version])
    unless package_dir.join('data').exist?
      data_dir = @data.join(@vname[version])
      inventory = FileInventory.read_xml_file(@manifests.join(@vname[version]),'version')
      case version
        when 1
          catalog = SignatureCatalog.new(:digital_object_id => inventory.digital_object_id)
        else
          catalog = SignatureCatalog.read_xml_file(@manifests.join(@vname[version-1]))
      end
      Bagger.new(inventory,catalog,package_dir).fill_bag(:depositor,data_dir)
    end
  end

  # Store packages in a pseudo repository
  (1..3).each do |version|
    object_dir = @ingests.join(@obj)
    object_dir.mkpath
    unless object_dir.join("v000#{version}").exist?
      bag_dir = @packages.join(@vname[version])
      StorageObject.new(@druid,object_dir).ingest_bag(bag_dir)
    end
  end

  # Generate reconstructed versions from pseudo repository
  (1..3).each do |version|
    bag_dir = @reconstructs.join(@vname[version])
    unless bag_dir.exist?
      object_dir = @ingests.join(@obj)
      StorageObject.new(@druid,object_dir).reconstruct_version(version, bag_dir)
    end
  end

  ## Re-Generate packages from inventories and signature catalogs
  ## because output contents were moved into psuedo repository
  #(1..3).each do |version|
  #  package_dir  = @packages.join(@vname[version])
  #  unless package_dir.join('data').exist?
  #    data_dir = @data.join(@vname[version])
  #    inventory = FileInventory.read_xml_file(@manifests.join(@vname[version]),'version')
  #    case version
  #      when 1
  #        catalog = SignatureCatalog.new(:digital_object_id => inventory.digital_object_id)
  #      else
  #        catalog = SignatureCatalog.read_xml_file(@manifests.join(@vname[version-1]))
  #    end
  #    StorageObject.package(inventory,catalog,data_dir,package_dir)
  #  end
  #end

end

