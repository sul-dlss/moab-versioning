require 'spec_helper'



# Unit tests for class {Moab::StorageObjectVersion}
describe 'Moab::VerificationResult' do

  describe '=========================== CONSTRUCTOR ===========================' do

    specify 'Moab::VerificationResult#initialize' do
      result = VerificationResult.new('my_entity')
      result.entity.should == 'my_entity'
      result.verified.should == false
      result.details.should == nil
      result.subentities.should be_an_instance_of(Array)
    end

  end

  describe '========================= CLASS METHODS ==========================' do

    specify 'Moab::VerificationResult.verify_value' do
      result = VerificationResult.verify_value('greeting',"hello","goodbye")
      result.entity.should == 'greeting'
      result.verified.should == false
      result.details.should == {"expected"=>"hello", "found"=>"goodbye"}
      result.subentities.should be_an_instance_of(Array)
      result.subentities.size.should == 0
    end

    specify 'Moab::VerificationResult.verify_truth' do
      result = VerificationResult.verify_truth('truth',"true")
      result.entity.should == 'truth'
      result.verified.should == true
      result.details.should == nil
      result.subentities.should be_an_instance_of(Array)
      result.subentities.size.should == 0
    end

  end

  describe '======================= INSTANCE METHODS ==========================' do

    specify 'Moab::VerificationResult.to_hash' do
      result = VerificationResult.new('my_entity')
      result.verified = false
      result.subentities << VerificationResult.new('subentity_1')
      result.subentities << VerificationResult.new('subentity_2')
      result.subentities << VerificationResult.new('subentity_3')
      result.subentities.each do |s|
        if (s.entity == 'subentity_2')
          s.verified = false
          s.details = {"its a" => "shame"}
        else
          s.verified = true
          s.details = {"all is" => "good"}
        end
      end
      detail_hash = result.to_hash(verbose=true)
      #puts JSON.pretty_generate(detail_hash)
      "#{JSON.pretty_generate(detail_hash)}\n".should == <<-EOF
{
  "my_entity": {
    "verified": false,
    "details": {
      "subentity_1": {
        "verified": true,
        "details": {
          "all is": "good"
        }
      },
      "subentity_2": {
        "verified": false,
        "details": {
          "its a": "shame"
        }
      },
      "subentity_3": {
        "verified": true,
        "details": {
          "all is": "good"
        }
      }
    }
  }
}
      EOF

      detail_json = result.to_json(verbose=false)
      #puts detail_json
      "#{detail_json}\n".should == <<-EOF
{
  "my_entity": {
    "verified": false,
    "details": {
      "subentity_1": {
        "verified": true
      },
      "subentity_2": {
        "verified": false,
        "details": {
          "its a": "shame"
        }
      },
      "subentity_3": {
        "verified": true
      }
    }
  }
}
      EOF


    end

  end



end


