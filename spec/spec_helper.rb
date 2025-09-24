# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter 'spec'

  if ENV['CI']
    require 'simplecov_json_formatter'

    formatter SimpleCov::Formatter::JSONFormatter
  end
end

require 'equivalent-xml/rspec_matchers'
require 'moab/stanford'
require 'spec_config'
require 'debug'

RSpec.configure do |config|
  config.before(:all) { fixture_setup }
end

def fixtures_directory
  File.expand_path('fixtures', File.dirname(__FILE__))
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
  (1..3).each do |version|
    version_manifest_dir = manifests_dir.join(TEST_OBJECT_VERSIONS[version])
    version_manifest_dir.mkpath

    # Inventory data directories
    inventory = Moab::FileInventory.new(type: 'version', digital_object_id: FULL_TEST_DRUID, version_id: version)
    inventory.inventory_from_directory(test_object_data_dir.join(TEST_OBJECT_VERSIONS[version]))
    inventory.write_xml_file(version_manifest_dir)

    # Derive signature catalogs from inventories
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

  (2..3).each do |version|
    version_manifest_dir = manifests_dir.join(TEST_OBJECT_VERSIONS[version])

    # Generate version addition reports for all version inventories
    inventory = Moab::FileInventory.read_xml_file(version_manifest_dir, 'version')
    catalog = Moab::SignatureCatalog.read_xml_file(manifests_dir.join(TEST_OBJECT_VERSIONS[version - 1]))
    additions = catalog.version_additions(inventory)
    additions.write_xml_file(version_manifest_dir)

    # Generate difference reports
    old_inventory = Moab::FileInventory.read_xml_file(manifests_dir.join(TEST_OBJECT_VERSIONS[version - 1]), 'version')
    new_inventory = Moab::FileInventory.read_xml_file(manifests_dir.join(TEST_OBJECT_VERSIONS[version]), 'version')
    differences = Moab::FileInventoryDifference.new.compare(old_inventory, new_inventory)
    differences.write_xml_file(manifests_dir)
  end

  # Generate difference report 'all'
  manifest_all_dir = manifests_dir.join('all')
  manifest_all_dir.mkpath
  old_inventory = Moab::FileInventory.read_xml_file(manifests_dir.join(TEST_OBJECT_VERSIONS[1]), 'version')
  new_inventory = Moab::FileInventory.read_xml_file(manifests_dir.join(TEST_OBJECT_VERSIONS[3]), 'version')
  differences = Moab::FileInventoryDifference.new.compare(old_inventory, new_inventory)
  differences.write_xml_file(manifests_dir)

  object_dir = ingests_dir.join(BARE_TEST_DRUID)
  object_dir.mkpath
  reconstructs_dir = derivatives_dir.join('reconstructs')
  (1..3).each do |version|
    # Generate packages from inventories and signature catalogs
    version_package_dir = packages_dir.join(TEST_OBJECT_VERSIONS[version])
    unless version_package_dir.join('data').exist?
      version_data_dir = test_object_data_dir.join(TEST_OBJECT_VERSIONS[version])
      inventory = Moab::FileInventory.read_xml_file(manifests_dir.join(TEST_OBJECT_VERSIONS[version]), 'version')
      catalog = case version
                when 1
                  Moab::SignatureCatalog.new(digital_object_id: inventory.digital_object_id)
                else
                  Moab::SignatureCatalog.read_xml_file(manifests_dir.join(TEST_OBJECT_VERSIONS[version - 1]))
                end
      Moab::Bagger.new(inventory, catalog, version_package_dir).fill_bag(:depositor, version_data_dir)

      # Store packages in a pseudo repository
      unless object_dir.join("v000#{version}").exist?
        bag_dir = packages_dir.join(TEST_OBJECT_VERSIONS[version])
        Moab::StorageObject.new(FULL_TEST_DRUID, object_dir).ingest_bag(bag_dir)
      end

      # Generate reconstructed versions from pseudo repository
      bag_dir = reconstructs_dir.join(TEST_OBJECT_VERSIONS[version])
      unless bag_dir.exist?
        object_dir = ingests_dir.join(BARE_TEST_DRUID)
        Moab::StorageObject.new(FULL_TEST_DRUID, object_dir).reconstruct_version(version, bag_dir)
      end
    end
  end

  ## Re-Generate packages from inventories and signature catalogs
  ## because output contents were moved into psuedo repository
  #(1..3).each do |version|
  #  version_package_dir  = packages_dir.join(TEST_OBJECT_VERSIONS[version])
  #  unless version_package_dir.join('data').exist?
  #    version_data_dir = test_object_data_dir.join(TEST_OBJECT_VERSIONS[version])
  #    inventory = Moab::FileInventory.read_xml_file(manifests_dir.join(TEST_OBJECT_VERSIONS[version]), 'version')
  #    case version
  #      when 1
  #        catalog = Moab::SignatureCatalog.new(:digital_object_id => inventory.digital_object_id)
  #      else
  #        catalog = Moab::SignatureCatalog.read_xml_file(manifests_dir.join(TEST_OBJECT_VERSIONS[version-1]))
  #    end
  #    Moab::StorageObject.package(inventory, catalog, version_data_dir, version_package_dir)
  #  end
  #end
end
# rubocop:enable Metrics/AbcSize
