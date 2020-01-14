# frozen_string_literal: true

describe Moab::StorageRepository do
  let(:storage_repo) { described_class.new }
  let(:derivatives_storage_root) { @fixtures.join('derivatives') }
  let(:derivatives2_storage_root) { @fixtures.join('derivatives2') }
  let(:newnode_storage_root) { @fixtures.join('newnode') }

  specify '#storage_roots' do
    # these are set in spec_config.rb
    expect(storage_repo.storage_roots[0]).to eq derivatives_storage_root
    expect(storage_repo.storage_roots[1]).to eq derivatives2_storage_root
    expect(storage_repo.storage_roots[2]).to eq newnode_storage_root
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

  describe '#find_storage_root' do
    it 'new objects will be stored in the newest (most empty) filesystem' do
      expect(storage_repo.find_storage_root('abcdef')).to eq newnode_storage_root
    end

    it 'object with known storage branch' do
      allow(storage_repo).to receive(:storage_branch).and_return('jq937jp0017')
      expect(storage_repo.find_storage_root('jq937jp0017')).to eq derivatives_storage_root
    end

    it 'exception raised when storage_trunk is bogus' do
      allow(storage_repo).to receive(:storage_trunk).and_return('junk')
      expect { storage_repo.find_storage_root('abcdef') }.to raise_exception(Moab::MoabRuntimeError, /Storage area not found/)
    end
  end

  describe '#search_storage_objects' do
    context 'new storage objects' do
      it 'returns an empty array' do
        expect(storage_repo.search_storage_objects('abcdef')).to be_empty
      end
    end

    context 'existing storage objects' do
      it 'finds objects with known storage branches' do
        allow(storage_repo).to receive(:storage_branch).and_return('jq937jp0017')
        found_storage_objs = storage_repo.search_storage_objects('jq937jp0017')
        expect(found_storage_objs.length).to eq 2
        expect(found_storage_objs[0].object_pathname).to eq derivatives_storage_root.join('ingests/jq937jp0017')
        expect(found_storage_objs[1].object_pathname).to eq derivatives2_storage_root.join('ingests/jq937jp0017')
      end
    end

    it 'exception raised when storage_trunk is bogus' do
      allow(storage_repo).to receive(:storage_trunk).and_return('junk')
      expect { storage_repo.search_storage_objects('abcdef') }.to raise_exception(Moab::MoabRuntimeError,
                                                                                  /Storage area not found/)
    end
  end

  specify '#find_storage_object' do
    allow(storage_repo).to receive(:storage_branch).and_return('jq937jp0017')
    found_storage_obj = storage_repo.find_storage_object('jq937jp0017')
    expect(found_storage_obj.object_pathname).to eq derivatives_storage_root.join('ingests/jq937jp0017')
    expect(found_storage_obj.deposit_bag_pathname).to eq derivatives_storage_root.join('packages/jq937jp0017')
  end

  describe '#storage_object' do
    before do
      mock_storage_obj = double(Moab::StorageObject)
      allow(storage_repo).to receive(:find_storage_object).and_return(mock_storage_obj)
      @mock_path = double(Pathname)
      allow(mock_storage_obj).to receive(:object_pathname).and_return(@mock_path)
      allow(@mock_path).to receive(:exist?).and_return(false)
    end

    it 'raises exception when object not found' do
      expect { storage_repo.storage_object('jq937jp0017') }.to raise_exception(Moab::ObjectNotFoundException)
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
