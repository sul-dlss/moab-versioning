require 'spec_helper'

describe 'Moab::FileInventoryDifference' do

  describe '#initialize' do
    specify 'empty options hash' do
      fid = Moab::FileInventoryDifference.new({})
      group_diffs = fid.group_differences
      expect(group_diffs).to be_kind_of Array
      expect(group_diffs.size).to eq 0
    end
    specify 'options passed in' do
      opts = {
        digital_object_id: 'Test digital_object_id',
        basis: 'Test basis',
        other: 'Test other',
        report_datetime: 'Apr 12 19:36:07 UTC 2012'
      }
      fid = Moab::FileInventoryDifference.new(opts)
      expect(fid.digital_object_id).to eq opts[:digital_object_id]
      expect(fid.difference_count).to eq 0
      expect(fid.basis).to eq opts[:basis]
      expect(fid.other).to eq opts[:other]
      expect(fid.report_datetime).to eq '2012-04-12T19:36:07Z'
    end
  end

  describe '.compare sets attributes' do
    let(:compared_file_inv_diff) do
      v1_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
      v1_inventory = Moab::FileInventory.parse(v1_inventory_pathname.read)
      v2_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0002/manifests/versionInventory.xml')
      v2_inventory = Moab::FileInventory.parse(v2_inventory_pathname.read)
      fid = Moab::FileInventoryDifference.new
      fid.compare(v1_inventory, v2_inventory)
      fid
    end

    specify '#digital_object_id' do
      expect(compared_file_inv_diff.digital_object_id).to eq 'druid:jq937jp0017'
    end
    specify '#difference_count' do
      expect(compared_file_inv_diff.difference_count).to eq 6
    end
    specify '#basis' do
      expect(compared_file_inv_diff.basis).to eq 'v1'
    end
    specify '#other' do
      expect(compared_file_inv_diff.other).to eq 'v2'
    end
    specify '#report_datetime' do
      expect(Time.parse(compared_file_inv_diff.report_datetime)).to be_instance_of(Time)
    end
    specify '#group_differences' do
      expect(compared_file_inv_diff.group_differences.size).to eq 2
    end
  end

  describe '#report_datetime' do
    specify 'reformats date as ISO8601 (UTC Z format)' do
      fid = Moab::FileInventoryDifference.new
      fid.report_datetime = 'Apr 12 19:36:07 UTC 2012'
      expect(fid.report_datetime).to eq '2012-04-12T19:36:07Z'
    end
  end

  let(:v1_inventory) do
    v1_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
    Moab::FileInventory.parse(v1_inventory_pathname.read)
  end
  let(:v2_inventory) do
    v2_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0002/manifests/versionInventory.xml')
    Moab::FileInventory.parse(v2_inventory_pathname.read)
  end
  let(:file_inventory_difference) { Moab::FileInventoryDifference.new }

  specify '#compare' do
    diff = file_inventory_difference.compare(v1_inventory, v2_inventory)
    expect(diff).to be_instance_of(Moab::FileInventoryDifference)
    expect(diff.group_differences.size).to eq 2
    expect(diff.basis).to eq 'v1'
    expect(diff.other).to eq 'v2'
    expect(diff.difference_count).to eq 6
    expect(diff.digital_object_id).to eq 'druid:jq937jp0017'
  end

  describe '#group_difference' do
    let(:diff) { file_inventory_difference.compare(v1_inventory, v2_inventory) }
    specify '"content" has group_id "content"' do
      group_diff = diff.group_difference 'content'
      expect(group_diff.group_id).to eq 'content'
    end
    specify 'unknown type returns nil' do
      expect(diff.group_difference('dummy')).to eq nil
    end
  end

  describe '#common_object_id' do
    specify 'different ids' do
      basis_inventory = Moab::FileInventory.new(digital_object_id: 'druid:aa111bb2222')
      other_inventory = Moab::FileInventory.new(digital_object_id: 'druid:cc444dd5555')
      exp_id = 'druid:aa111bb2222|druid:cc444dd5555'
      expect(file_inventory_difference.common_object_id(basis_inventory, other_inventory)).to eq exp_id
    end
    specify 'same id' do
      expect(file_inventory_difference.common_object_id(v1_inventory, v2_inventory)).to eq 'druid:jq937jp0017'
    end
  end

  specify '#summary_fields' do
    diff = file_inventory_difference.compare(v1_inventory, v2_inventory)
    hash = diff.summary
    hash.delete('report_datetime')
    expect(hash).to eq({
      'digital_object_id' => 'druid:jq937jp0017',
      'basis' => 'v1',
      'other' => 'v2',
      'difference_count' => 6,
      'group_differences' => {
        'metadata' => {
          'group_id' => 'metadata',
          'difference_count' => 3,
          'identical' => 2,
          'added' => 0,
          'modified' => 3,
          'deleted' => 0,
          'renamed' => 0,
          'copyadded' => 0,
          'copydeleted' => 0
        },
        'content' => {
          'group_id' => 'content',
          'difference_count' => 3,
          'identical' => 3,
          'added' => 0,
          'modified' => 1,
          'deleted' => 2,
          'renamed' => 0,
          'copyadded' => 0,
          'copydeleted' => 0
        }
      }
    })
  end

  specify '#differences_detail' do
    diff = file_inventory_difference.compare(v1_inventory, v2_inventory)
    hash = diff.differences_detail
    expect(hash['group_differences'].size).to eq 2
  end
end
