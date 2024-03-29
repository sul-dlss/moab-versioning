# frozen_string_literal: true

RSpec.describe Stanford::StorageObjectValidator do
  let(:druid) { 'xx000xx0000' }
  let(:druid_path) { 'spec/fixtures/bad_root01/bad_moab_storage_trunk/xx/000/xx/0000/xx000xx0000' }
  let(:storage_obj) { Moab::StorageObject.new(druid, druid_path) }
  let(:storage_obj_validator) { described_class.new(storage_obj) }
  let(:error_list) { storage_obj_validator.validation_errors }

  before do
    stub_const('Moab::StorageObjectValidator::IMPLICIT_DIRS', ['.', '..', '.keep'].freeze)
  end

  describe '#validation_errors' do
    context 'when superclass has validation_errors' do
      it 'returns errors' do
        expect(error_list.count).to eq(9)
      end
    end

    context 'when file path for druid is empty' do
      let(:druid) { 'dd000dd0000' }
      let(:druid_path) { 'spec/fixtures/bad_root01/bad_moab_storage_trunk/dd/000/dd/0000/dd000dd0000' }

      it 'returns errors' do
        expect(error_list).to include(Moab::StorageObjectValidator::MISSING_DIR => 'Missing directory: no versions exist')
      end
    end

    context 'with allow_content_subdirs set to false' do
      it 'passes to super' do
        expect(storage_obj_validator.validation_errors(false))
          .to include(Moab::StorageObjectValidator::CONTENT_SUB_DIRS_DETECTED => 'Version v0013: content directory should only contain files, not directories. Found directory: data')
      end
    end
  end

  describe '#identify_druid' do
    let(:druid) { 'bz514sm9647' }
    let(:druid_path) { 'spec/fixtures/storage_root01/moab_storage_trunk/bz/514/sm/9647/bz514sm9647' }
    let(:sov_id_druid) { storage_obj_validator.identify_druid }

    context 'with druid_tree config' do
      context 'when druid is the same' do
        it 'has no errors' do
          expect(sov_id_druid).to be_empty
        end
      end

      context 'when druid is not the same' do
        let(:druid) { 'jj925bx9565' }
        let(:druid_path) { 'spec/fixtures/storage_root01/moab_storage_trunk/jj/925/bx/9565/jj925bx9565' }

        it 'has errors' do
          expect(sov_id_druid).to eq [
            { Stanford::StorageObjectValidator::DRUID_MISMATCH => 'manifestInventory object_id does not match druid' }
          ]
        end
      end
    end

    context 'with druid config' do
      context 'when druid is the same' do
        let(:druid_path) { 'spec/fixtures/storage_root02/moab_storage_trunk/bz514sm9647' }

        it 'has no errors' do
          expect(sov_id_druid).to be_empty
        end
      end

      context 'when druid is not the same' do
        let(:druid) { 'jj925bx9565' }
        let(:druid_path) { 'spec/fixtures/storage_root02/moab_storage_trunk/jj925bx9565' }

        it 'has errors' do
          expect(sov_id_druid).to eq [
            { Stanford::StorageObjectValidator::DRUID_MISMATCH => 'manifestInventory object_id does not match druid' }
          ]
        end
      end
    end
  end
end
