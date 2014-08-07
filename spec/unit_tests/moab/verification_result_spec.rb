require 'spec_helper'



# Unit tests for class {Moab::StorageObjectVersion}
describe 'Moab::VerificationResult' do

  describe '=========================== CONSTRUCTOR ===========================' do

    specify 'Moab::VerificationResult#initialize' do
      result = VerificationResult.new('my_entity')
      expect(result.entity).to eq('my_entity')
      expect(result.verified).to eq(false)
      expect(result.details).to eq(nil)
      expect(result.subentities).to be_an_instance_of(Array)
    end

  end

  describe '========================= CLASS METHODS ==========================' do

    specify 'Moab::VerificationResult.verify_value' do
      result = VerificationResult.verify_value('greeting',"hello","goodbye")
      expect(result.entity).to eq('greeting')
      expect(result.verified).to eq(false)
      expect(result.details).to eq({"expected"=>"hello", "found"=>"goodbye"})
      expect(result.subentities).to be_an_instance_of(Array)
      expect(result.subentities.size).to eq(0)
    end

    specify 'Moab::VerificationResult.verify_truth' do
      result = VerificationResult.verify_truth('truth',"true")
      expect(result.entity).to eq('truth')
      expect(result.verified).to eq(true)
      expect(result.details).to eq(nil)
      expect(result.subentities).to be_an_instance_of(Array)
      expect(result.subentities.size).to eq(0)
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
      expect("#{JSON.pretty_generate(detail_hash)}\n").to eq <<-EOF
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
      expect("#{detail_json}\n").to eq <<-EOF
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


