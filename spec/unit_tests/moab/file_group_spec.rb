def basic_expectations(file_group)
  expect(file_group).to be_instance_of(Moab::FileGroup)
  expect(file_group.files).to be_kind_of(Array)
  expect(file_group.signature_hash).to be_kind_of(Hash)
end

describe 'Moab::FileGroup' do

  it '#initialize' do
    basic_expectations(Moab::FileGroup.new())
  end
  it '#initialize with empty hash argument' do
    basic_expectations(Moab::FileGroup.new({}))
  end
  it '#initialize with populated hash argument' do
    # test initialization with options hash
    opts = Hash.new
    opts[:group_id]    = 'Test group_id'
    opts[:data_source] = 'Test data_source'
    file_group = Moab::FileGroup.new(opts)
    basic_expectations(file_group)
    expect(file_group.group_id   ).to eq(opts[:group_id])
    expect(file_group.data_source).to eq(opts[:data_source])
    expect(file_group.file_count ).to eq(0)
    expect(file_group.byte_count ).to eq(0)
    expect(file_group.block_count).to eq(0)
    expect(file_group.files).to eq([])
  end

  before(:all) do
    @file_group = Moab::FileGroup.new.group_from_directory(@fixtures.join('data/jq937jp0017/v0001'),recursive=true)
  end

  it 'Provides instance attribute get/set' do
    @file_group.group_id    = 'Test group_id'
    @file_group.data_source = 'Test data_source'
    expect(@file_group.group_id   ).to eq('Test group_id')
    expect(@file_group.data_source).to eq('Test data_source')
    expect(@file_group.file_count ).to eq(11)
    expect(@file_group.byte_count ).to eq(217820)
    expect(@file_group.block_count).to eq(216)
    expect(@file_group.files.size ).to eq(11)
    expect(@file_group.signature_hash.size).to eq(11)
    expect(@file_group.base_directory.to_s).to include('data/jq937jp0017/v0001')
  end

  describe 'INSTANCE METHODS' do

    before(:each) do
      @v1_file_group  = Moab::FileGroup.new.group_from_directory(@fixtures.join('data/jq937jp0017/v0001/content'),recursive=true)
      @new_file_group = Moab::FileGroup.new
    end

    it 'provides path_hash, path_list, path_hash_subset' do
      list = %w[intro-1.jpg intro-2.jpg page-1.jpg page-2.jpg page-3.jpg title.jpg]
      expect(@v1_file_group.path_hash().keys).to eq(list)
      expect(@v1_file_group.path_list       ).to eq(list)
      sigs   = (0..2).map{ |i| @v1_file_group.files[i].signature }
      subset = @v1_file_group.path_hash_subset(sigs)
      expect(subset.size).to eq(3)
    end

    it '#add_file' do
      manifestation = @v1_file_group.files[0]
      @new_file_group.add_file(manifestation)
      expect(@new_file_group.files[0]).to eq(manifestation)
    end

    it '#add_file_instance can add serially' do
      manifestation = @v1_file_group.files[0]
      manifestation.instances.each do |instance|
        @new_file_group.add_file_instance(manifestation.signature, instance)
      end
      expect(@new_file_group.files[0]).to eq(manifestation)

      # add a second file instance to an existing manifestation
      @new_file_group.add_file_instance(manifestation.signature, Moab::FileInstance.new(:path => "/my/path"))
      expect(@new_file_group.files[0].instances.size).to eq(2)
    end

    it '#remove_file_having_path affects file_count' do
      file_group = Moab::FileGroup.new.group_from_directory(@fixtures.join('data/jq937jp0017/v0001/content'),true)
      before_file_count = file_group.file_count
      file_group.remove_file_having_path("page-1.jpg")
      expect(file_group.file_count).to eq(before_file_count - 1)
    end

    context "#is_descendent_of_base?" do
      # FIXME:  shouldn't this method be named descendent_of_base?
      before(:each) { @new_file_group.base_directory = @fixtures.join('data') }
      it "true when condition met" do
        expect(@new_file_group).to be_is_descendent_of_base(@fixtures.join('data/jq937jp0017/v0001'))
      end

      it "raises exception if false (FIXME!)" do
        base = @fixtures.join('derivatives/manifests')
        # FIXME:  shouldn't it simply return false?
        expect{ @new_file_group.is_descendent_of_base?(base) }.to raise_exception(/is not a descendent of/)
      end
    end

    it 'Can group from bagit subdirectory' do
      expect(@new_file_group).to receive(:group_from_directory).with('my_directory', false)
      @new_file_group.group_from_bagit_subdir('my_directory', 'my_digests', false)
      expect(@new_file_group.instance_variable_get(:@signatures_from_bag)).to eq('my_digests')
    end

    it '#group_from_directory' do
      directory = @fixtures.join('data/jq937jp0017/v0001/content')
      expect(@new_file_group).to receive(:harvest_directory).with(directory, true)
      group = @new_file_group.group_from_directory(directory, true)
      basic_expectations(group)
      expect(group.base_directory).to eq(directory.realpath)
      expect(group.data_source).to eq(directory.realpath.to_s)
    end

    it '#harvest_directory does something?!?' do         ## TODO: NO EXPECTATIONS DEFINED
      path = @fixtures.join('derivatives/manifests')
      file_group = Moab::FileGroup.new
      file_group.base_directory=path
      file_group.harvest_directory(path,true)
      file_group.file_count=0

      path = @fixtures.join('derivatives/packages/v0001')
      second_group = Moab::FileGroup.new
      second_group.base_directory=path
      second_group.harvest_directory(path,false)
      second_group.file_count=0
    end

    it '#add_physical_file adds data for a physical file to array of files in group' do
      pathname = @fixtures.join('data/jq937jp0017/v0001/content/title.jpg')
      group = Moab::FileGroup.new
      group.base_directory = @fixtures.join('data/jq937jp0017/v0001/content')
      group.add_physical_file(pathname)
      expect(group.files.size).to eq(1)
      expect(group.files[0].signature).to eq(Moab::FileSignature.new(
          :size=>40873, :md5=>"1a726cd7963bd6d3ceb10a8c353ec166", :sha1=>"583220e0572640abcd3ddd97393d224e8053a6ad"))
      expect(group.files[0].instances[0].path).to eq('title.jpg')

      sig1 = double(Moab::FileSignature)
      sig2 = double(Moab::FileSignature)
      signature_for_path = double(Hash)

      allow(Moab::FileSignature).to receive(:new).and_return(sig1)
      expect(sig1).to receive(:signature_from_file).with(pathname)
      group.add_physical_file(pathname)

      expect(signature_for_path).to receive(:[]).with(pathname).twice.and_return(sig2)
      expect(sig2).to receive(:complete?).and_return(false)
      expect(sig2).to receive(:normalized_signature).with(pathname).and_return(sig2)
      expect(group).to receive(:add_file_instance)
      group.instance_variable_set(:@signatures_from_bag, signature_for_path)
      group.add_physical_file(pathname)
    end

  end

end
