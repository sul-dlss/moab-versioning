# frozen_string_literal: true

describe 'Import digital object version to SDR' do
  #  In order to: ingest a new version of a digital object into SDR
  #  The application needs to: process a Bagit bag containing either a full set or subset of object files

  let(:temp_ingests_dir) { temp_dir.join('ingests') }
  let(:object_temp_dir) { temp_ingests_dir.join(BARE_TEST_DRUID) }

  before do
    temp_ingests_dir.rmtree if temp_ingests_dir.exist?
    object_temp_dir.mkpath
  end

  after do
    temp_ingests_dir.rmtree if temp_ingests_dir.exist?
  end

  it 'Creates a new version storage folder' do
    # given: A Bagit bag containing a version of a digital object
    # action: Parse the file inventory for the version,
    #       : create the new version's storage folder,
    #       : copy the version's data files into storage,
    #       : update the object's signature catalog,
    #       : generate a version differences report,
    #       : and generate an inventory of all the manifest files
    # outcome: version storage folder

    %w[v0001 v0002 v0003].each do |version_name|
      unless object_temp_dir.join(version_name).exist?
        bag_version_dir = packages_dir.join(version_name)
        Moab::StorageObject.new(FULL_TEST_DRUID, object_temp_dir).ingest_bag(bag_version_dir)
      end
    end

    files = []
    temp_ingests_dir.find { |f| files << f.relative_path_from(temp_dir).to_s }
    expect(files.sort).to eq([
                               'ingests',
                               'ingests/jq937jp0017',
                               'ingests/jq937jp0017/v0001',
                               'ingests/jq937jp0017/v0001/data',
                               'ingests/jq937jp0017/v0001/data/content',
                               'ingests/jq937jp0017/v0001/data/content/intro-1.jpg',
                               'ingests/jq937jp0017/v0001/data/content/intro-2.jpg',
                               'ingests/jq937jp0017/v0001/data/content/page-1.jpg',
                               'ingests/jq937jp0017/v0001/data/content/page-2.jpg',
                               'ingests/jq937jp0017/v0001/data/content/page-3.jpg',
                               'ingests/jq937jp0017/v0001/data/content/title.jpg',
                               'ingests/jq937jp0017/v0001/data/metadata',
                               'ingests/jq937jp0017/v0001/data/metadata/contentMetadata.xml',
                               'ingests/jq937jp0017/v0001/data/metadata/descMetadata.xml',
                               'ingests/jq937jp0017/v0001/data/metadata/identityMetadata.xml',
                               'ingests/jq937jp0017/v0001/data/metadata/provenanceMetadata.xml',
                               'ingests/jq937jp0017/v0001/data/metadata/versionMetadata.xml',
                               'ingests/jq937jp0017/v0001/manifests',
                               'ingests/jq937jp0017/v0001/manifests/fileInventoryDifference.xml',
                               'ingests/jq937jp0017/v0001/manifests/manifestInventory.xml',
                               'ingests/jq937jp0017/v0001/manifests/signatureCatalog.xml',
                               'ingests/jq937jp0017/v0001/manifests/versionAdditions.xml',
                               'ingests/jq937jp0017/v0001/manifests/versionInventory.xml',
                               'ingests/jq937jp0017/v0002',
                               'ingests/jq937jp0017/v0002/data',
                               'ingests/jq937jp0017/v0002/data/content',
                               'ingests/jq937jp0017/v0002/data/content/page-1.jpg',
                               'ingests/jq937jp0017/v0002/data/metadata',
                               'ingests/jq937jp0017/v0002/data/metadata/contentMetadata.xml',
                               'ingests/jq937jp0017/v0002/data/metadata/provenanceMetadata.xml',
                               'ingests/jq937jp0017/v0002/data/metadata/versionMetadata.xml',
                               'ingests/jq937jp0017/v0002/manifests',
                               'ingests/jq937jp0017/v0002/manifests/fileInventoryDifference.xml',
                               'ingests/jq937jp0017/v0002/manifests/manifestInventory.xml',
                               'ingests/jq937jp0017/v0002/manifests/signatureCatalog.xml',
                               'ingests/jq937jp0017/v0002/manifests/versionAdditions.xml',
                               'ingests/jq937jp0017/v0002/manifests/versionInventory.xml',
                               'ingests/jq937jp0017/v0003',
                               'ingests/jq937jp0017/v0003/data',
                               'ingests/jq937jp0017/v0003/data/content',
                               'ingests/jq937jp0017/v0003/data/content/page-2.jpg',
                               'ingests/jq937jp0017/v0003/data/metadata',
                               'ingests/jq937jp0017/v0003/data/metadata/contentMetadata.xml',
                               'ingests/jq937jp0017/v0003/data/metadata/provenanceMetadata.xml',
                               'ingests/jq937jp0017/v0003/data/metadata/versionMetadata.xml',
                               'ingests/jq937jp0017/v0003/manifests',
                               'ingests/jq937jp0017/v0003/manifests/fileInventoryDifference.xml',
                               'ingests/jq937jp0017/v0003/manifests/manifestInventory.xml',
                               'ingests/jq937jp0017/v0003/manifests/signatureCatalog.xml',
                               'ingests/jq937jp0017/v0003/manifests/versionAdditions.xml',
                               'ingests/jq937jp0017/v0003/manifests/versionInventory.xml'
                             ])
  end
end
