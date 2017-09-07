require 'spec_helper'

describe 'Moab::StorageRepository' do

  let(:storage_repo) { Moab::StorageRepository.new() }

  specify '#storage_roots' do
    # these are set in spec_config.rb
    expect(storage_repo.storage_roots[0]).to eq @fixtures.join('derivatives')
    expect(storage_repo.storage_roots[1]).to eq @fixtures.join('newnode')
  end

  specify '#storage_trunk' do
    # set in spec_config.rb
    expect(storage_repo.storage_trunk).to eq 'ingests'
  end

  specify '#deposit_trunk' do
    # set in spec_config.rb
    expect(storage_repo.deposit_trunk).to eq 'packages'
  end

  specify '#storage_branch' do
    expect(storage_repo.storage_branch('abcdef')).to eq 'ab/cd/ef/abcdef'
  end

  specify '#deposit_branch' do
    expect(storage_repo.deposit_branch('abcdef')).to eq 'abcdef'
  end

  context '#find_storage_root' do
    it 'new objects will be stord in the newest (most empty) filesystem' do
      expect(storage_repo.find_storage_root('abcdef')).to eq @fixtures.join('newnode')
    end
    it 'object with known storage branch' do
      allow(storage_repo).to receive(:storage_branch).and_return('jq937jp0017')
      expect(storage_repo.find_storage_root('jq937jp0017')).to eq @derivatives
    end
    it 'exception raised when storage_trunk is bogus' do
      allow(storage_repo).to receive(:storage_trunk).and_return('junk')
      expect{storage_repo.find_storage_root('abcdef')}.to raise_exception(/Storage area not found/)
    end
  end

  specify '#find_storage_object' do
    allow(storage_repo).to receive(:storage_branch).and_return('jq937jp0017')
    found_storage_obj = storage_repo.find_storage_object('jq937jp0017')
    expect(found_storage_obj.object_pathname).to eq @derivatives.join('ingests/jq937jp0017')
    expect(found_storage_obj.deposit_bag_pathname).to eq @derivatives.join('packages/jq937jp0017')
  end

  context '#storage_object' do
    before(:each) do
      mock_storage_obj = double(Moab::StorageObject)
      allow(storage_repo).to receive(:find_storage_object).and_return(mock_storage_obj)
      @mock_path = double(Pathname)
      allow(mock_storage_obj).to receive(:object_pathname).and_return(@mock_path)
      allow(@mock_path).to receive(:exist?).and_return(false)
    end

    it 'raises exception when object not found' do
      expect{storage_repo.storage_object('jq937jp0017')}.to raise_exception(Moab::ObjectNotFoundException)
    end

    it 'creates path when create set to true' do
      expect(@mock_path).to receive(:mkpath)
      storage_repo.storage_object('jq937jp0017', true)
    end
  end

  it '#object_size returns the size of a moab object' do
    # values may differ from file system to file system (which is to be expected).
    # if this test fails on your mac, make sure you don't have any extraneous .DS_Store files
    # lingering in the fixture directories.
    allow(storage_repo).to receive(:storage_branch).and_return('jq937jp0017')
    expect(storage_repo.object_size('jq937jp0017')).to be_between(345_000, 346_000)
  end

  specify "#store_new_object_version" do
    bag_pathname = double("bag_pathname")
    object_pathname = double("object_pathname")
    storage_object = double(Moab::StorageObject)
    expect(storage_repo).to receive(:storage_object).with(@druid, true).and_return(storage_object)
    allow(storage_object).to receive(:object_pathname).and_return(object_pathname)
    expect(storage_object).to receive(:ingest_bag).with(bag_pathname)
    storage_repo.store_new_object_version(@druid, bag_pathname)
  end
end
