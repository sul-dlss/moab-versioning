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

    it 'returns correct data structure' do
      expect(storage_obj_validator1.validation_errors).to be_kind_of Array
    end

    it 'has item in the array that is the expected structure' do
      expect(verification_array[0]).to be_kind_of Hash
    end
    context 'under version directory' do
      it 'has missing items' do
        # v0001
        expect(verification_array[0]).to eq(Moab::StorageObjectValidator::MISSING_DIR => "Missing directory: [\"data\", \"manifests\"] Version: v0001")
      end
      it 'has unexpected directory' do
        # v0002
        expect(verification_array[1]).to eq(Moab::StorageObjectValidator::EXTRA_CHILD_DETECTED =>"Unexpected item in path: [\"extra_dir\"] Version: v0002")
      end
      it 'has unexpected file' do
        # v0003
        expect(verification_array[2]).to eq(Moab::StorageObjectValidator::EXTRA_CHILD_DETECTED =>"Unexpected item in path: [\"extra_file.txt\"] Version: v0003")
      end
      it 'has missing data directory' do
        # v0004
        expect(verification_array[3]).to eq(Moab::StorageObjectValidator::MISSING_DIR =>"Missing directory: [\"data\"] Version: v0004")
      end
    end

    context 'under data directory' do
      it 'has unexpected file' do
        # v0005
        expect(verification_array[4]).to eq(Moab::StorageObjectValidator::EXTRA_CHILD_DETECTED =>"Unexpected item in path: [\"extra_file.txt\"] Version: v0005")
        expect(verification_array[8]).to eq(Moab::StorageObjectValidator::NO_XML_FILES =>"Version: v0007 Missing all required metadata files")
      end
      it 'has missing manifest files' do
        # v0005
        expect(verification_array[5]).to eq(Moab::StorageObjectValidator::NO_XML_FILES =>"Version: v0005 Missing all required metadata files")
      end
      it 'has missing metadata directory' do
        # v0006
        expect(verification_array[6]).to eq(Moab::StorageObjectValidator::MISSING_DIR =>"Missing directory: [\"metadata\"] Version: v0006")
      end
      it 'has no required items' do
        # v0006
        expect(verification_array[7]).to eq(Moab::StorageObjectValidator::NO_XML_FILES =>"Version: v0006 Missing all required metadata files")
      end
    end
    context 'under manifest directory' do
      druid = 'cc000cc0000'
      druid_path = 'spec/fixtures/bad_root01/bad_moab_storage_trunk/cc/000/cc/0000/cc000cc0000'
      storage_obj = Moab::StorageObject.new(druid, druid_path)
      storage_obj_validator = described_class.new(storage_obj)
      verification_array = storage_obj_validator.validation_errors
      it 'does not have signatureCatalog.xml' do
        expect(verification_array).to include(Moab::StorageObjectValidator::NO_SIGNATURE_CATALOG => "Version: v0001 Missing signatureCatalog.xml")
      end

      it 'does not have manifestInventory.xml' do
        expect(verification_array).to include(Moab::StorageObjectValidator::NO_MANIFEST_INVENTORY => "Version: v0002 Missing manifestInventory.xml")
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
      expect(verification_array).to include(Moab::StorageObjectValidator::VERSION_DIR_BAD_FORMAT => "Version directory name not in 'v00xx' format")
    end
    it "incorrect items in path" do
      druid = 'bb000bb0000'
      druid_path = 'spec/fixtures/bad_root01/bad_moab_storage_trunk/bb/000/bb/0000/bb000bb0000'
      storage_obj = Moab::StorageObject.new(druid, druid_path)
      storage_obj_validator = described_class.new(storage_obj)
      verification_array = storage_obj_validator.validation_errors
      expect(verification_array).to include(Moab::StorageObjectValidator::INCORRECT_DIR => "Incorrect items in path")
    end
    it "has incorrect version directory name" do
      druid = 'zz000zz0000'
      druid_path = 'spec/fixtures/bad_root01/bad_moab_storage_trunk/zz/000/zz/0000/zz000zz0000'
      storage_obj = Moab::StorageObject.new(druid, druid_path)
      storage_obj_validator = described_class.new(storage_obj)
      verification_array = storage_obj_validator.validation_errors
      expect(verification_array).to include(Moab::StorageObjectValidator::VERSION_DIR_BAD_FORMAT =>"Version directory name not in 'v00xx' format")
    end
    it "returns true when moab is in correct format" do
      druid = 'bj103hs9687'
      druid_path = 'spec/fixtures/good_root01/moab_storage_trunk/bj/103/hs/9687/bj103hs9687'
      storage_obj = Moab::StorageObject.new(druid, druid_path)
      storage_obj_validator = described_class.new(storage_obj)
      verification_array = storage_obj_validator.validation_errors
      expect(verification_array.empty?).to eq true
    end
  end
end
