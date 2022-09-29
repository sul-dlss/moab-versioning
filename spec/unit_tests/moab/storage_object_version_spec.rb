# frozen_string_literal: true

describe Moab::StorageObjectVersion do
  let(:temp_dir_ingests) { temp_dir.join('ingests') }
  let(:temp_object_dir) { temp_dir_ingests.join(BARE_TEST_DRUID) }
  let(:existing_object_pathname) { ingests_dir.join(BARE_TEST_DRUID) }
  let(:existing_storage_object_version) do
    existing_storage_object = Moab::StorageObject.new(FULL_TEST_DRUID, existing_object_pathname)
    described_class.new(existing_storage_object, 2)
  end
  let(:temp_storage_object) { Moab::StorageObject.new(FULL_TEST_DRUID, temp_object_dir) }
  let(:version_with_manifest_errors) do
    bad_object_pathname = temp_dir.join(BARE_TEST_DRUID)
    bad_object_pathname.rmtree if bad_object_pathname.exist?
    bad_object_pathname.mkpath
    FileUtils.cp_r(existing_object_pathname.join('v0001').to_s, bad_object_pathname.join('v0001').to_s)
    object_with_manifest_errors = Moab::StorageObject.new(FULL_TEST_DRUID, bad_object_pathname)
    version_with_manifest_errors = object_with_manifest_errors.storage_object_version(1)
    new_manifest_file = version_with_manifest_errors.version_pathname.join('manifests', 'dummy1.xml')
    new_manifest_file.open('w') { |f| f.puts 'dummy' }
    new_metadata_file = version_with_manifest_errors.version_pathname.join('data', 'metadata', 'dummy2.xml')
    new_metadata_file.open('w') { |f| f.puts 'dummy' }
    version_with_manifest_errors
  end

  before do
    temp_object_dir.rmtree if temp_object_dir.exist?
  end

  after do
    temp_dir_ingests.rmtree if temp_dir_ingests.exist?
    temp_dir.join(BARE_TEST_DRUID).rmtree if temp_dir.join(BARE_TEST_DRUID).exist?
  end

  describe '#initialize' do
    let(:storage_object) { Moab::StorageObject.new(FULL_TEST_DRUID, temp_object_dir) }

    context 'when version argument is integer' do
      let(:version_id) { 2 }
      let(:storage_object_version) { described_class.new(storage_object, version_id) }

      it 'storage_object attribute is correct' do
        expect(storage_object_version.storage_object).to eq storage_object
      end

      it 'version_id attribute is numeric' do
        expect(storage_object_version.version_id).to eq version_id
      end
    end

    context 'when version argument is directory name' do
      let(:v0003) { described_class.new(storage_object, 'v0003') }

      it 'version_id attribute is numeric' do
        expect(v0003.version_id).to eq 3
      end
    end
  end

  describe '#composite_key' do
    it 'is the full druid with version suffix' do
      expect(existing_storage_object_version.composite_key).to eq('druid:jq937jp0017-v0002')
    end
  end

  describe '#find_signature' do
    it 'content file has expected signature fixity' do
      signature = existing_storage_object_version.find_signature('content', 'title.jpg')
      expected_sig_fixity = {
        size: '40873',
        md5: '1a726cd7963bd6d3ceb10a8c353ec166',
        sha1: '583220e0572640abcd3ddd97393d224e8053a6ad',
        sha256: '8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5'
      }
      expect(signature.fixity).to eq expected_sig_fixity
    end

    it 'content file with hyphen in file name has expected signature fixity' do
      signature = existing_storage_object_version.find_signature('content', 'page-1.jpg')
      expected_sig_fixity = {
        size: '32915',
        md5: 'c1c34634e2f18a354cd3e3e1574c3194',
        sha1: '0616a0bd7927328c364b2ea0b4a79c507ce915ed',
        sha256: 'b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0'
      }
      expect(signature.fixity).to eq expected_sig_fixity
    end

    it 'manifest file has expected signature size' do
      signature = existing_storage_object_version.find_signature('manifest', 'versionInventory.xml')
      exp_result = File.size(existing_storage_object_version.find_filepath('manifest', 'versionInventory.xml'))
      expect(signature.size).to eq exp_result
    end

    it 'non-existent file raises Moab::FileNotFoundException' do
      expect { existing_storage_object_version.find_signature('manifest', 'dummy.xml') }
        .to raise_exception Moab::FileNotFoundException
    end
  end

  describe '#find_filepath' do
    let(:exp_dir) { 'ingests/jq937jp0017' }

    it 'content file has expected path' do
      pathname = existing_storage_object_version.find_filepath('content', 'title.jpg')
      expect(pathname.to_s).to include "#{exp_dir}/v0001/data/content/title.jpg"
    end

    it 'content file with hyphen has expected path' do
      pathname = existing_storage_object_version.find_filepath('content', 'page-1.jpg')
      expect(pathname.to_s).to include "#{exp_dir}/v0002/data/content/page-1.jpg"
    end

    it 'manifest file has expected path' do
      pathname = existing_storage_object_version.find_filepath('manifest', 'versionInventory.xml')
      expect(pathname.to_s).to include "#{exp_dir}/v0002/manifests/versionInventory.xml"
    end

    it 'non-existent file raises Moab::FileNotFoundException' do
      expect { existing_storage_object_version.find_filepath('manifest', 'dummy.xml') }
        .to raise_exception Moab::FileNotFoundException
    end
  end

  describe '#find_filepath_using_signature' do
    let(:file_signature) do
      fixity_hash = {
        size: 40873,
        md5: '1a726cd7963bd6d3ceb10a8c353ec166',
        sha1: '583220e0572640abcd3ddd97393d224e8053a6ad'
      }
      Moab::FileSignature.new(fixity_hash)
    end

    it 'finds expected path' do
      storage_object_path = existing_storage_object_version.find_filepath_using_signature('content', file_signature).to_s
      expected_path = File.join('ingests', BARE_TEST_DRUID, 'v0001', 'data', 'content', 'title.jpg')
      expect(storage_object_path).to include expected_path
    end
  end

  describe '#file_pathname' do
    let(:exp_dir) { 'ingests/jq937jp0017/v0002' }

    it 'returns data file pathname' do
      pathname = existing_storage_object_version.file_pathname('content', 'title.jpg')
      expect(pathname.to_s).to include "#{exp_dir}/data/content/title.jpg"
    end

    it 'returns metadata file pathname' do
      pathname = existing_storage_object_version.file_pathname('metadata', 'descMetadata.xml')
      expect(pathname.to_s).to include "#{exp_dir}/data/metadata/descMetadata.xml"
    end

    it 'returns manifest file pathname' do
      pathname = existing_storage_object_version.file_pathname('manifest', 'signatureCatalog.xml')
      expect(pathname.to_s).to include "#{exp_dir}/manifests/signatureCatalog.xml"
    end
  end

  describe '#file_category_pathname' do
    let(:data_path) { File.join('derivatives', 'ingests', BARE_TEST_DRUID, 'v0002') }
    let(:content_path) { File.join(data_path, 'data', 'content') }
    let(:metadata_path) { File.join(data_path, 'data', 'metadata') }
    let(:manifests_path) { File.join(data_path, 'manifests') }

    it 'creates the data file paths' do
      expect(existing_storage_object_version.file_category_pathname('content').to_s).to include content_path
      expect(existing_storage_object_version.file_category_pathname('metadata').to_s).to include metadata_path
      expect(existing_storage_object_version.file_category_pathname('manifests').to_s).to include manifests_path
    end
  end

  describe '#file_inventory' do
    # TODO: test all allowed type values and disallowed type value, version_id = 0

    it "'version' returns instance of Moab::FileInventory" do
      expect(existing_storage_object_version.file_inventory('version')).to be_an_instance_of(Moab::FileInventory)
    end
  end

  describe '#signature_catalog' do
    # TODO: write better test

    it 'returns instance of Moab::SignatureCatalog' do
      expect(existing_storage_object_version.signature_catalog).to be_instance_of(Moab::SignatureCatalog)
    end
  end

  describe '#ingest_bag_data' do
    context 'with links (default)' do
      before do
        temp_storage_object_version = described_class.new(temp_storage_object, 1)
        temp_storage_object_version.ingest_bag_data(packages_dir.join('v0001'))
      end

      it 'puts the files in the ingest dir' do
        files = []
        temp_object_dir.find { |f| files << f.relative_path_from(temp_dir).to_s }
        expect(files.sort).to eq [
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
          'ingests/jq937jp0017/v0001/manifests/versionAdditions.xml',
          'ingests/jq937jp0017/v0001/manifests/versionInventory.xml'
        ]
      end
    end

    context 'without links' do
      before do
        temp_storage_object_version = described_class.new(temp_storage_object, 1)
        temp_storage_object_version.ingest_bag_data(packages_dir.join('v0001'), use_links: false)
      end

      it 'puts the files in the ingest dir' do
        files = []
        temp_object_dir.find { |f| files << f.relative_path_from(temp_dir).to_s }
        expect(files.sort).to eq [
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
          'ingests/jq937jp0017/v0001/manifests/versionAdditions.xml',
          'ingests/jq937jp0017/v0001/manifests/versionInventory.xml'
        ]
      end
    end
  end

  describe '#ingest_dir' do
    before do
      source_dir = packages_dir.join('v0001/data')
      temp_storage_object_version = described_class.new(temp_storage_object, 1)
      target_dir = temp_storage_object_version.version_pathname.join('data')
      use_links = true
      temp_storage_object_version.ingest_dir(source_dir, target_dir, use_links)
    end

    it 'result contains expected files' do
      files = []
      temp_object_dir.find { |f| files << f.relative_path_from(temp_dir).to_s }
      expect(files.sort).to eq [
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
        'ingests/jq937jp0017/v0001/data/metadata/versionMetadata.xml'
      ]
    end
  end

  describe '#ingest_file' do
    let(:temp_version_pathname) do
      temp_version_pathname = temp_storage_object_version.version_pathname
      temp_version_pathname.mkpath
      temp_version_pathname
    end
    let(:temp_storage_object_version) { described_class.new(temp_storage_object, 2) }

    it 'ingests single source files, cumulatively' do
      # ingest versionInventory.xml
      source_file = packages_dir.join('v0002').join('versionInventory.xml')
      temp_storage_object_version.ingest_file(source_file, temp_version_pathname)
      files = []
      temp_object_dir.find { |f| files << f.relative_path_from(temp_dir).to_s }
      expect(files.sort).to eq [
        'ingests/jq937jp0017',
        'ingests/jq937jp0017/v0002',
        'ingests/jq937jp0017/v0002/versionInventory.xml'
      ]

      # ingest versionAdditions.xml
      source_file = packages_dir.join('v0002').join('versionAdditions.xml')
      use_links = false
      temp_storage_object_version.ingest_file(source_file, temp_version_pathname, use_links)

      files = []
      temp_object_dir.find { |f| files << f.relative_path_from(temp_dir).to_s }
      expect(files.sort).to eq [
        'ingests/jq937jp0017',
        'ingests/jq937jp0017/v0002',
        'ingests/jq937jp0017/v0002/versionAdditions.xml',
        'ingests/jq937jp0017/v0002/versionInventory.xml'
      ]
    end
  end

  describe '#update_catalog' do
    let(:temp_storage_object_version) { described_class.new(temp_storage_object, 4) }
    let(:signature_catalog) { instance_double(Moab::SignatureCatalog.name) }
    let(:new_inventory) { instance_double(Moab::FileInventory.name) }

    before do
      allow(signature_catalog).to receive(:update).with(new_inventory, temp_storage_object_version.version_pathname.join('data'))
      allow(signature_catalog).to receive(:write_xml_file).with(temp_storage_object_version.version_pathname.join('manifests'))
    end

    it 'calls update and write_xml_file for Moab::SignatureCatalog' do
      temp_storage_object_version.update_catalog(signature_catalog, new_inventory)
      expect(signature_catalog)
        .to have_received(:update).with(new_inventory, temp_storage_object_version.version_pathname.join('data'))
      expect(signature_catalog)
        .to have_received(:write_xml_file).with(temp_storage_object_version.version_pathname.join('manifests'))
    end
  end

  describe '#generate_differences_report' do
    let(:old_inventory) { instance_double(Moab::FileInventory.name) }
    let(:new_inventory) { instance_double(Moab::FileInventory.name) }
    let(:mock_fid) { instance_double(Moab::FileInventoryDifference.name) }

    before do
      allow(Moab::FileInventoryDifference).to receive(:new).and_return(mock_fid)
      allow(mock_fid).to receive(:compare).with(old_inventory, new_inventory).and_return(mock_fid)
      allow(mock_fid).to receive(:write_xml_file)
    end

    it 'calls compare and write_xml_file for Moab::FileInventoryDifference' do
      existing_storage_object_version.generate_differences_report(old_inventory, new_inventory)
      expect(mock_fid).to have_received(:compare).with(old_inventory, new_inventory)
      expect(mock_fid).to have_received(:write_xml_file)
    end
  end

  describe '#generate_manifest_inventory' do
    let(:temp_storage_object_version) { described_class.new(temp_storage_object, 2) }
    let(:temp_version_pathname) { temp_storage_object_version.version_pathname }

    before do
      temp_version_pathname.mkpath
      vers_inv_file = packages_dir.join('v0002').join('versionInventory.xml')
      temp_storage_object_version.ingest_file(vers_inv_file, temp_version_pathname)
      vers_add_file = packages_dir.join('v0002').join('versionAdditions.xml')
      temp_storage_object_version.ingest_file(vers_add_file, temp_version_pathname)
    end

    it 'creates a FileInventory containing the manifest files' do
      temp_storage_object_version.generate_manifest_inventory
      expect(Moab::FileInventory.xml_pathname_exist?(temp_version_pathname.join('manifests'), 'manifests')).to be true
    end
  end

  describe '#verify_version_storage' do
    it 'true when object version is verified without errors' do
      verification_result = existing_storage_object_version.verify_version_storage
      expect(verification_result.verified).to be true
    end
  end

  describe '#verify_manifest_inventory' do
    context 'when files match' do
      let(:verification_result) { existing_storage_object_version.verify_manifest_inventory }

      it 'VerificationResult.verified is true' do
        expect(verification_result.verified).to be true
      end
    end

    context 'when files do not match' do
      let(:verification_result) { version_with_manifest_errors.verify_manifest_inventory }

      it 'VerificationResult.verified is false' do
        expect(verification_result.verified).to be false
      end

      it 'VerificationResult.to_hash has expected content' do
        detail_hash = verification_result.to_hash
        detail_hash['manifest_inventory']['details']['file_differences']['details'].delete('report_datetime')
        expect(JSON.parse(JSON.pretty_generate(detail_hash))).to eq JSON.parse(
          <<-JSON
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
    let(:verification_result) { existing_storage_object_version.verify_signature_catalog }

    context 'when signature catalog verifies cleanly' do
      it 'VerificationResult.verified is true' do
        expect(verification_result.verified).to be true
      end

      it 'VerificationResult.to_hash has expected content' do
        detail_hash = verification_result.to_hash(true)
        expect(detail_hash).to eq JSON.parse(
          <<-JSON
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
  end

  describe '#verify_version_inventory' do
    context 'when version inventory verifies cleanly' do
      let(:verification_result) { existing_storage_object_version.verify_version_inventory }

      it 'VerificationResult.verified is true' do
        expect(verification_result.verified).to be true
      end

      it 'VerificationResult.to_hash has expected content' do
        detail_hash = verification_result.to_hash(true)
        expect(detail_hash).to eq JSON.parse(
          <<-JSON
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
  end

  describe '#verify_version_additions' do
    context 'when files match' do
      let(:verification_result) { existing_storage_object_version.verify_version_additions }

      it 'VerificationResult.verified is true' do
        expect(verification_result.verified).to be true
      end
    end

    context 'when files do not match' do
      let(:verification_result) { version_with_manifest_errors.verify_version_additions }

      it 'VerificationResult.verified is false' do
        expect(verification_result.verified).to be false
      end

      it 'VerificationResult.to_hash has expected content' do
        detail_hash = verification_result.to_hash(true)
        detail_hash['version_additions']['details']['file_differences']['details'].delete('report_datetime')
        expect(JSON.parse(JSON.pretty_generate(detail_hash))).to eq JSON.parse(
          <<-JSON
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

  describe '#deactivate' do
    let(:version) do
      temp_object_dir.mkpath
      version_id = existing_storage_object_version.version_id
      FileUtils.cp_r existing_storage_object_version.version_pathname, temp_object_dir
      storage_obj = Moab::StorageObject.new(FULL_TEST_DRUID, temp_object_dir)
      storage_obj.storage_object_version(version_id)
    end
    let(:timestamp) { Time.now }
    let(:inactive_location) { temp_object_dir.join(timestamp.utc.iso8601.gsub(/[-:]/, '')) }

    it 'moves object version to the passed directory' do
      expect(version.exist?).to be true
      expect(Dir.exist?(inactive_location)).not_to be true

      version.deactivate(timestamp)

      expect(version.exist?).to be false
      expect(inactive_location.children.size).to eq 1
    end
  end
end
