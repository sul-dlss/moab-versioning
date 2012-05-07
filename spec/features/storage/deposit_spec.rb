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
      vname = ['','v1','v2','v3'][version]
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
      Bagger.new(inventory,catalog,data_dir,bag_dir).fill_bag(:depositor)
    end

    files = Array.new
    @temp.join('packages').find { |f| files << f.relative_path_from(@temp).to_s }
    files.sort.should == [
        "packages",
        "packages/v1",
        "packages/v1/bag-info.txt",
        "packages/v1/bagit.txt",
        "packages/v1/data",
        "packages/v1/data/content",
        "packages/v1/data/content/intro-1.jpg",
        "packages/v1/data/content/intro-2.jpg",
        "packages/v1/data/content/page-1.jpg",
        "packages/v1/data/content/page-2.jpg",
        "packages/v1/data/content/page-3.jpg",
        "packages/v1/data/content/title.jpg",
        "packages/v1/data/metadata",
        "packages/v1/data/metadata/contentMetadata.xml",
        "packages/v1/data/metadata/descMetadata.xml",
        "packages/v1/data/metadata/identityMetadata.xml",
        "packages/v1/data/metadata/provenanceMetadata.xml",
        "packages/v1/data/metadata/versionMetadata.xml",
        "packages/v1/manifest-md5.txt",
        "packages/v1/manifest-sha1.txt",
        "packages/v1/tagmanifest-md5.txt",
        "packages/v1/tagmanifest-sha1.txt",
        "packages/v1/versionAdditions.xml",
        "packages/v1/versionInventory.xml",
        "packages/v2",
        "packages/v2/bag-info.txt",
        "packages/v2/bagit.txt",
        "packages/v2/data",
        "packages/v2/data/content",
        "packages/v2/data/content/page-1.jpg",
        "packages/v2/data/metadata",
        "packages/v2/data/metadata/contentMetadata.xml",
        "packages/v2/data/metadata/provenanceMetadata.xml",
        "packages/v2/data/metadata/versionMetadata.xml",
        "packages/v2/manifest-md5.txt",
        "packages/v2/manifest-sha1.txt",
        "packages/v2/tagmanifest-md5.txt",
        "packages/v2/tagmanifest-sha1.txt",
        "packages/v2/versionAdditions.xml",
        "packages/v2/versionInventory.xml",
        "packages/v3",
        "packages/v3/bag-info.txt",
        "packages/v3/bagit.txt",
        "packages/v3/data",
        "packages/v3/data/content",
        "packages/v3/data/content/page-2.jpg",
        "packages/v3/data/metadata",
        "packages/v3/data/metadata/contentMetadata.xml",
        "packages/v3/data/metadata/provenanceMetadata.xml",
        "packages/v3/data/metadata/versionMetadata.xml",
        "packages/v3/manifest-md5.txt",
        "packages/v3/manifest-sha1.txt",
        "packages/v3/tagmanifest-md5.txt",
        "packages/v3/tagmanifest-sha1.txt",
        "packages/v3/versionAdditions.xml",
        "packages/v3/versionInventory.xml"
    ]
    @temp.join('packages').rmtree
  end
end