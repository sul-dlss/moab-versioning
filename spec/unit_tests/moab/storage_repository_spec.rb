# frozen_string_literal: true

describe Moab::StorageRepository do
  let(:storage_repo) { described_class.new }
  let(:derivatives_storage_root) { derivatives_dir }
  let(:derivatives2_storage_root) { fixtures_dir.join('derivatives2') }
  let(:newnode_storage_root) { fixtures_dir.join('newnode') }

  describe '#storage_roots' do
    it 'returns the configured values' do
      # these are set in spec_config.rb
      expect(storage_repo.storage_roots[0]).to eq derivatives_storage_root
      expect(storage_repo.storage_roots[1]).to eq derivatives2_storage_root
      expect(storage_repo.storage_roots[2]).to eq newnode_storage_root
    end
  end

  describe '#storage_trunk' do
    it 'returns the configured values' do
      # set in spec_config.rb
      expect(storage_repo.storage_trunk).to eq 'ingests'
    end
  end

  describe '#deposit_trunk' do
    it 'returns the configured values' do
      # set in spec_config.rb
      expect(storage_repo.deposit_trunk).to eq 'packages'
    end
  end

  describe '#storage_branch' do
    it 'splits the argument into 2-character segments, followed by a copy of the argument, if not overridden in subclass' do
      expect(storage_repo.storage_branch('abcdef')).to eq 'ab/cd/ef/abcdef'
    end
  end

  describe '#deposit_branch' do
    it 'returns the argument as is, if not overridden in subclass' do
      expect(storage_repo.deposit_branch('abcdef')).to eq 'abcdef'
    end
  end

  describe '#find_storage_root' do
    context 'with new object' do
      it 'returns the newest/last (most empty) filesystem' do
        expect(storage_repo.find_storage_root('abcdef')).to eq newnode_storage_root
      end
    end

    context 'with existing object' do
      before do
        allow(storage_repo).to receive(:storage_branch).and_return(BARE_TEST_DRUID)
      end

      it 'returns the storage root containing the object' do
        expect(storage_repo.find_storage_root(BARE_TEST_DRUID)).to eq derivatives_storage_root
      end
    end

    context 'with misconfigured storage_trunk' do
      before do
        allow(storage_repo).to receive(:storage_trunk).and_return('junk')
      end

      it 'raises exception when storage_trunk does not exist' do
        expect { storage_repo.find_storage_root('abcdef') }.to raise_exception(Moab::MoabRuntimeError, /Storage area not found/)
      end
    end
  end

  describe '#search_storage_objects' do
    context 'with new storage objects' do
      it 'returns an empty array' do
        expect(storage_repo.search_storage_objects('abcdef')).to be_empty
      end
    end

    context 'with existing storage objects' do
      before do
        allow(storage_repo).to receive(:storage_branch).and_return(BARE_TEST_DRUID)
      end

      it 'finds objects with known storage branches' do
        found_storage_objs = storage_repo.search_storage_objects(BARE_TEST_DRUID)
        expect(found_storage_objs.length).to eq 2
        expect(found_storage_objs[0].object_pathname).to eq derivatives_storage_root.join('ingests/jq937jp0017')
        expect(found_storage_objs[1].object_pathname).to eq derivatives2_storage_root.join('ingests/jq937jp0017')
      end
    end

    it 'exception raised when storage_trunk is bogus' do
      allow(storage_repo).to receive(:storage_trunk).and_return('junk')
      expect do
        storage_repo.search_storage_objects('abcdef')
      end.to raise_exception(Moab::MoabRuntimeError, /Storage area not found/)
    end
  end

  describe '#find_storage_object' do
    context 'when storage object exists' do
      let(:found_storage_obj) { storage_repo.find_storage_object(BARE_TEST_DRUID) }

      before do
        allow(storage_repo).to receive(:storage_branch).and_return(BARE_TEST_DRUID)
      end

      it 'returns storage object populated as expected' do
        expect(found_storage_obj.object_pathname).to eq derivatives_storage_root.join('ingests/jq937jp0017')
        expect(found_storage_obj.deposit_bag_pathname).to eq derivatives_storage_root.join('packages/jq937jp0017')
      end
    end
  end

  describe '#storage_object' do
    let(:mock_path) { instance_double(Pathname) }
    let(:mock_storage_obj) { instance_double(Moab::StorageObject) }

    before do
      allow(storage_repo).to receive(:find_storage_object).and_return(mock_storage_obj)
      allow(mock_storage_obj).to receive(:object_pathname).and_return(mock_path)
      allow(mock_path).to receive(:exist?).and_return(false)
      allow(mock_path).to receive(:mkpath)
    end

    it 'raises exception when object not found' do
      expect { storage_repo.storage_object(BARE_TEST_DRUID) }.to raise_exception(Moab::ObjectNotFoundException)
    end

    it 'creates path when create set to true' do
      storage_repo.storage_object(BARE_TEST_DRUID, true)
      expect(mock_path).to have_received(:mkpath)
    end
  end

  describe '#object_size' do
    context 'when there is content' do
      before do
        allow(storage_repo).to receive(:storage_branch).and_return(BARE_TEST_DRUID)
      end

      it 'returns the size of a moab object' do
        # values may differ from file system to file system (which is to be expected).
        # if this test fails on your mac, make sure you don't have any extraneous .DS_Store files
        # lingering in the fixture directories.
        expect(storage_repo.object_size(BARE_TEST_DRUID)).to be_between(345_000, 346_000)
      end
    end
  end

  describe '#store_new_object_version' do
    let(:bag_pathname) { 'bag_pathname' }
    let(:object_pathname) { 'object_pathname' }
    let(:storage_object) { instance_double(Moab::StorageObject) }

    before do
      allow(storage_object).to receive(:ingest_bag)
      allow(storage_object).to receive(:object_pathname).and_return(object_pathname)
      allow(storage_repo).to receive(:storage_object).with(FULL_TEST_DRUID, true).and_return(storage_object)
    end

    it 'calls storage_object and ingest_bag' do
      storage_repo.store_new_object_version(FULL_TEST_DRUID, bag_pathname)
      expect(storage_object).to have_received(:ingest_bag).with(bag_pathname)
      expect(storage_repo).to have_received(:storage_object).with(FULL_TEST_DRUID, true)
    end
  end
end
