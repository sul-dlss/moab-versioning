# frozen_string_literal: true

describe Moab::StorageObjectVersion do
  before(:all) do
    @temp_ingests = @temp.join("ingests")
    @temp_object_dir = @temp_ingests.join(@obj)
    @existing_object_pathname = @ingests.join(@obj)
    @existing_storage_object = Moab::StorageObject.new(@druid, @existing_object_pathname)
    @existing_storage_object_version = described_class.new(@existing_storage_object, 2)
    @temp_storage_object = Moab::StorageObject.new(@druid, @temp_object_dir)
    @temp_package_pathname = @temp.join("packages")
    bad_object_pathname = @temp.join(@obj)
    bad_object_pathname.rmtree if bad_object_pathname.exist?
    bad_object_pathname.mkpath
    FileUtils.cp_r(@existing_object_pathname.join('v0001').to_s, bad_object_pathname.join('v0001').to_s)
    @object_with_manifest_errors = Moab::StorageObject.new(@druid, bad_object_pathname)
    @version_with_manifest_errors = @object_with_manifest_errors.storage_object_version(1)
    new_manifest_file = @version_with_manifest_errors.version_pathname.join('manifests', 'dummy1.xml')
    new_manifest_file.open('w') { |f| f.puts "dummy" }
    new_metadata_file = @version_with_manifest_errors.version_pathname.join('data', 'metadata', 'dummy2.xml')
    new_metadata_file.open('w') { |f| f.puts "dummy" }
  end

  after(:all) do
    @temp_ingests.rmtree if @temp_ingests.exist?
    @temp.join(@obj).rmtree if @temp.join(@obj).exist?
  end

  before do
    @temp_object_dir.rmtree if @temp_object_dir.exist?
  end

  describe '#initialize' do
    let(:storage_object) { Moab::StorageObject.new(@druid, @temp_object_dir) }

    it 'numeric version' do
      version_id = 2
      storage_object_version = described_class.new(storage_object, version_id)
      expect(storage_object_version.storage_object).to eq storage_object
      expect(storage_object_version.version_id).to eq version_id
    end

    it 'version as directory name' do
      v0003 = described_class.new(storage_object, 'v0003')
      expect(v0003.version_id).to eq 3
    end
  end

  specify '#composite_key' do
    expect(@existing_storage_object_version.composite_key).to eq("druid:jq937jp0017-v0002")
  end

  describe '#find_signature' do
    it 'content' do
      signature = @existing_storage_object_version.find_signature('content', 'title.jpg')
      expected_sig_fixity = {
        size: "40873",
        md5: "1a726cd7963bd6d3ceb10a8c353ec166",
        sha1: "583220e0572640abcd3ddd97393d224e8053a6ad",
        sha256: "8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"
      }
      expect(signature.fixity).to eq expected_sig_fixity
    end

    it 'content with hyphen in file name' do
      signature = @existing_storage_object_version.find_signature('content', 'page-1.jpg')
      expected_sig_fixity = {
        size: "32915",
        md5: "c1c34634e2f18a354cd3e3e1574c3194",
        sha1: "0616a0bd7927328c364b2ea0b4a79c507ce915ed",
        sha256: "b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0"
      }
      expect(signature.fixity).to eq expected_sig_fixity
    end

    it 'manifest' do
      signature = @existing_storage_object_version.find_signature('manifest', 'versionInventory.xml')
      exp_result = File.size(@existing_storage_object_version.find_filepath('manifest', 'versionInventory.xml'))
      expect(signature.size).to eq exp_result
    end

    it 'non-existent file raises Moab::FileNotFoundException' do
      expect { @existing_storage_object_version.find_signature('manifest', 'dummy.xml') }
        .to raise_exception Moab::FileNotFoundException
    end
  end

  describe '#find_filepath' do
    let(:exp_dir) { "ingests/jq937jp0017" }

    it 'content file' do
      pathname = @existing_storage_object_version.find_filepath('content', 'title.jpg')
      expect(pathname.to_s).to include "#{exp_dir}/v0001/data/content/title.jpg"
    end

    it 'content file with hyphen' do
      pathname = @existing_storage_object_version.find_filepath('content', 'page-1.jpg')
      expect(pathname.to_s).to include "#{exp_dir}/v0002/data/content/page-1.jpg"
    end

    it 'manifest file' do
      pathname = @existing_storage_object_version.find_filepath('manifest', 'versionInventory.xml')
      expect(pathname.to_s).to include "#{exp_dir}/v0002/manifests/versionInventory.xml"
    end

    it 'non-existent file raises Moab::FileNotFoundException' do
      expect { @existing_storage_object_version.find_filepath('manifest', 'dummy.xml') }
        .to raise_exception Moab::FileNotFoundException
    end
  end

  specify '#find_filepath_using_signature' do
    fixity_hash = {
      size: 40873,
      md5: "1a726cd7963bd6d3ceb10a8c353ec166",
      sha1: "583220e0572640abcd3ddd97393d224e8053a6ad"
    }
    file_signature = Moab::FileSignature.new(fixity_hash)
    title_image = File.join('ingests', 'jq937jp0017', 'v0001', 'data', 'content', 'title.jpg')
    storage_object_path = @existing_storage_object_version.find_filepath_using_signature('content', file_signature).to_s
    expect(storage_object_path).to include title_image
  end

  describe '#file_pathname' do
    let(:exp_dir) { 'ingests/jq937jp0017/v0002' }

    it 'data file' do
      pathname = @existing_storage_object_version.file_pathname('content', 'title.jpg')
      expect(pathname.to_s).to include "#{exp_dir}/data/content/title.jpg"
    end

    it 'metadata file' do
      pathname = @existing_storage_object_version.file_pathname('metadata', 'descMetadata.xml')
      expect(pathname.to_s).to include "#{exp_dir}/data/metadata/descMetadata.xml"
    end

    it 'manifest file' do
      pathname = @existing_storage_object_version.file_pathname('manifest', 'signatureCatalog.xml')
      expect(pathname.to_s).to include "#{exp_dir}/manifests/signatureCatalog.xml"
    end
  end

  describe '#file_category_pathname' do
    let(:data_path) { File.join('derivatives', 'ingests', 'jq937jp0017', 'v0002') }
    let(:content_path) { File.join(data_path, 'data', 'content') }
    let(:metadata_path) { File.join(data_path, 'data', 'metadata') }
    let(:manifests_path) { File.join(data_path, 'manifests') }

    it 'creates the data file paths' do
      expect(@existing_storage_object_version.file_category_pathname('content').to_s).to include content_path
      expect(@existing_storage_object_version.file_category_pathname('metadata').to_s).to include metadata_path
      expect(@existing_storage_object_version.file_category_pathname('manifests').to_s).to include manifests_path
    end
  end

  specify '#file_inventory' do
    # TODO: test all allowed type values and disallowed type value, version_id = 0
    expect(@existing_storage_object_version.file_inventory('version')).to be_an_instance_of(Moab::FileInventory)
  end

  specify '#signature_catalog' do
    # TODO: write better test
    expect(@existing_storage_object_version.signature_catalog).to be_instance_of(Moab::SignatureCatalog)
  end

  specify '#ingest_bag_data' do
    temp_storage_object_version = described_class.new(@temp_storage_object, 1)
    temp_storage_object_version.ingest_bag_data(@packages.join("v0001"))
    files = []
    @temp_object_dir.find { |f| files << f.relative_path_from(@temp).to_s }
    expect(files.sort).to eq [
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
      "ingests/jq937jp0017/v0001/manifests/versionAdditions.xml",
      "ingests/jq937jp0017/v0001/manifests/versionInventory.xml"
    ]
  end

  specify '#ingest_dir' do
    source_dir = @packages.join("v0001/data")
    temp_storage_object_version = described_class.new(@temp_storage_object, 1)
    target_dir = temp_storage_object_version.version_pathname.join('data')
    use_links = true
    temp_storage_object_version.ingest_dir(source_dir, target_dir, use_links)
    files = []
    @temp_object_dir.find { |f| files << f.relative_path_from(@temp).to_s }
    expect(files.sort).to eq [
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
      "ingests/jq937jp0017/v0001/data/metadata/versionMetadata.xml"
    ]
  end

  describe '#ingest_file' do
    it 'versionInventory.xml' do
      temp_storage_object_version = described_class.new(@temp_storage_object, 2)
      temp_version_pathname = temp_storage_object_version.version_pathname
      temp_version_pathname.mkpath
      source_file = @packages.join("v0002").join('versionInventory.xml')

      temp_storage_object_version.ingest_file(source_file, temp_version_pathname)

      files = []
      @temp_object_dir.find { |f| files << f.relative_path_from(@temp).to_s }
      expect(files.sort).to eq [
        "ingests/jq937jp0017",
        "ingests/jq937jp0017/v0002",
        "ingests/jq937jp0017/v0002/versionInventory.xml"
      ]

      # now ingest versionAdditions file
      source_file = @packages.join("v0002").join('versionAdditions.xml')
      use_links = false
      temp_storage_object_version.ingest_file(source_file, temp_version_pathname, use_links)

      files = []
      @temp_object_dir.find { |f| files << f.relative_path_from(@temp).to_s }
      expect(files.sort).to eq [
        "ingests/jq937jp0017",
        "ingests/jq937jp0017/v0002",
        "ingests/jq937jp0017/v0002/versionAdditions.xml",
        "ingests/jq937jp0017/v0002/versionInventory.xml"
      ]
    end
  end

  specify '#update_catalog' do
    temp_storage_object_version = described_class.new(@temp_storage_object, 4)
    signature_catalog = double(Moab::SignatureCatalog.name)
    new_inventory = double(Moab::FileInventory.name)

    expect(signature_catalog).to receive(:update).with(new_inventory, temp_storage_object_version.version_pathname.join('data'))
    expect(signature_catalog).to receive(:write_xml_file).with(temp_storage_object_version.version_pathname.join('manifests'))
    temp_storage_object_version.update_catalog(signature_catalog, new_inventory)
  end

  specify '#generate_differences_report' do
    old_inventory = double(Moab::FileInventory.name)
    new_inventory = double(Moab::FileInventory.name)
    mock_fid = double(Moab::FileInventoryDifference.name)

    expect(Moab::FileInventoryDifference).to receive(:new).and_return(mock_fid)
    expect(mock_fid).to receive(:compare).with(old_inventory, new_inventory).and_return(mock_fid)
    expect(mock_fid).to receive(:write_xml_file)
    @existing_storage_object_version.generate_differences_report(old_inventory, new_inventory)
  end

  specify '#generate_manifest_inventory' do
    temp_storage_object_version = described_class.new(@temp_storage_object, 2)
    temp_version_pathname = temp_storage_object_version.version_pathname
    temp_version_pathname.mkpath
    vers_inv_file = @packages.join("v0002").join('versionInventory.xml')
    temp_storage_object_version.ingest_file(vers_inv_file, temp_version_pathname)
    vers_add_file = @packages.join("v0002").join('versionAdditions.xml')
    temp_storage_object_version.ingest_file(vers_add_file, temp_version_pathname)

    temp_storage_object_version.generate_manifest_inventory
    expect(Moab::FileInventory.xml_pathname_exist?(temp_version_pathname.join('manifests'), 'manifests')).to eq true
  end

  specify '#verify_version_storage' do
    result = @existing_storage_object_version.verify_version_storage
    expect(result.verified).to eq true
  end

  describe '#verify_manifest_inventory' do
    it 'when files match, VerificationResult.verified is true' do
      result = @existing_storage_object_version.verify_manifest_inventory
      expect(result.verified).to eq true
    end

    context 'when files do not match' do
      before(:all) do
        @result = @version_with_manifest_errors.verify_manifest_inventory
      end

      it 'VerificationResult.verified is false' do
        expect(@result.verified).to eq false
      end

      it 'VerificationResult.to_hash has expected content' do
        detail_hash = @result.to_hash
        detail_hash['manifest_inventory']['details']['file_differences']['details'].delete('report_datetime')
        expect(JSON.parse(JSON.pretty_generate(detail_hash))).to eq JSON.parse(<<-JSON
          {
          "manifest_inventory": {
            "verified": false,
            "details": {
              "composite_key": {
                "verified": true
              },
              "manifests_group": {
                "verified": true
              },
              "file_differences": {
                "verified": false,
                "details": {
                  "digital_object_id": "druid:jq937jp0017",
                  "difference_count": 1,
                  "basis": "v1",
                  "other": "#{File.expand_path('..', fixtures_directory)}/temp/jq937jp0017/v0001/manifests",
                  "group_differences": {
                    "manifests": {
                      "group_id": "manifests",
                      "difference_count": 1,
                      "identical": 4,
                      "added": 1,
                      "subsets": {
                        "added": {
                          "change": "added",
                          "count": 1,
                          "files": {
                            "0": {
                              "change": "added",
                              "basis_path": "",
                              "other_path": "dummy1.xml",
                              "signatures": {
                                "0": {
                                  "size": 6,
                                  "md5": "f02e326f800ee26f04df7961adbf7c0a",
                                  "sha1": "f161ebd29699d93411cec0915c5133c0f3229a28",
                                  "sha256": "d3eb539a556352f3f47881d71fb0e5777b2f3e9a4251d283c18c67ce996774b7"
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        JSON
                                                                              )
      end
    end
  end

  describe '#verify_signature_catalog' do
    before(:all) do
      @result = @existing_storage_object_version.verify_signature_catalog
    end

    it 'VerificationResult.verified is true' do
      expect(@result.verified).to eq true
    end

    it 'VerificationResult.to_hash has expected content' do
      detail_hash = @result.to_hash(true)
      expect(detail_hash).to eq JSON.parse(<<-JSON
        {
          "signature_catalog": {
            "verified": true,
            "details": {
              "signature_key": {
                "verified": true,
                "details": {
                  "found": "druid:jq937jp0017-v0002",
                  "expected": "druid:jq937jp0017-v0002"
                }
              },
              "storage_location": {
                "verified": true,
                "details": {
                  "found": 15,
                  "expected": 15
                }
              }
            }
          }
        }
      JSON
                                          )
    end
  end

  describe '#verify_version_inventory' do
    before(:all) do
      @result = @existing_storage_object_version.verify_version_inventory
    end

    it 'VerificationResult.verified is true' do
      expect(@result.verified).to eq true
    end

    it 'VerificationResult.to_hash has expected content' do
      detail_hash = @result.to_hash(true)
      expect(detail_hash).to eq JSON.parse(<<-JSON
        {
          "version_inventory": {
            "verified": true,
            "details": {
              "inventory_key": {
                "verified": true,
                "details": {
                  "found": "druid:jq937jp0017-v0002",
                  "expected": "druid:jq937jp0017-v0002"
                }
              },
              "signature_key": {
                "verified": true,
                "details": {
                  "found": "druid:jq937jp0017-v0002",
                  "expected": "druid:jq937jp0017-v0002"
                }
              },
              "catalog_entry": {
                "verified": true,
                "details": {
                  "found": 9,
                  "expected": 9
                }
              }
            }
          }
        }
      JSON
                                          )
    end
  end

  describe '#verify_version_additions' do
    it 'when files match, VerificationResult.verified is true' do
      result = @existing_storage_object_version.verify_version_additions
      expect(result.verified).to eq true
    end

    context 'when files do not match' do
      before(:all) do
        @result = @version_with_manifest_errors.verify_version_additions
      end

      it 'VerificationResult.verified is false' do
        expect(@result.verified).to eq false
      end

      it 'VerificationResult.to_hash has expected content' do
        detail_hash = @result.to_hash(true)
        detail_hash['version_additions']['details']['file_differences']['details'].delete('report_datetime')
        expect(JSON.parse(JSON.pretty_generate(detail_hash))).to eq JSON.parse(<<-JSON
          {
            "version_additions": {
            "verified": false,
            "details": {
              "composite_key": {
                "verified": true,
                "details": {
                  "found": "druid:jq937jp0017-v0001",
                  "expected": "druid:jq937jp0017-v0001"
                }
              },
              "file_differences": {
                "verified": false,
                "details": {
                  "digital_object_id": "druid:jq937jp0017|",
                  "difference_count": 1,
                  "basis": "v1",
                  "other": "#{File.expand_path('..', fixtures_directory)}/temp/jq937jp0017/v0001/data/content|#{File.expand_path('..', fixtures_directory)}/temp/jq937jp0017/v0001/data/metadata",
                  "group_differences": {
                    "content": {
                      "group_id": "content",
                      "difference_count": 0,
                      "identical": 6
                    },
                    "metadata": {
                      "group_id": "metadata",
                      "difference_count": 1,
                      "identical": 5,
                      "added": 1,
                      "subsets": {
                        "added": {
                          "change": "added",
                          "count": 1,
                          "files": {
                            "0": {
                              "change": "added",
                              "basis_path": "",
                              "other_path": "dummy2.xml",
                              "signatures": {
                                "0": {
                                  "size": 6,
                                  "md5": "f02e326f800ee26f04df7961adbf7c0a",
                                  "sha1": "f161ebd29699d93411cec0915c5133c0f3229a28",
                                  "sha256": "d3eb539a556352f3f47881d71fb0e5777b2f3e9a4251d283c18c67ce996774b7"
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        JSON
                                                                              )
      end
    end
  end

  specify '#deactivate' do
    # create an object version in a temp location by copying from ingests location
    @temp_object_dir.mkpath
    version_id = @existing_storage_object_version.version_id
    FileUtils.cp_r @existing_storage_object_version.version_pathname, @temp_object_dir
    so = Moab::StorageObject.new(@druid, @temp_object_dir)
    version = so.storage_object_version(version_id)
    timestamp = Time.now
    expect(version.exist?).to eq true
    version.deactivate(timestamp)
    expect(version.exist?).to eq false
    inactive_location = @temp_object_dir.join(timestamp.utc.iso8601.gsub(/[-:]/, ''))
    expect(inactive_location.children.size).to eq 1
  end
end
