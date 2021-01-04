# frozen_string_literal: true

require 'coveralls'
Coveralls.wear_merged! # because we run travis on multiple rubies

require 'simplecov'
SimpleCov.formatter = Coveralls::SimpleCov::Formatter
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

def fixture_setup
  @temp = Pathname.new(File.dirname(__FILE__)).join('temp')
  @temp.mkpath
  @temp = @temp.realpath
  @fixtures = Pathname.new(File.dirname(__FILE__)).join('fixtures')
  @fixtures.mkpath
  @fixtures = @fixtures.realpath
  @obj = "jq937jp0017"
  @druid = "druid:#{@obj}"
  @data = @fixtures.join("data", @obj)
  @derivatives = @fixtures.join('derivatives')
  @manifests = @derivatives.join('manifests')
  @packages = @derivatives.join('packages')
  @ingests = @derivatives.join('ingests')
  @reconstructs = @derivatives.join('reconstructs')
  @vname = [nil, 'v0001', 'v0002', 'v0003']

  # Inventory data directories
  (1..3).each do |version|
    manifest_dir = @manifests.join(@vname[version])
    manifest_dir.mkpath
    inventory = Moab::FileInventory.new(type: 'version', digital_object_id: @druid, version_id: version)
    inventory.inventory_from_directory(@data.join(@vname[version]))
    inventory.write_xml_file(manifest_dir)
  end

  # Derive signature catalogs from inventories
  (1..3).each do |version|
    manifest_dir = @manifests.join(@vname[version])
    manifest_dir.mkpath
    inventory = Moab::FileInventory.read_xml_file(manifest_dir, 'version')
    catalog = case version
              when 1
                Moab::SignatureCatalog.new(digital_object_id: inventory.digital_object_id)
              else
                Moab::SignatureCatalog.read_xml_file(@manifests.join(@vname[version - 1]))
              end
    catalog.update(inventory, @data.join(@vname[version]))
    catalog.write_xml_file(manifest_dir)
  end

  # Generate version addition reports for all version inventories
  (2..3).each do |version|
    manifest_dir = @manifests.join(@vname[version])
    manifest_dir.mkpath
    inventory = Moab::FileInventory.read_xml_file(manifest_dir, 'version')
    catalog = Moab::SignatureCatalog.read_xml_file(@manifests.join(@vname[version - 1]))
    additions = catalog.version_additions(inventory)
    additions.write_xml_file(manifest_dir)
  end

  # Generate difference reports
  (2..3).each do |version|
    manifest_dir = @manifests.join(@vname[version])
    manifest_dir.mkpath
    old_inventory = Moab::FileInventory.read_xml_file(@manifests.join(@vname[version - 1]), 'version')
    new_inventory = Moab::FileInventory.read_xml_file(@manifests.join(@vname[version]), 'version')
    differences = Moab::FileInventoryDifference.new.compare(old_inventory, new_inventory)
    differences.write_xml_file(manifest_dir)
  end
  manifest_dir = @manifests.join('all')
  manifest_dir.mkpath
  old_inventory = Moab::FileInventory.read_xml_file(@manifests.join(@vname[1]), 'version')
  new_inventory = Moab::FileInventory.read_xml_file(@manifests.join(@vname[3]), 'version')
  differences = Moab::FileInventoryDifference.new.compare(old_inventory, new_inventory)
  differences.write_xml_file(manifest_dir)

  # Generate packages from inventories and signature catalogs
  (1..3).each do |version|
    package_dir = @packages.join(@vname[version])
    unless package_dir.join('data').exist?
      data_dir = @data.join(@vname[version])
      inventory = Moab::FileInventory.read_xml_file(@manifests.join(@vname[version]), 'version')
      catalog = case version
                when 1
                  Moab::SignatureCatalog.new(digital_object_id: inventory.digital_object_id)
                else
                  Moab::SignatureCatalog.read_xml_file(@manifests.join(@vname[version - 1]))
                end
      Moab::Bagger.new(inventory, catalog, package_dir).fill_bag(:depositor, data_dir)
    end
  end

  # Store packages in a pseudo repository
  (1..3).each do |version|
    object_dir = @ingests.join(@obj)
    object_dir.mkpath
    unless object_dir.join("v000#{version}").exist?
      bag_dir = @packages.join(@vname[version])
      Moab::StorageObject.new(@druid, object_dir).ingest_bag(bag_dir)
    end
  end

  # Generate reconstructed versions from pseudo repository
  (1..3).each do |version|
    bag_dir = @reconstructs.join(@vname[version])
    unless bag_dir.exist?
      object_dir = @ingests.join(@obj)
      Moab::StorageObject.new(@druid, object_dir).reconstruct_version(version, bag_dir)
    end
  end

  ## Re-Generate packages from inventories and signature catalogs
  ## because output contents were moved into psuedo repository
  #(1..3).each do |version|
  #  package_dir  = @packages.join(@vname[version])
  #  unless package_dir.join('data').exist?
  #    data_dir = @data.join(@vname[version])
  #    inventory = Moab::FileInventory.read_xml_file(@manifests.join(@vname[version]),'version')
  #    case version
  #      when 1
  #        catalog = Moab::SignatureCatalog.new(:digital_object_id => inventory.digital_object_id)
  #      else
  #        catalog = Moab::SignatureCatalog.read_xml_file(@manifests.join(@vname[version-1]))
  #    end
  #    Moab::StorageObject.package(inventory,catalog,data_dir,package_dir)
  #  end
  #end
end
