require 'spec_helper'

feature "Export a digital object version from DOR" do
  #  In order to: tranfer files and metadata from DOR to SDR
  #  The application needs to: create a Bagit bag containing files and manifests

  scenario "Export content and metadata files for a new version" do
    # given: a workspace directory containing content and metadata subdirectories,
    #      : and a file inventory decribing the version's files,
    #      : and a signature catalog for the digital object
    # action: create a new Bagit container
    #       : with hard links to only new or modified files
    # outcome: Bagit bag containing only new or modified files

    (1..3).each do |version|
      vname = [nil,'v0001','v0002','v0003'][version]
      data_dir = @data.join(vname)
      inventory = FileInventory.read_xml_file(@manifests.join(vname),'version')
      case version
        when 1
          catalog = SignatureCatalog.new(:digital_object_id => inventory.digital_object_id)
        else
          catalog = SignatureCatalog.read_xml_file(@manifests.join(@vname[version-1]))
      end
      bag_dir = @temp.join('packages',vname)
      bag_dir.rmtree if bag_dir.exist?
      Bagger.new(inventory,catalog,bag_dir).fill_bag(:depositor,data_dir)
    end

    files = Array.new
    @temp.join('packages').find { |f| files << f.relative_path_from(@temp).to_s }
    files.sort.should == [
        "packages",
        "packages/v0001",
        "packages/v0001/bag-info.txt",
        "packages/v0001/bagit.txt",
        "packages/v0001/data",
        "packages/v0001/data/content",
        "packages/v0001/data/content/intro-1.jpg",
        "packages/v0001/data/content/intro-2.jpg",
        "packages/v0001/data/content/page-1.jpg",
        "packages/v0001/data/content/page-2.jpg",
        "packages/v0001/data/content/page-3.jpg",
        "packages/v0001/data/content/title.jpg",
        "packages/v0001/data/metadata",
        "packages/v0001/data/metadata/contentMetadata.xml",
        "packages/v0001/data/metadata/descMetadata.xml",
        "packages/v0001/data/metadata/identityMetadata.xml",
        "packages/v0001/data/metadata/provenanceMetadata.xml",
        "packages/v0001/data/metadata/versionMetadata.xml",
        "packages/v0001/manifest-md5.txt",
        "packages/v0001/manifest-sha1.txt",
        "packages/v0001/manifest-sha256.txt",
        "packages/v0001/tagmanifest-md5.txt",
        "packages/v0001/tagmanifest-sha1.txt",
        "packages/v0001/tagmanifest-sha256.txt",
        "packages/v0001/versionAdditions.xml",
        "packages/v0001/versionInventory.xml",
        "packages/v0002",
        "packages/v0002/bag-info.txt",
        "packages/v0002/bagit.txt",
        "packages/v0002/data",
        "packages/v0002/data/content",
        "packages/v0002/data/content/page-1.jpg",
        "packages/v0002/data/metadata",
        "packages/v0002/data/metadata/contentMetadata.xml",
        "packages/v0002/data/metadata/provenanceMetadata.xml",
        "packages/v0002/data/metadata/versionMetadata.xml",
        "packages/v0002/manifest-md5.txt",
        "packages/v0002/manifest-sha1.txt",
        "packages/v0002/manifest-sha256.txt",
        "packages/v0002/tagmanifest-md5.txt",
        "packages/v0002/tagmanifest-sha1.txt",
        "packages/v0002/tagmanifest-sha256.txt",
        "packages/v0002/versionAdditions.xml",
        "packages/v0002/versionInventory.xml",
        "packages/v0003",
        "packages/v0003/bag-info.txt",
        "packages/v0003/bagit.txt",
        "packages/v0003/data",
        "packages/v0003/data/content",
        "packages/v0003/data/content/page-2.jpg",
        "packages/v0003/data/metadata",
        "packages/v0003/data/metadata/contentMetadata.xml",
        "packages/v0003/data/metadata/provenanceMetadata.xml",
        "packages/v0003/data/metadata/versionMetadata.xml",
        "packages/v0003/manifest-md5.txt",
        "packages/v0003/manifest-sha1.txt",
        "packages/v0003/manifest-sha256.txt",
        "packages/v0003/tagmanifest-md5.txt",
        "packages/v0003/tagmanifest-sha1.txt",
        "packages/v0003/tagmanifest-sha256.txt",
        "packages/v0003/versionAdditions.xml",
        "packages/v0003/versionInventory.xml"
    ]
    @temp.join('packages').rmtree
  end
end