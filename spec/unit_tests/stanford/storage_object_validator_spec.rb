require 'spec_helper'
RSpec.describe Stanford::StorageObjectValidator do
  describe '#validation_errors' do
    let(:druid1) { 'bj102hs9687'}
    let(:druid_path1) { 'spec/fixtures/storage_root01/moab_storage_trunk/bj/102/hs/9687/bj102hs9687' }
    let(:storage_obj1) { Moab::StorageObject.new(druid1, druid_path1) }
    let(:storage_obj_validator1) { described_class.new(storage_obj1) }

    it 'returns errors from calling the superclass validation_errors' do
      erroneous_druid = 'xx000xx0000'
      erroneous_druid_path = 'spec/fixtures/bad_root01/bad_moab_storage_trunk/xx/000/xx/0000/xx000xx0000'
      erroneous_object = Moab::StorageObject.new(erroneous_druid, erroneous_druid_path)
      erroneous_object_validator = described_class.new(erroneous_object)
      error_list = erroneous_object_validator.validation_errors
      expect(error_list.count).to eq(10)
    end
    it 'returns validation error codes when there is file path for druid to directory validation' do
      invalid_druid_path = 'spec/fixtures/bad_root01/bad_moab_storage_trunk/dd/000/dd/0000/dd000dd0000'
      storage_obj = Moab::StorageObject.new('dd000dd0000', invalid_druid_path)
      storage_obj_validator = described_class.new(storage_obj)
      verification_array = storage_obj_validator.validation_errors
      expect(verification_array).to include(Moab::StorageObjectValidator::MISSING_DIR => "Missing directory: no versions exist")
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
