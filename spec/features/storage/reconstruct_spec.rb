describe "Create reconstructed digital object for a version" do
  #  In order to: disseminate a copy of a digital object version
  #  The application needs to: reconstruct the version's file structure from the storage location

  it "Generate a copy of a full version in a temp location" do
    # given: the repository storage location containing the files from all the object versions
    #      : the file inventory for the desired version
    #      : the file signature catalog for the object
    # action: copy (link) files to the temp location,
    #       : using the signature catalog to locate files
    #       : and the version's file inventory to provide original filenames
    # outcome: a temp folder containing the version's files

    reconstructs_dir = @temp.join('reconstructs')
    reconstructs_dir.rmtree if reconstructs_dir.exist?
    (1..3).each do |version|
      vname = [nil,'v0001','v0002','v0003'][version]
      bag_dir = reconstructs_dir.join(vname)
      unless bag_dir.exist?
        object_dir = @ingests.join(@obj)
        Moab::StorageObject.new(@druid,object_dir).reconstruct_version(version, bag_dir)
      end
    end

    files = Array.new
    reconstructs_dir.find { |f| files << f.relative_path_from(@temp).to_s }
    expect(files.sort).to eq([
        "reconstructs",
        "reconstructs/v0001",
        "reconstructs/v0001/bag-info.txt",
        "reconstructs/v0001/bagit.txt",
        "reconstructs/v0001/data",
        "reconstructs/v0001/data/content",
        "reconstructs/v0001/data/content/intro-1.jpg",
        "reconstructs/v0001/data/content/intro-2.jpg",
        "reconstructs/v0001/data/content/page-1.jpg",
        "reconstructs/v0001/data/content/page-2.jpg",
        "reconstructs/v0001/data/content/page-3.jpg",
        "reconstructs/v0001/data/content/title.jpg",
        "reconstructs/v0001/data/metadata",
        "reconstructs/v0001/data/metadata/contentMetadata.xml",
        "reconstructs/v0001/data/metadata/descMetadata.xml",
        "reconstructs/v0001/data/metadata/identityMetadata.xml",
        "reconstructs/v0001/data/metadata/provenanceMetadata.xml",
        "reconstructs/v0001/data/metadata/versionMetadata.xml",
        "reconstructs/v0001/manifest-md5.txt",
        "reconstructs/v0001/manifest-sha1.txt",
        "reconstructs/v0001/manifest-sha256.txt",
        "reconstructs/v0001/tagmanifest-md5.txt",
        "reconstructs/v0001/tagmanifest-sha1.txt",
        "reconstructs/v0001/tagmanifest-sha256.txt",
        "reconstructs/v0001/versionInventory.xml",
        "reconstructs/v0002",
        "reconstructs/v0002/bag-info.txt",
        "reconstructs/v0002/bagit.txt",
        "reconstructs/v0002/data",
        "reconstructs/v0002/data/content",
        "reconstructs/v0002/data/content/page-1.jpg",
        "reconstructs/v0002/data/content/page-2.jpg",
        "reconstructs/v0002/data/content/page-3.jpg",
        "reconstructs/v0002/data/content/title.jpg",
        "reconstructs/v0002/data/metadata",
        "reconstructs/v0002/data/metadata/contentMetadata.xml",
        "reconstructs/v0002/data/metadata/descMetadata.xml",
        "reconstructs/v0002/data/metadata/identityMetadata.xml",
        "reconstructs/v0002/data/metadata/provenanceMetadata.xml",
        "reconstructs/v0002/data/metadata/versionMetadata.xml",
        "reconstructs/v0002/manifest-md5.txt",
        "reconstructs/v0002/manifest-sha1.txt",
        "reconstructs/v0002/manifest-sha256.txt",
        "reconstructs/v0002/tagmanifest-md5.txt",
        "reconstructs/v0002/tagmanifest-sha1.txt",
        "reconstructs/v0002/tagmanifest-sha256.txt",
        "reconstructs/v0002/versionInventory.xml",
        "reconstructs/v0003",
        "reconstructs/v0003/bag-info.txt",
        "reconstructs/v0003/bagit.txt",
        "reconstructs/v0003/data",
        "reconstructs/v0003/data/content",
        "reconstructs/v0003/data/content/page-1.jpg",
        "reconstructs/v0003/data/content/page-2.jpg",
        "reconstructs/v0003/data/content/page-3.jpg",
        "reconstructs/v0003/data/content/page-4.jpg",
        "reconstructs/v0003/data/content/title.jpg",
        "reconstructs/v0003/data/metadata",
        "reconstructs/v0003/data/metadata/contentMetadata.xml",
        "reconstructs/v0003/data/metadata/descMetadata.xml",
        "reconstructs/v0003/data/metadata/identityMetadata.xml",
        "reconstructs/v0003/data/metadata/provenanceMetadata.xml",
        "reconstructs/v0003/data/metadata/versionMetadata.xml",
        "reconstructs/v0003/manifest-md5.txt",
        "reconstructs/v0003/manifest-sha1.txt",
        "reconstructs/v0003/manifest-sha256.txt",
        "reconstructs/v0003/tagmanifest-md5.txt",
        "reconstructs/v0003/tagmanifest-sha1.txt",
        "reconstructs/v0003/tagmanifest-sha256.txt",
        "reconstructs/v0003/versionInventory.xml"
    ])
    reconstructs_dir.rmtree if reconstructs_dir.exist?
  end

end
