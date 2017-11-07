require 'spec_helper'
RSpec.describe Stanford::StorageObjectValidator do
  describe '#validation_errors' do
    let(:druid1) { 'bj102hs9687'}
    let(:druid_path1) { 'spec/fixtures/storage_root01/moab_storage_trunk/bj/102/hs/9687/bj102hs9687' }
    let(:storage_obj1) { Moab::StorageObject.new(druid1, druid_path1) }
    let(:storage_obj_validator1) { described_class.new(storage_obj1) }
    let(:verification_array) { storage_obj_validator1.validation_errors }

    it 'returns errors from calling the superclass validation_errors' do
      expect(verification_array.count).to eq(2)
    end

  end

  describe '#identify_druid' do
    let(:same_druid) { 'bz514sm9647' }
    let(:different_druid) { 'jj925bx9565' }

    context 'for druid_tree config' do
      let(:same_druid_path) { 'spec/fixtures/storage_root01/moab_storage_trunk/bz/514/sm/9647/bz514sm9647' }
      let(:storage_obj1) { Moab::StorageObject.new(same_druid, same_druid_path) }
      let(:storage_obj_validator1) { described_class.new(storage_obj1) }
      let(:different_druid_path) { 'spec/fixtures/storage_root01/moab_storage_trunk/jj/925/bx/9565/jj925bx9565' }
      let(:storage_obj2) { Moab::StorageObject.new(different_druid, different_druid_path) }
      let(:storage_obj_validator2) { described_class.new(storage_obj2) }

      it 'returns empty errors array when druid is the same' do
        expect(storage_obj_validator1.identify_druid).to eq []
      end

      it 'returns the right error code when druid is not the same' do
        expect(storage_obj_validator2.identify_druid).to eq [
          { Stanford::StorageObjectValidator::DRUID_MISMATCH=>'manifestInventory object_id does not match druid' }
        ]
      end
    end
    context 'for druid config' do
      let(:same_druid_path) { 'spec/fixtures/storage_root02/moab_storage_trunk/bz514sm9647' }
      let(:storage_obj1) { Moab::StorageObject.new(same_druid, same_druid_path) }
      let(:storage_obj_validator1) { described_class.new(storage_obj1) }
      let(:different_druid_path) { 'spec/fixtures/storage_root02/moab_storage_trunk/jj925bx9565' }
      let(:storage_obj2) { Moab::StorageObject.new(different_druid, different_druid_path) }
      let(:storage_obj_validator2) { described_class.new(storage_obj2) }

      it 'returns empty errors array when druid is the same' do
        expect(storage_obj_validator1.identify_druid).to eq []
      end

      it 'returns the right error code when druid is not the same' do
        expect(storage_obj_validator2.identify_druid).to eq [
          { Stanford::StorageObjectValidator::DRUID_MISMATCH=>'manifestInventory object_id does not match druid' }
        ]
      end
    end
  end
end
