# frozen_string_literal: true

describe Moab::DepositBagValidator do
  let(:deposit_dir_pathname) { Pathname(File.join(File.dirname(__FILE__), '../../fixtures/deposit')) }

  describe '#validation_errors' do
    describe 'returns empty Array if there are no errors' do
      describe 'initial version of Moab' do
        it 'metadata only' do
          bag_pathname = Pathname(File.join(deposit_dir_pathname, 'metadata-only-v1'))
          storage_obj = instance_double(Moab::StorageObject, deposit_bag_pathname: bag_pathname, current_version_id: 0)
          expect(described_class.new(storage_obj).validation_errors).to eq []
        end

        it 'metadata and content' do
          bag_pathname = Pathname(File.join(deposit_dir_pathname, 'xm152jw3650-etd'))
          storage_obj = instance_double(Moab::StorageObject, deposit_bag_pathname: bag_pathname, current_version_id: 0)
          expect(described_class.new(storage_obj).validation_errors).to eq []
        end
      end

      describe 'new version updates Moab' do
        it 'metadata only' do
          bag_pathname = Pathname(File.join(deposit_dir_pathname, 'cr123dt0367-kahn-md-only'))
          storage_obj = instance_double(Moab::StorageObject, deposit_bag_pathname: bag_pathname, current_version_id: 5)
          expect(described_class.new(storage_obj).validation_errors).to eq []
        end

        it 'metadata and content' do
          bag_pathname = Pathname(File.join(deposit_dir_pathname, 'yx086st8953-md-and-content'))
          storage_obj = instance_double(Moab::StorageObject, deposit_bag_pathname: bag_pathname, current_version_id: 2)
          expect(described_class.new(storage_obj).validation_errors).to eq []
        end
      end
    end

    it 'returns 1 item Array with BAG_DIR_NOT_FOUND result hash if deposit bag directory does not exist' do
      bag_pathname = Pathname(File.join(deposit_dir_pathname, 'not-there'))
      storage_obj = instance_double(Moab::StorageObject, deposit_bag_pathname: bag_pathname, current_version_id: 0)
      dbv = described_class.new(storage_obj)
      code = described_class::BAG_DIR_NOT_FOUND
      expect(dbv.validation_errors).to eq [{ code => "Deposit bag directory #{bag_pathname} does not exist" }]
    end

    it 'REQUIRED_FILE_NOT_FOUND result hash for each missing req file' do
      bag_pathname = Pathname(File.join(deposit_dir_pathname, 'missing-required-files'))
      storage_obj = instance_double(Moab::StorageObject, deposit_bag_pathname: bag_pathname, current_version_id: 0)
      vdn_errors = described_class.new(storage_obj).validation_errors
      code = described_class::REQUIRED_FILE_NOT_FOUND
      expect(vdn_errors.size).to eq 3
      ['bag-info.txt', 'versionAdditions.xml', 'data/metadata/versionMetadata.xml'].each do |missing_file|
        exp_msg_regexp = Regexp.new("Deposit bag required file .*#{Regexp.escape(missing_file)} not found")
        expect(vdn_errors).to include(code => a_string_matching(exp_msg_regexp))
      end
    end

    describe 'verify new version number' do
      ['versionMetadata.xml', 'versionAdditions.xml', 'versionInventory.xml'].each do |file|
        it "when version is missing from #{file}, returns VERSION_MISSING_FROM_FILE result" do
          bag_pathname = Pathname(File.join(deposit_dir_pathname, 'missing-versionId'))
          storage_obj = instance_double(Moab::StorageObject, deposit_bag_pathname: bag_pathname, current_version_id: 0)
          vdn_errors = described_class.new(storage_obj).validation_errors
          code = described_class::VERSION_MISSING_FROM_FILE
          exp_msg_regexp =
            Regexp.new("Version xml file .*#{Regexp.escape(file)} missing data at .*@versionId.* containing version id")
          expect(vdn_errors.size).to eq 3
          expect(vdn_errors).to include(code => a_string_matching(exp_msg_regexp))
        end

        it "when version in versionXXX.xml doesn't match what Moab expects, returns VERSION_MISMATCH_TO_MOAB result" do
          bag_pathname = Pathname(File.join(deposit_dir_pathname, 'metadata-only-v1'))
          storage_obj = instance_double(Moab::StorageObject, deposit_bag_pathname: bag_pathname, current_version_id: 1)
          vdn_errors = described_class.new(storage_obj).validation_errors
          code = described_class::VERSION_MISMATCH_TO_MOAB
          exp_msg_regexp = Regexp.new("Version mismatch in .*#{Regexp.escape(file)}: Moab expected 2; found 1")
          expect(vdn_errors.size).to eq 3
          expect(vdn_errors).to include(code => a_string_matching(exp_msg_regexp))
        end

        it "when #{file} does not parse, returns INVALID_VERSION_XXX_XML result" do
          bag_pathname = Pathname(File.join(deposit_dir_pathname, 'unparseable-version-xml'))
          storage_obj = instance_double(Moab::StorageObject, deposit_bag_pathname: bag_pathname, current_version_id: 0)
          vdn_errors = described_class.new(storage_obj).validation_errors
          code = described_class::INVALID_VERSION_XXX_XML
          exp_msg_regexp = Regexp.new("Unable to parse .*#{Regexp.escape(file)}: .*FATAL:.*nokogiri.*", Regexp::MULTILINE)
          expect(vdn_errors.size).to eq 3
          expect(vdn_errors).to include(code => a_string_matching(exp_msg_regexp))
        end
      end
    end

    describe 'when unrecognized checksum, result array has CHECKSUM_TYPE_UNRECOGNIZED result hash' do
      before do
        bag_pathname = Pathname(File.join(deposit_dir_pathname, 'unknown-checksum-alg'))
        @storage_obj = instance_double(Moab::StorageObject, deposit_bag_pathname: bag_pathname, current_version_id: 0)
      end

      let(:vdn_errors) { described_class.new(@storage_obj).validation_errors }
      let(:exp_code) { described_class::CHECKSUM_TYPE_UNRECOGNIZED }
      let(:err_msg_prefix) { Regexp.escape("Checksum type unrecognized: sha666; file: ") }

      it 'tagmanifest file of unrecognized checksum type' do
        expect(vdn_errors.size).to eq 2
        expect(vdn_errors).to include(exp_code => a_string_matching("#{err_msg_prefix}.*\/tagmanifest-sha666.txt"))
      end

      it 'manifest file of unrecognized checksum type' do
        expect(vdn_errors.size).to eq 2
        expect(vdn_errors).to include(exp_code => a_string_matching("#{err_msg_prefix}.*\/manifest-sha666.txt"))
      end

      it 'in version_xxx.xml file' do
        # NOTE:  bad checksum types within files that are NOT part of bag structure will NOT be flagged here
        expect(vdn_errors).not_to include(exp_code => "#{err_msg_prefix}.*\/versionAdditions.xml")
        expect(vdn_errors).not_to include(exp_code => "#{err_msg_prefix}.*\/versionInventory.xml")
      end
    end

    it 'result array has CHECKSUM_MISMATCH result hash when tagmanifest checksum verification fails' do
      bag_pathname = Pathname(File.join(deposit_dir_pathname, 'tagmanifest-checksum-mismatch'))
      storage_obj = instance_double(Moab::StorageObject, deposit_bag_pathname: bag_pathname, current_version_id: 0)
      dbv = described_class.new(storage_obj)
      code = described_class::CHECKSUM_MISMATCH
      from_file = '6666666666666666666666666666666666666666666666666666666666666666'
      generated = '4227e88364c1f99ceb6aa9da763f5a9db345cb56d4a97ea56e5fb4e34e5123fd'
      exp_msg = "Failed tagmanifest verification. Differences:.*#{Regexp.escape('bagit.txt')}" \
        ".*sha256.*manifest.*#{from_file}.*generated.*#{generated}.*"
      expect(dbv.validation_errors).to match([{ code => a_string_matching(/#{exp_msg}/m) }])
    end

    it 'result array has PAYLOAD_SIZE_MISMATCH result hash when payload size verification fails' do
      bag_pathname = Pathname(File.join(deposit_dir_pathname, 'payload-size-mismatch'))
      storage_obj = instance_double(Moab::StorageObject, deposit_bag_pathname: bag_pathname, current_version_id: 0)
      dbv = described_class.new(storage_obj)
      code = described_class::PAYLOAD_SIZE_MISMATCH
      size_from_file = dbv.send(:bag_info_payload_size)
      exp_msg = "Failed payload size verification. Expected: #{size_from_file}; found: {:bytes=>4300, :files=>4}"
      expect(dbv.validation_errors).to eq [{ code => exp_msg }]
    end

    it 'result array has CHECKSUM_MISMATCH result hash when payload checksum verification fails' do
      bag_pathname = Pathname(File.join(deposit_dir_pathname, 'payload-checksum-mismatch'))
      storage_obj = instance_double(Moab::StorageObject, deposit_bag_pathname: bag_pathname, current_version_id: 0)
      dbv = described_class.new(storage_obj)
      code = described_class::CHECKSUM_MISMATCH
      from_file = '6666666666666666666666666666666666666666666666666666666666666666'
      generated = 'c5410a4bb014d9d65371a0335d06483626ce35115124270ce08b01432c80e4b0'
      exp_msg = "Failed manifest verification. Differences:.*#{Regexp.escape('data/metadata/versionMetadata.xml')}" \
        ".*sha256.*manifest.*#{from_file}.*generated.*#{generated}.*"
      expect(dbv.validation_errors).to match([{ code => a_string_matching(/#{exp_msg}/m) }])
    end
  end
end
