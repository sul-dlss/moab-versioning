require 'spec_helper'

feature "Create reconstructed digital object for a version" do
  #  In order to: disseminate a copy of a digital object version
  #  The application needs to: reconstruct the version's file structure from the storage location

  scenario "Generate a copy of a full version in a temp location" do
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
      vname = ['','v1','v2','v3'][version]
      bag_dir = reconstructs_dir.join(vname)
      unless bag_dir.exist?
        object_dir = @ingests.join(@obj)
        StorageObject.new(@druid,object_dir).reconstruct_version(version, bag_dir)
      end
    end

    files = Array.new
    reconstructs_dir.find { |f| files << f.relative_path_from(@temp).to_s }
    files.sort.should == [
        "reconstructs",
        "reconstructs/v1",
        "reconstructs/v1/bag-info.txt",
        "reconstructs/v1/bagit.txt",
        "reconstructs/v1/data",
        "reconstructs/v1/data/content",
        "reconstructs/v1/data/content/intro-1.jpg",
        "reconstructs/v1/data/content/intro-2.jpg",
        "reconstructs/v1/data/content/page-1.jpg",
        "reconstructs/v1/data/content/page-2.jpg",
        "reconstructs/v1/data/content/page-3.jpg",
        "reconstructs/v1/data/content/title.jpg",
        "reconstructs/v1/data/metadata",
        "reconstructs/v1/data/metadata/contentMetadata.xml",
        "reconstructs/v1/data/metadata/descMetadata.xml",
        "reconstructs/v1/data/metadata/identityMetadata.xml",
        "reconstructs/v1/data/metadata/provenanceMetadata.xml",
        "reconstructs/v1/data/metadata/versionMetadata.xml",
        "reconstructs/v1/manifest-md5.txt",
        "reconstructs/v1/manifest-sha1.txt",
        "reconstructs/v1/tagmanifest-md5.txt",
        "reconstructs/v1/tagmanifest-sha1.txt",
        "reconstructs/v1/versionInventory.xml",
        "reconstructs/v2",
        "reconstructs/v2/bag-info.txt",
        "reconstructs/v2/bagit.txt",
        "reconstructs/v2/data",
        "reconstructs/v2/data/content",
        "reconstructs/v2/data/content/page-1.jpg",
        "reconstructs/v2/data/content/page-2.jpg",
        "reconstructs/v2/data/content/page-3.jpg",
        "reconstructs/v2/data/content/title.jpg",
        "reconstructs/v2/data/metadata",
        "reconstructs/v2/data/metadata/contentMetadata.xml",
        "reconstructs/v2/data/metadata/descMetadata.xml",
        "reconstructs/v2/data/metadata/identityMetadata.xml",
        "reconstructs/v2/data/metadata/provenanceMetadata.xml",
        "reconstructs/v2/data/metadata/versionMetadata.xml",
        "reconstructs/v2/manifest-md5.txt",
        "reconstructs/v2/manifest-sha1.txt",
        "reconstructs/v2/tagmanifest-md5.txt",
        "reconstructs/v2/tagmanifest-sha1.txt",
        "reconstructs/v2/versionInventory.xml",
        "reconstructs/v3",
        "reconstructs/v3/bag-info.txt",
        "reconstructs/v3/bagit.txt",
        "reconstructs/v3/data",
        "reconstructs/v3/data/content",
        "reconstructs/v3/data/content/page-1.jpg",
        "reconstructs/v3/data/content/page-2.jpg",
        "reconstructs/v3/data/content/page-3.jpg",
        "reconstructs/v3/data/content/page-4.jpg",
        "reconstructs/v3/data/content/title.jpg",
        "reconstructs/v3/data/metadata",
        "reconstructs/v3/data/metadata/contentMetadata.xml",
        "reconstructs/v3/data/metadata/descMetadata.xml",
        "reconstructs/v3/data/metadata/identityMetadata.xml",
        "reconstructs/v3/data/metadata/provenanceMetadata.xml",
        "reconstructs/v3/data/metadata/versionMetadata.xml",
        "reconstructs/v3/manifest-md5.txt",
        "reconstructs/v3/manifest-sha1.txt",
        "reconstructs/v3/tagmanifest-md5.txt",
        "reconstructs/v3/tagmanifest-sha1.txt",
        "reconstructs/v3/versionInventory.xml"
    ]
    reconstructs_dir.rmtree if reconstructs_dir.exist?
  end

end