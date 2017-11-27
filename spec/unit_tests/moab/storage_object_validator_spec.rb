require 'spec_helper'
RSpec.describe Moab::StorageObjectValidator do
  let(:druid1) { 'xx000xx0000'}
  let(:druid_path1) { 'spec/fixtures/bad_root01/bad_moab_storage_trunk/xx/000/xx/0000/xx000xx0000' }
  let(:storage_obj1) { Moab::StorageObject.new(druid1, druid_path1) }
  let(:storage_obj_validator1) { described_class.new(storage_obj1) }

  describe '#initialize' do
    it "sets storage_obj_path" do
      storage_obj_validator = described_class.new(storage_obj1)
      expect(storage_obj_validator.storage_obj_path.to_s).to eq druid_path1
    end
  end
  context '#validation_errors' do
    let(:verification_array) { storage_obj_validator1.validation_errors }

    it 'returns an Array of Hashes' do
      expect(verification_array).to be_kind_of Array
      expect(verification_array.first).to be_kind_of Hash
    end

    context "invalid moab" do
      context 'under version directory' do
        it 'has missing items' do
          expect(verification_array).to include(Moab::StorageObjectValidator::MISSING_DIR => "Missing directory: [\"data\", \"manifests\"] Version: v0001")
        end
        it 'has unexpected directory' do
          expect(verification_array).to include(Moab::StorageObjectValidator::EXTRA_CHILD_DETECTED =>"Unexpected item in path: [\"extra_dir\"] Version: v0002")
        end
        it 'has unexpected file' do
          expect(verification_array).to include(Moab::StorageObjectValidator::EXTRA_CHILD_DETECTED =>"Unexpected item in path: [\"extra_file.txt\"] Version: v0003")
        end
        it 'has missing data directory' do
          expect(verification_array).to include(Moab::StorageObjectValidator::MISSING_DIR =>"Missing directory: [\"data\"] Version: v0004")
        end
      end
      context 'under data directory' do
        it 'has unexpected file' do
          expect(verification_array).to include(Moab::StorageObjectValidator::EXTRA_CHILD_DETECTED =>"Unexpected item in path: [\"extra_file.txt\"] Version: v0005")
        end
        it 'has missing metadata directory' do
          expect(verification_array).to include(Moab::StorageObjectValidator::MISSING_DIR =>"Missing directory: [\"metadata\"] Version: v0006")
        end
        context 'content directory' do
          # TODO: if we permanently allow data/content to have sub-dirs, remove this test
          # it 'must only contain files' do
          #   expect(verification_array).to include(Moab::StorageObjectValidator::CONTENT_SUB_DIRS_DETECTED =>"Version v0007: content directory should only contain files, not directories")
          # end
          it 'must contain files' do
            expect(verification_array).to include(Moab::StorageObjectValidator::NO_FILES_IN_CONTENT_DIR=>"Version v0009: No files present in content dir")
          end
          it 'contains directories with disallowed names' do
            # vnnnn
            expect(verification_array).to include(Moab::StorageObjectValidator::BAD_SUB_DIR_IN_CONTENT_DIR=>"Version v0011: content directory has forbidden sub-directory name: vnnnn or [\"data\", \"manifests\", \"content\", \"metadata\"]")
            # manifests
            expect(verification_array).to include(Moab::StorageObjectValidator::BAD_SUB_DIR_IN_CONTENT_DIR=>"Version v0012: content directory has forbidden sub-directory name: vnnnn or [\"data\", \"manifests\", \"content\", \"metadata\"]")
            # data
            expect(verification_array).to include(Moab::StorageObjectValidator::BAD_SUB_DIR_IN_CONTENT_DIR=>"Version v0013: content directory has forbidden sub-directory name: vnnnn or [\"data\", \"manifests\", \"content\", \"metadata\"]")
            # content
            expect(verification_array).to include(Moab::StorageObjectValidator::BAD_SUB_DIR_IN_CONTENT_DIR=>"Version v0014: content directory has forbidden sub-directory name: vnnnn or [\"data\", \"manifests\", \"content\", \"metadata\"]")
            # metadata
            expect(verification_array).to include(Moab::StorageObjectValidator::BAD_SUB_DIR_IN_CONTENT_DIR=>"Version v0015: content directory has forbidden sub-directory name: vnnnn or [\"data\", \"manifests\", \"content\", \"metadata\"]")
          end
          it 'allows multiple level sub directories' do
            druid = 'gg000gg0000'
            druid_path = 'spec/fixtures/good_root01/moab_storage_trunk/gg/000/gg/0000/gg000gg0000'
            storage_obj = Moab::StorageObject.new(druid, druid_path)
            storage_obj_validator = described_class.new(storage_obj)
            verification_array = storage_obj_validator.validation_errors
            expect(verification_array).to be_empty
          end
        end
        context 'metadata directory' do
          it 'must only contain files' do
            expect(verification_array).to include(Moab::StorageObjectValidator::METADATA_SUB_DIRS_DETECTED =>"Version v0008: metadata directory should only contain files, not directories")
          end
          it 'must contain files' do
            expect(verification_array).to include(Moab::StorageObjectValidator::NO_FILES_IN_METADATA_DIR=>"Version v0010: No files present in metadata dir")
          end
        end
      end
      context 'under manifest directory' do
        druid = 'cc000cc0000'
        druid_path = 'spec/fixtures/bad_root01/bad_moab_storage_trunk/cc/000/cc/0000/cc000cc0000'
        storage_obj = Moab::StorageObject.new(druid, druid_path)
        storage_obj_validator = described_class.new(storage_obj)
        verification_array = storage_obj_validator.validation_errors
        it 'does not have signatureCatalog.xml' do
          expect(verification_array).to include(Moab::StorageObjectValidator::NO_SIGNATURE_CATALOG => "Version v0001: Missing signatureCatalog.xml")
        end

        it 'does not have manifestInventory.xml' do
          expect(verification_array).to include(Moab::StorageObjectValidator::NO_MANIFEST_INVENTORY => "Version v0002: Missing manifestInventory.xml")
        end

        it 'does not have either signatureCatalog.xml or manifestInventory.xml' do
          expect(verification_array).to include(Moab::StorageObjectValidator::NO_MANIFEST_INVENTORY => "Version v0003: Missing manifestInventory.xml")
          expect(verification_array).to include(Moab::StorageObjectValidator::NO_SIGNATURE_CATALOG => "Version v0003: Missing signatureCatalog.xml")
        end

        it 'has no files' do
          expect(verification_array).to include(Moab::StorageObjectValidator::NO_FILES_IN_MANIFEST_DIR => "Version v0004: No files present in manifest dir")
        end
        it 'has a folder' do
          expect(verification_array).to include(Moab::StorageObjectValidator::NO_FILES_IN_MANIFEST_DIR => "Version v0005: No files present in manifest dir")
        end
      end
      it "has non contiguous version directories" do
        druid = 'yy000yy0000'
        druid_path = 'spec/fixtures/bad_root01/bad_moab_storage_trunk/yy/000/yy/0000/yy000yy0000'
        storage_obj = Moab::StorageObject.new(druid, druid_path)
        storage_obj_validator = described_class.new(storage_obj)
        verification_array = storage_obj_validator.validation_errors
        expect(verification_array).to include(Moab::StorageObjectValidator::VERSIONS_NOT_IN_ORDER =>"Should contain only sequential version directories. Current directories: [\"v0001\", \"v0003\", \"v0004\", \"v0006\"]")
      end
      it "has extra characters in version directory name" do
        druid = 'aa000aa0000'
        druid_path = 'spec/fixtures/bad_root01/bad_moab_storage_trunk/aa/000/aa/0000/aa000aa0000'
        storage_obj = Moab::StorageObject.new(druid, druid_path)
        storage_obj_validator = described_class.new(storage_obj)
        verification_array = storage_obj_validator.validation_errors
        expect(verification_array).to include(Moab::StorageObjectValidator::VERSION_DIR_BAD_FORMAT => "Version directory name not in 'v00xx' format: v0001a")
      end
      it "incorrect items under version directory" do
        druid = 'bb000bb0000'
        druid_path = 'spec/fixtures/bad_root01/bad_moab_storage_trunk/bb/000/bb/0000/bb000bb0000'
        storage_obj = Moab::StorageObject.new(druid, druid_path)
        storage_obj_validator = described_class.new(storage_obj)
        verification_array = storage_obj_validator.validation_errors
        files_present_err_msg = 'should not contain files; only the manifests and data directories'
        expect(verification_array.size).to eq 7
        expect(verification_array).to include(Moab::StorageObjectValidator::INCORRECT_DIR_CONTENTS => "Incorrect items under v0001 directory")
        expect(verification_array).to include(Moab::StorageObjectValidator::FILES_IN_VERSION_DIR => "Version directory v0001 #{files_present_err_msg}")
        expect(verification_array).to include(Moab::StorageObjectValidator::FILES_IN_VERSION_DIR => "Version directory v0002 #{files_present_err_msg}")
        expect(verification_array).to include(Moab::StorageObjectValidator::FILES_IN_VERSION_DIR => "Version directory v0003 #{files_present_err_msg}")
        expect(verification_array).to include(Moab::StorageObjectValidator::EXTRA_CHILD_DETECTED => "Unexpected item in path: [\"test2.txt\"] Version: v0004")
        expect(verification_array).to include(Moab::StorageObjectValidator::INCORRECT_DIR_CONTENTS => "Incorrect items under v0005 directory")
        expect(verification_array).to include(Moab::StorageObjectValidator::FILES_IN_VERSION_DIR => "Version directory v0005 #{files_present_err_msg}")
      end

      it "has incorrect version directory name" do
        druid = 'zz000zz0000'
        druid_path = 'spec/fixtures/bad_root01/bad_moab_storage_trunk/zz/000/zz/0000/zz000zz0000'
        storage_obj = Moab::StorageObject.new(druid, druid_path)
        storage_obj_validator = described_class.new(storage_obj)
        verification_array = storage_obj_validator.validation_errors
        expect(verification_array).to include(Moab::StorageObjectValidator::VERSION_DIR_BAD_FORMAT => "Version directory name not in 'v00xx' format: x0001")
      end
      it 'does not call #check_expected_data_sub_dirs because moab does not have the expected version sub dirs' do
        druid = 'ee000ee0000'
        druid_path = 'spec/fixtures/bad_root01/bad_moab_storage_trunk/ee/000/ee/0000/ee000ee0000'
        storage_obj = Moab::StorageObject.new(druid, druid_path)
        storage_obj_validator = described_class.new(storage_obj)
        expect(storage_obj_validator).not_to receive(:check_expected_data_sub_dirs)
        storage_obj_validator.validation_errors
      end
      it 'does not call #check_metadata_dir_files_only because moab does not have the expected data sub dirs' do
        druid = 'ff000ff0000'
        druid_path = 'spec/fixtures/bad_root01/bad_moab_storage_trunk/ff/000/ff/0000/ff000ff0000'
        storage_obj = Moab::StorageObject.new(druid, druid_path)
        storage_obj_validator = described_class.new(storage_obj)
        expect(storage_obj_validator).not_to receive(:check_metadata_dir_files_only)
        storage_obj_validator.validation_errors
      end
    end
    context 'valid moab' do
      let(:druid) { 'bj103hs9687' }
      let(:druid_path) { 'spec/fixtures/good_root01/moab_storage_trunk/bj/103/hs/9687/bj103hs9687' }
      let(:storage_obj) { Moab::StorageObject.new(druid, druid_path) }
      let(:storage_obj_validator) { described_class.new(storage_obj) }
      let(:verification_array) { storage_obj_validator.validation_errors }

      it "returns true when moab is in correct format" do
        expect(verification_array.empty?).to eq true
      end
      it "calls #check_correctly_named_version_dirs to verify correctly named version dirs" do
        expect(storage_obj_validator).to receive(:check_correctly_named_version_dirs).and_return([])
        storage_obj_validator.validation_errors
      end
      it "calls #check_sequential_version_dirs to verify contiguous version dirs" do
        expect(storage_obj_validator).to receive(:check_sequential_version_dirs).and_return([])
        storage_obj_validator.validation_errors
      end
      it 'calls #check_required_manifest_files if moab has the expected version sub dirs' do
        expect(storage_obj_validator).to receive(:check_required_manifest_files).and_return([])
        storage_obj_validator.validation_errors
      end
      it 'calls #check_data_sub_dirs if moab has the expected version sub dirs' do
        expect(storage_obj_validator).to receive(:check_data_sub_dirs).and_return([])
        storage_obj_validator.validation_errors
      end
      it 'calls #check_metadata_dir_files_only if moab has the expected data sub dirs' do
        expect(storage_obj_validator).to receive(:check_metadata_dir_files_only).and_return([])
        storage_obj_validator.validation_errors
      end

      context 'manifests directory' do
        it 'may have files in addition to required files' do
          expect(verification_array).not_to include(Moab::StorageObjectValidator::EXTRA_CHILD_DETECTED)
        end
        it 'may only have required files' do
          druid = 'mm000mm0000'
          druid_path = 'spec/fixtures/good_root01/moab_storage_trunk/mm/000/mm/0000/mm000mm0000'
          expect(verification_array).to be_empty
        end
      end

      context 'data directory' do
        context 'content directory' do
          it 'may be missing' do
            druid = 'xx000xx0000'
            druid_path = 'spec/fixtures/good_root01/moab_storage_trunk/xx/000/xx/0000/xx000xx0000'
            expect(verification_array).to be_empty
          end
          it 'may be present' do
            expect(verification_array).not_to include(Moab::StorageObjectValidator::EXTRA_CHILD_DETECTED)
          end
          it 'may have sub-directories if not verboten sub-dir name' do
            druid = 'nn000nn0000'
            druid_path = 'spec/fixtures/good_root01/moab_storage_trunk/nn/000/nn/0000/nn000nn0000'
            expect(verification_array).to be_empty
            druid = 'xx000xx000'
            druid_path = 'spec/fixtures/good_root01/moab_storage_trunk/xx/000/xx/0000/xx000xx0000'
            expect(verification_array).not_to include(Moab::StorageObjectValidator::CONTENT_SUB_DIRS_DETECTED =>"Version v0007: content directory should only contain files, not directories")
          end
        end
      end
    end
  end
end
