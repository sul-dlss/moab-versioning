describe "Import digital object version to SDR" do
  #  In order to: ingest a new version of a digital object into SDR
  #  The application needs to: process a Bagit bag containing either a full set or subset of object files

  it "Create a new version storage folder" do
    # given: A Bagit bag containing a version of a digital object
    # action: Parse the file inventory for the version,
    #       : create the new version's storage folder,
    #       : copy the version's data files into storage,
    #       : update the object's signature catalog,
    #       : generate a version differences report,
    #       : and generate an inventory of all the manifest files
    # outcome: version storage folder

    ingests_dir = @temp.join('ingests')
    ingests_dir.rmtree if ingests_dir.exist?
    (1..3).each do |version|
      vname = [nil, 'v0001', 'v0002', 'v0003'][version]
      object_dir = ingests_dir.join(@obj)
      object_dir.mkpath
      unless object_dir.join("v000#{version}").exist?
        bag_dir = @packages.join(vname)
        Moab::StorageObject.new(@druid, object_dir).ingest_bag(bag_dir)
      end
    end

    files = Array.new
    ingests_dir.find { |f| files << f.relative_path_from(@temp).to_s }
    expect(files.sort).to eq([
                               "ingests",
                               "ingests/jq937jp0017",
                               "ingests/jq937jp0017/v0001",
                               "ingests/jq937jp0017/v0001/data",
                               "ingests/jq937jp0017/v0001/data/content",
                               "ingests/jq937jp0017/v0001/data/content/intro-1.jpg",
                               "ingests/jq937jp0017/v0001/data/content/intro-2.jpg",
                               "ingests/jq937jp0017/v0001/data/content/page-1.jpg",
                               "ingests/jq937jp0017/v0001/data/content/page-2.jpg",
                               "ingests/jq937jp0017/v0001/data/content/page-3.jpg",
                               "ingests/jq937jp0017/v0001/data/content/title.jpg",
                               "ingests/jq937jp0017/v0001/data/metadata",
                               "ingests/jq937jp0017/v0001/data/metadata/contentMetadata.xml",
                               "ingests/jq937jp0017/v0001/data/metadata/descMetadata.xml",
                               "ingests/jq937jp0017/v0001/data/metadata/identityMetadata.xml",
                               "ingests/jq937jp0017/v0001/data/metadata/provenanceMetadata.xml",
                               "ingests/jq937jp0017/v0001/data/metadata/versionMetadata.xml",
                               "ingests/jq937jp0017/v0001/manifests",
                               "ingests/jq937jp0017/v0001/manifests/fileInventoryDifference.xml",
                               "ingests/jq937jp0017/v0001/manifests/manifestInventory.xml",
                               "ingests/jq937jp0017/v0001/manifests/signatureCatalog.xml",
                               "ingests/jq937jp0017/v0001/manifests/versionAdditions.xml",
                               "ingests/jq937jp0017/v0001/manifests/versionInventory.xml",
                               "ingests/jq937jp0017/v0002",
                               "ingests/jq937jp0017/v0002/data",
                               "ingests/jq937jp0017/v0002/data/content",
                               "ingests/jq937jp0017/v0002/data/content/page-1.jpg",
                               "ingests/jq937jp0017/v0002/data/metadata",
                               "ingests/jq937jp0017/v0002/data/metadata/contentMetadata.xml",
                               "ingests/jq937jp0017/v0002/data/metadata/provenanceMetadata.xml",
                               "ingests/jq937jp0017/v0002/data/metadata/versionMetadata.xml",
                               "ingests/jq937jp0017/v0002/manifests",
                               "ingests/jq937jp0017/v0002/manifests/fileInventoryDifference.xml",
                               "ingests/jq937jp0017/v0002/manifests/manifestInventory.xml",
                               "ingests/jq937jp0017/v0002/manifests/signatureCatalog.xml",
                               "ingests/jq937jp0017/v0002/manifests/versionAdditions.xml",
                               "ingests/jq937jp0017/v0002/manifests/versionInventory.xml",
                               "ingests/jq937jp0017/v0003",
                               "ingests/jq937jp0017/v0003/data",
                               "ingests/jq937jp0017/v0003/data/content",
                               "ingests/jq937jp0017/v0003/data/content/page-2.jpg",
                               "ingests/jq937jp0017/v0003/data/metadata",
                               "ingests/jq937jp0017/v0003/data/metadata/contentMetadata.xml",
                               "ingests/jq937jp0017/v0003/data/metadata/provenanceMetadata.xml",
                               "ingests/jq937jp0017/v0003/data/metadata/versionMetadata.xml",
                               "ingests/jq937jp0017/v0003/manifests",
                               "ingests/jq937jp0017/v0003/manifests/fileInventoryDifference.xml",
                               "ingests/jq937jp0017/v0003/manifests/manifestInventory.xml",
                               "ingests/jq937jp0017/v0003/manifests/signatureCatalog.xml",
                               "ingests/jq937jp0017/v0003/manifests/versionAdditions.xml",
                               "ingests/jq937jp0017/v0003/manifests/versionInventory.xml"
                             ])
    ingests_dir.rmtree if ingests_dir.exist?
  end
end
