require 'spec_helper'

describe 'Moab::FileInstanceDifference' do

  describe '#initialize' do
    specify 'empty options hash' do
      diff = Moab::FileInstanceDifference.new({})
      expect(diff.signatures).to be_kind_of Array
      expect(diff.signatures.size).to eq 0
    end
    specify 'options passed in' do
      opts = {
        change: 'Test change',
        basis_path: 'Test basis_path',
        other_path: 'Test other_path'
      }
      diff = Moab::FileInstanceDifference.new(opts)
      expect(diff.change).to eq opts[:change]
      expect(diff.basis_path).to eq opts[:basis_path]
      expect(diff.other_path).to eq opts[:other_path]
    end
  end

  describe '=========================== INSTANCE ATTRIBUTES ===========================' do

    before(:all) do
      opts = {}
      @file_instance_difference = Moab::FileInstanceDifference.new(opts)
    end

    # Unit test for attribute: {Moab::FileInstanceDifference#change}
    # Which stores: [String] \@change = The type of file change
    specify 'Moab::FileInstanceDifference#change' do
      value = 'Test change'
      @file_instance_difference.change= value
      expect(@file_instance_difference.change).to eq(value)

      # attribute :change, String
    end

    # Unit test for attribute: {Moab::FileInstanceDifference#basis_path}
    # Which stores: [String] \@basisPath = The file's path in the basis inventory (usually for an old version)
    specify 'Moab::FileInstanceDifference#basis_path' do
      value = 'Test basis_path'
      @file_instance_difference.basis_path= value
      expect(@file_instance_difference.basis_path).to eq(value)

      # attribute :basis_path, String, :tag => 'basisPath', :on_save => Proc.new { |s| s.to_s }
    end

    # Unit test for attribute: {Moab::FileInstanceDifference#other_path}
    # Which stores: [String] \@otherPath = The file's path in the other inventory (usually for an new version)
    #  compared against the basis
    specify 'Moab::FileInstanceDifference#other_path' do
      value = 'Test other_path'
      @file_instance_difference.other_path= value
      expect(@file_instance_difference.other_path).to eq(value)

      # attribute :other_path, String, :tag => 'otherPath', :on_save => Proc.new { |s| s.to_s }
    end

    # Unit test for attribute: {Moab::FileInstanceDifference#signatures}
    # Which stores: [Array<Moab::FileSignature>] \[<fileSignature>] = The fixity data of the file manifestation(s)
    #  (plural if change was a content modification)
    specify 'Moab::FileInstanceDifference#signatures' do
      expect(@file_instance_difference.signatures.size).to eq(0)

      # has_many :signatures, Moab::FileSignature
    end

  end

end
