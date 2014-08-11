require 'spec_helper'

# Unit tests for class {Moab::FileInventoryDifference}
describe 'Moab::FileInventoryDifference' do

  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Moab::FileInventoryDifference#initialize}
    # Which returns an instance of: [Moab::FileInventoryDifference]
    # For input parameters:
    # * opts [Hash<Symbol,Object>] = a hash containing any number of symbol => value pairs. The symbols should correspond to attributes declared using HappyMapper syntax 
    specify 'Moab::FileInventoryDifference#initialize' do
       
      # test initialization with required parameters (if any)
      opts = {}
      file_inventory_difference = FileInventoryDifference.new(opts)
      expect(file_inventory_difference).to be_instance_of(FileInventoryDifference)
       
      # test initialization of arrays and hashes
      expect(file_inventory_difference.group_differences).to be_kind_of(Array)
      expect(file_inventory_difference.group_differences.size).to eq(0)

      # test initialization with options hash
      opts = Hash.new
      opts[:digital_object_id] = 'Test digital_object_id'
      opts[:basis] = 'Test basis'
      opts[:other] = 'Test other'
      opts[:report_datetime] = "Apr 12 19:36:07 UTC 2012"
      file_inventory_difference = FileInventoryDifference.new(opts)
      expect(file_inventory_difference.digital_object_id).to eq(opts[:digital_object_id])
      expect(file_inventory_difference.difference_count).to eq(0)
      expect(file_inventory_difference.basis).to eq(opts[:basis])
      expect(file_inventory_difference.other).to eq(opts[:other])
      expect(file_inventory_difference.report_datetime).to eq("2012-04-12T19:36:07Z")

      # def initialize(opts={})
      #   @group_differences = Array.new
      #   super(opts)
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:all) do
      @v1_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
      @v1_inventory = FileInventory.parse(@v1_inventory_pathname.read)

      @v2_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0002/manifests/versionInventory.xml')
      @v2_inventory = FileInventory.parse(@v2_inventory_pathname.read)

      opts = {}
      @file_inventory_difference = FileInventoryDifference.new(opts)
      @file_inventory_difference.compare(@v1_inventory,@v2_inventory)
      end
    
    # Unit test for attribute: {Moab::FileInventoryDifference#digital_object_id}
    # Which stores: [String] The digital object ID (druid)
    specify 'Moab::FileInventoryDifference#digital_object_id' do
      expect(@file_inventory_difference.digital_object_id).to eq("druid:jq937jp0017")
       
      # attribute :digital_object_id, String, :tag => 'objectId'
    end
    
    # Unit test for attribute: {Moab::FileInventoryDifference#difference_count}
    # Which stores: [Integer] the number of differences found between the two inventories that were compared (dynamically calculated)
    specify 'Moab::FileInventoryDifference#difference_count' do
      expect(@file_inventory_difference.difference_count).to eq(6)
       
      # attribute :difference_count, Integer, :tag=> 'differenceCount',:on_save => Proc.new {|i| i.to_s}
       
      # def difference_count
      #   @group_differences.inject(0) { |sum, group| sum + group.difference_count }
      # end
    end
    
    # Unit test for attribute: {Moab::FileInventoryDifference#basis}
    # Which stores: [String] Id information from the version inventory used as the basis for comparison
    specify 'Moab::FileInventoryDifference#basis' do
      expect(@file_inventory_difference.basis).to eq("v1")
       
      # attribute :basis, String
    end
    
    # Unit test for attribute: {Moab::FileInventoryDifference#other}
    # Which stores: [String] Id information about the version inventory compared to the basis
    specify 'Moab::FileInventoryDifference#other' do
      expect(@file_inventory_difference.other).to eq("v2")

      # attribute :other, String
    end
    
    # Unit test for attribute: {Moab::FileInventoryDifference#report_datetime}
    # Which stores: [Time] The datetime at which the report was run
    specify 'Moab::FileInventoryDifference#report_datetime' do
      expect(Time.parse(@file_inventory_difference.report_datetime)).to be_instance_of(Time)
      @file_inventory_difference.report_datetime = "Apr 12 19:36:07 UTC 2012"
      expect(@file_inventory_difference.report_datetime).to eq("2012-04-12T19:36:07Z")
       
      # def report_datetime=(datetime)
      #   @report_datetime=Time.input(datetime)
      # end
       
      # def report_datetime
      #   Time.output(@report_datetime)
      # end
    end
    
    # Unit test for attribute: {Moab::FileInventoryDifference#group_differences}
    # Which stores: [Array<FileGroupDifference>] The set of data groups comprising the version
    specify 'Moab::FileInventoryDifference#group_differences' do
      expect(@file_inventory_difference.group_differences.size).to eq(2)
       
      # has_many :group_differences, FileGroupDifference
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:all) do
      @v1_data_directory = @fixtures.join('data/jq937jp0017/v0001')
      @v1_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
      @v1_inventory = FileInventory.parse(@v1_inventory_pathname.read)
      @v2_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0002/manifests/versionInventory.xml')
      @v2_inventory = FileInventory.parse(@v2_inventory_pathname.read)
    end

    before (:each) do
      opts = {}
      @file_inventory_difference = FileInventoryDifference.new(opts)
    end
    
    # Unit test for method: {Moab::FileInventoryDifference#compare}
    # Which returns: [FileInventoryDifference] Returns a report showing the differences, if any, between two inventories
    # For input parameters:
    # * basis_inventory [FileInventory] = The inventory that is the basis of the comparison 
    # * other_inventory [FileInventory] = The inventory that is compared against the basis inventory 
      specify 'Moab::FileInventoryDifference#compare' do
      basis_inventory = @v1_inventory
      other_inventory = @v2_inventory
      diff = @file_inventory_difference.compare(basis_inventory, other_inventory)
      expect(diff).to be_instance_of(FileInventoryDifference)
      expect(diff.group_differences.size).to eq(2)
      expect(diff.basis).to eq("v1")
      expect(diff.other).to eq("v2")
      expect(diff.difference_count).to eq(6)
      expect(diff.digital_object_id).to eq("druid:jq937jp0017")

      # def compare(basis_inventory, other_inventory)
      #   @digital_object_id ||= common_object_id(basis_inventory, other_inventory)
      #   @basis ||= basis_inventory.data_source
      #   @other ||= other_inventory.data_source
      #   @report_datetime = Time.now
      #   group_ids = basis_inventory.groups.keys | other_inventory.groups.keys
      #   group_ids.each do |group_id|
      #     basis_group = basis_inventory.groups.keyfind(group_id)
      #     other_group = other_inventory.groups.keyfind(group_id)
      #     unless (basis_group.nil? || other_group.nil?)
      #      @group_differences << FileGroupDifference.new.compare_file_groups(basis_group, other_group)
      #     end
      #   end
      #   self
      # end
      end

    specify 'Moab::FileInventoryDifference#group_difference' do
      basis_inventory = @v1_inventory
      other_inventory = @v2_inventory
      diff = @file_inventory_difference.compare(basis_inventory, other_inventory)
      group_diff = diff.group_difference("content")
      expect(group_diff.group_id).to eq("content")
      expect(diff.group_difference("dummy")).to eq(nil)
    end

    # Unit test for method: {Moab::FileInventoryDifference#common_object_id}
    # Which returns: [String] Returns either the common digitial object ID, or a concatenation of both inventory's IDs
    # For input parameters:
    # * basis_inventory [FileInventory] = The inventory that is the basis of the comparison 
    # * other_inventory [FileInventory] = The inventory that is compared against the basis inventory 
    specify 'Moab::FileInventoryDifference#common_object_id' do
      basis_inventory=FileInventory.new(:digital_object_id=>"druid:aa111bb2222")
      other_inventory=FileInventory.new(:digital_object_id=>"druid:cc444dd5555")
      expect(FileInventoryDifference.new.common_object_id(basis_inventory,other_inventory)).to eq("druid:aa111bb2222|druid:cc444dd5555")
      expect(FileInventoryDifference.new.common_object_id(@v1_inventory,@v2_inventory)).to eq("druid:jq937jp0017")

      # def common_object_id(basis_inventory, other_inventory)
      #   if basis_inventory.digital_object_id != other_inventory.digital_object_id
      #     "#{basis_inventory.digital_object_id.to_s}|#{other_inventory.digital_object_id.to_s}"
      #   else
      #     basis_inventory.digital_object_id.to_s
      #   end
      # end
    end

    # Unit test for method: {Moab::FileInventoryDifference#summary_fields}
    specify "Moab::FileInventoryDifference#summary_fields}" do
      basis_inventory = @v1_inventory
      other_inventory = @v2_inventory
      diff = @file_inventory_difference.compare(basis_inventory, other_inventory)
      hash = diff.summary
      hash.delete("report_datetime")
      expect(hash).to eq({
        "digital_object_id"=>"druid:jq937jp0017",
        "basis"=>"v1",
        "other"=>"v2",
        "difference_count"=>6,
        "group_differences"=> {
           "metadata"=> { "group_id"=>"metadata", "difference_count"=>3,
              "identical"=>2, "added"=>0, "modified"=>3, "deleted"=>0, "renamed"=>0, "copyadded"=>0, "copydeleted"=>0
           },
           "content"=> { "group_id"=>"content", "difference_count"=>3,
              "identical"=>3, "added"=>0, "modified"=>1,  "deleted"=>2, "renamed"=>0, "copyadded"=>0, "copydeleted"=>0
           }
        }
      })

      #puts diff.to_yaml(summary=true)
      #puts diff.to_json
    end

    # Unit test for method: {Moab::FileInventoryDifference#differences_detail}
    specify "Moab::FileInventoryDifference#differences_detail}" do
      basis_inventory = @v1_inventory
      other_inventory = @v2_inventory
      diff = @file_inventory_difference.compare(basis_inventory, other_inventory)
      hash = diff.differences_detail
      #puts JSON.pretty_generate(hash)
      expect(hash["group_differences"].size).to eq(2)

    end

  end

end
