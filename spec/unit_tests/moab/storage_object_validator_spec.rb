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
  describe '#validate_object' do
    let(:verification_array) { storage_obj_validator1.validate_object }

    it 'returns correct data structure' do
      expect(storage_obj_validator1.validate_object).to be_kind_of Array
    end

    it 'has item in the array that is the expected structure' do
      expect(verification_array[0]).to be_kind_of Hash
    end

    context 'under version directory' do
      it 'has missing items' do
        # v0001
        expect(verification_array[0]).to eq(1=>"Missing directory: [\"data\", \"manifests\"] Version: v0001")
      end
      it 'has unexpected directory' do
        # v0002
        expect(verification_array[1]).to eq(2=>"Unexpected item in path: [\"extra_dir\"] Version: v0002")
      end
      it 'has unexpected file' do
        # v0003
        expect(verification_array[2]).to eq(2=>"Unexpected item in path: [\"extra_file.txt\"] Version: v0003")
      end
      it 'has missing data directory' do
        # v0004
        expect(verification_array[3]).to eq(1=>"Missing directory: [\"data\"] Version: v0004")
      end
    end

    context 'under data directory' do
      it 'has unexpected file' do
        # v0005
        expect(verification_array[4]).to eq(2=>"Unexpected item in path: [\"extra_file.txt\"] Version: v0005")
        expect(verification_array[8]).to eq(6=>"Version: v0007 Missing all required metadata files")
      end
      it 'has missing manifest files' do
        # v0005
        expect(verification_array[5]).to eq(6=>"Version: v0005 Missing all required metadata files")
      end
      it 'has missing content directory' do
        # v0006
        expect(verification_array[6]).to eq(1=>"Missing directory: [\"content\", \"metadata\"] Version: v0006")
      end
      it 'has no items' do
        # v0006
        expect(verification_array[7]).to eq(6=>"Version: v0006 Missing all required metadata files")
      end
    end
  end
  describe '#validate_object' do
    let(:druid) { 'yy000yy0000'}
    let(:druid_path) { 'spec/fixtures/bad_root01/bad_moab_storage_trunk/yy/000/yy/0000/yy000yy0000' }
    let(:storage_obj) { Moab::StorageObject.new(druid, druid_path) }
    let(:storage_obj_validator) { described_class.new(storage_obj) }
    let(:verification_array) { storage_obj_validator.validate_object }

    it "has non contiguous version directories" do
      expect(verification_array).to eq([{ 7=>"Should contain only sequential version directories. Current directories: [\"v0001\", \"v0003\", \"v0004\", \"v0006\"]" }])
    end
  end
  describe '#validate_object' do
    let(:druid) { 'zz000zz0000'}
    let(:druid_path) { 'spec/fixtures/bad_root01/bad_moab_storage_trunk/zz/000/zz/0000/zz000zz0000' }
    let(:storage_obj) { Moab::StorageObject.new(druid, druid_path) }
    let(:storage_obj_validator) { described_class.new(storage_obj) }
    let(:verification_array) { storage_obj_validator.validate_object }

    it "has incorrect version directory name" do
      expect(verification_array).to eq [9=>"Version directory name not in 'v00xx' format"]
    end
  end
  describe '#validate_object' do
    let(:druid) { 'bj102hs9687'}
    let(:druid_path) { 'spec/fixtures/storage_root01/moab_storage_trunk/bj/102/hs/9687/bj102hs9687' }
    let(:storage_obj) { Moab::StorageObject.new(druid, druid_path) }
    let(:storage_obj_validator) { described_class.new(storage_obj) }
    let(:verification_array) { storage_obj_validator.validate_object }

    it "returns true when moab is in correct format" do
      expect(verification_array).to eq true
    end
  end
end
