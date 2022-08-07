# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
end

require 'equivalent-xml'
require 'moab/stanford'
require 'spec_config'

RSpec.configure do |config|
  config.before(:all) { fixture_setup }
end

def fixtures_directory
  File.expand_path('fixtures', File.dirname(__FILE__))
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
    diff = Serializer::Serializable.deep_diff(:expected, expected, :detected, detected)
    diff == {}
  end
  failure_message do |_actual|
    # ai is a kernel mixin that calls AwesomePrint::Inspector
    "Hash difference found: \n#{diff.ai}"
  end
end

BARE_TEST_DRUID = 'jq937jp0017'
FULL_TEST_DRUID = "druid:#{BARE_TEST_DRUID}".freeze
TEST_OBJECT_VERSIONS = [nil, 'v0001', 'v0002', 'v0003'].freeze

def fixtures_dir
  @fixtures_dir ||= begin
    fixtures_dir = Pathname.new(File.dirname(__FILE__)).join('fixtures')
    fixtures_dir.realpath
  end
end

def temp_dir
  @temp_dir ||= begin
    temp_dir = Pathname.new(File.dirname(__FILE__)).join('temp')
    temp_dir.mkpath
    temp_dir.realpath
  end
end

def test_object_data_dir
  @test_object_data_dir ||= fixtures_dir.join(Moab::StorageObjectValidator::DATA_DIR, BARE_TEST_DRUID)
end

def manifests_dir
  @manifests_dir ||= derivatives_dir.join('manifests')
end

def packages_dir
  @packages_dir ||= derivatives_dir.join('packages')
end

def ingests_dir
  @ingests_dir ||= derivatives_dir.join('ingests')
end

def derivatives_dir
  @derivatives_dir ||= fixtures_dir.join('derivatives')
end

# rubocop:disable Metrics/AbcSize
def fixture_setup
  # Inventory data directories
  (1..3).each do |version|
    version_manifest_dir = manifests_dir.join(TEST_OBJECT_VERSIONS[version])
    version_manifest_dir.mkpath
    inventory = Moab::FileInventory.new(type: 'version', digital_object_id: FULL_TEST_DRUID, version_id: version)
    inventory.inventory_from_directory(test_object_data_dir.join(TEST_OBJECT_VERSIONS[version]))
    inventory.write_xml_file(version_manifest_dir)
  end

  # Derive signature catalogs from inventories
  (1..3).each do |version|
    version_manifest_dir = manifests_dir.join(TEST_OBJECT_VERSIONS[version])
    version_manifest_dir.mkpath
    inventory = Moab::FileInventory.read_xml_file(version_manifest_dir, 'version')
    catalog = case version
              when 1
                Moab::SignatureCatalog.new(digital_object_id: inventory.digital_object_id)
              else
                Moab::SignatureCatalog.read_xml_file(manifests_dir.join(TEST_OBJECT_VERSIONS[version - 1]))
              end
    catalog.update(inventory, test_object_data_dir.join(TEST_OBJECT_VERSIONS[version]))
    catalog.write_xml_file(version_manifest_dir)
  end

  # Generate version addition reports for all version inventories
  (2..3).each do |version|
    version_manifest_dir = manifests_dir.join(TEST_OBJECT_VERSIONS[version])
    version_manifest_dir.mkpath
    inventory = Moab::FileInventory.read_xml_file(version_manifest_dir, 'version')
    catalog = Moab::SignatureCatalog.read_xml_file(manifests_dir.join(TEST_OBJECT_VERSIONS[version - 1]))
    additions = catalog.version_additions(inventory)
    additions.write_xml_file(version_manifest_dir)
  end

  # Generate difference reports
  (2..3).each do |version|
    version_manifest_dir = manifests_dir.join(TEST_OBJECT_VERSIONS[version])
    version_manifest_dir.mkpath
    old_inventory = Moab::FileInventory.read_xml_file(manifests_dir.join(TEST_OBJECT_VERSIONS[version - 1]), 'version')
    new_inventory = Moab::FileInventory.read_xml_file(manifests_dir.join(TEST_OBJECT_VERSIONS[version]), 'version')
    differences = Moab::FileInventoryDifference.new.compare(old_inventory, new_inventory)
    differences.write_xml_file(manifests_dir)
  end
  manifest_all_dir = manifests_dir.join('all')
  manifest_all_dir.mkpath
  old_inventory = Moab::FileInventory.read_xml_file(manifests_dir.join(TEST_OBJECT_VERSIONS[1]), 'version')
  new_inventory = Moab::FileInventory.read_xml_file(manifests_dir.join(TEST_OBJECT_VERSIONS[3]), 'version')
  differences = Moab::FileInventoryDifference.new.compare(old_inventory, new_inventory)
  differences.write_xml_file(manifests_dir)

  # Generate packages from inventories and signature catalogs
  (1..3).each do |version|
    package_dir = packages_dir.join(TEST_OBJECT_VERSIONS[version])
    unless package_dir.join('data').exist?
      version_data_dir = test_object_data_dir.join(TEST_OBJECT_VERSIONS[version])
      inventory = Moab::FileInventory.read_xml_file(manifests_dir.join(TEST_OBJECT_VERSIONS[version]), 'version')
      catalog = case version
                when 1
                  Moab::SignatureCatalog.new(digital_object_id: inventory.digital_object_id)
                else
                  Moab::SignatureCatalog.read_xml_file(manifests_dir.join(TEST_OBJECT_VERSIONS[version - 1]))
                end
      Moab::Bagger.new(inventory, catalog, package_dir).fill_bag(:depositor, version_data_dir)
    end
  end

  # Store packages in a pseudo repository
  (1..3).each do |version|
    object_dir = ingests_dir.join(BARE_TEST_DRUID)
    object_dir.mkpath
    unless object_dir.join("v000#{version}").exist?
      bag_dir = packages_dir.join(TEST_OBJECT_VERSIONS[version])
      Moab::StorageObject.new(FULL_TEST_DRUID, object_dir).ingest_bag(bag_dir)
    end
  end

  # Generate reconstructed versions from pseudo repository
  reconstructs_dir = derivatives_dir.join('reconstructs')
  (1..3).each do |version|
    bag_dir = reconstructs_dir.join(TEST_OBJECT_VERSIONS[version])
    unless bag_dir.exist?
      object_dir = ingests_dir.join(BARE_TEST_DRUID)
      Moab::StorageObject.new(FULL_TEST_DRUID, object_dir).reconstruct_version(version, bag_dir)
    end
  end

  ## Re-Generate packages from inventories and signature catalogs
  ## because output contents were moved into psuedo repository
  #(1..3).each do |version|
  #  package_dir  = packages_dir.join(TEST_OBJECT_VERSIONS[version])
  #  unless package_dir.join('data').exist?
  #    version_data_dir = test_object_data_dir.join(TEST_OBJECT_VERSIONS[version])
  #    inventory = Moab::FileInventory.read_xml_file(manifests_dir.join(TEST_OBJECT_VERSIONS[version]),'version')
  #    case version
  #      when 1
  #        catalog = Moab::SignatureCatalog.new(:digital_object_id => inventory.digital_object_id)
  #      else
  #        catalog = Moab::SignatureCatalog.read_xml_file(manifests_dir.join(TEST_OBJECT_VERSIONS[version-1]))
  #    end
  #    Moab::StorageObject.package(inventory,catalog,version_data_dir,package_dir)
  #  end
  #end
end
# rubocop:enable Metrics/AbcSize
