module Moab

  # Given a deposit bag, ensures the contents valid for becoming a StorageObjectVersion
  # this is a Shameless Green implementation, combining code from:
  #  - sdr-preservation-core/lib/sdr_ingest/validate_bag  <-- old preservation robots
  #  - archive-utils/lib/bagit_bag  <-- gem only used by sdr-preservation-robots
  #  - archive-utils/lib/file_fixity
  #  - archive-utils/lib/fixity
  # this code adds duplication to this gem (see github issue #119);
  # for example, computing checksums is done
  #  - deposit_bag_validator
  #  - file_signature
  class DepositBagValidator

    BAG_DIR_NOT_FOUND = :bag_dir_not_found
    CHECKSUM_MISMATCH = :checksum_mismatch
    CHECKSUM_TYPE_UNRECOGNIZED = :checksum_type_unrecognized
    INVALID_VERSION_XXX_XML = :invalid_versionXxx_xml
    PAYLOAD_SIZE_MISMATCH = :payload_size_mismatch
    REQUIRED_FILE_NOT_FOUND = :required_file_not_found
    VERSION_MISMATCH_TO_MOAB = :version_mismatch_to_moab
    VERSION_MISSING_FROM_FILE = :version_missing_from_file

    ERROR_CODE_TO_MESSAGES = {
      BAG_DIR_NOT_FOUND => "Deposit bag directory %{bag_dir} does not exist",
      CHECKSUM_MISMATCH => "Failed %{manifest_type} verification. Differences: \n%{diffs}",
      CHECKSUM_TYPE_UNRECOGNIZED => "Checksum type unrecognized: %{checksum_type}; file: %{filename}",
      INVALID_VERSION_XXX_XML => "Unable to parse %{file_pathname}: %{err_info}",
      PAYLOAD_SIZE_MISMATCH => "Failed payload size verification. Expected: %{bag_info_sizes}; found: %{generated_sizes}",
      REQUIRED_FILE_NOT_FOUND => "Deposit bag required file %{file_pathname} not found",
      VERSION_MISMATCH_TO_MOAB => "Version mismatch in %{file_pathname}: Moab expected %{new_version}; found %{file_version}",
      VERSION_MISSING_FROM_FILE => "Version xml file %{version_file} missing data at %{xpath} containing version id"
    }.freeze

    REQUIRED_MANIFEST_CHECKSUM_TYPE = 'sha256'.freeze
    RECOGNIZED_CHECKSUM_ALGORITHMS = [:md5, :sha1, :sha256, :sha384, :sha512].freeze

    TAGMANIFEST = 'tagmanifest'.freeze
    MANIFEST = 'manifest'.freeze
    DATA_DIR_BASENAME = 'data'.freeze
    BAG_INFO_TXT_BASENAME = 'bag-info.txt'.freeze
    VERSION_ADDITIONS_BASENAME = 'versionAdditions.xml'.freeze
    VERSION_INVENTORY_BASENAME = 'versionInventory.xml'.freeze
    VERSION_METADATA_PATH = "#{DATA_DIR_BASENAME}/metadata/versionMetadata.xml".freeze

    REQUIRED_BAG_FILES = [
      DATA_DIR_BASENAME,
      'bagit.txt'.freeze,
      BAG_INFO_TXT_BASENAME,
      "#{MANIFEST}-#{REQUIRED_MANIFEST_CHECKSUM_TYPE}.txt".freeze,
      "#{TAGMANIFEST}-#{REQUIRED_MANIFEST_CHECKSUM_TYPE}.txt".freeze,
      VERSION_ADDITIONS_BASENAME,
      VERSION_INVENTORY_BASENAME,
      VERSION_METADATA_PATH
    ].freeze

    attr_reader :deposit_bag_pathname, :expected_new_version, :result_array

    def initialize(storage_object)
      @deposit_bag_pathname = storage_object.deposit_bag_pathname
      @expected_new_version = storage_object.current_version_id + 1
      @result_array = []
    end

    # returns Array of tiny error hashes, allowing multiple occurrences of a single error code
    def validation_errors
      return [single_error_hash(BAG_DIR_NOT_FOUND, bag_dir: deposit_bag_pathname)] unless deposit_bag_pathname.exist?
      return result_array unless required_bag_files_exist?
      verify_version
      verify_tagmanifests
      verify_payload_size
      verify_payload_manifests
      result_array # attr that accumulates any errors encountered along the way
    end

    private

    def bag_dir_exists?
      deposit_bag_pathname.exist?
    end

    # assumes this is called when result_array is empty, as subsequent checks will use these required files
    def required_bag_files_exist?
      REQUIRED_BAG_FILES.each do |filename|
        pathname = deposit_bag_pathname.join(filename)
        result_array << single_error_hash(REQUIRED_FILE_NOT_FOUND, file_pathname: pathname) unless pathname.exist?
      end
      result_array.empty? ? true : false
    end

    def verify_version
      version_md_pathname = deposit_bag_pathname.join(VERSION_METADATA_PATH)
      version_from_file = last_version_id_from_version_md_xml(version_md_pathname)
      verify_version_from_xml_file(version_md_pathname, version_from_file) if version_from_file

      version_additions_pathname = deposit_bag_pathname.join(VERSION_ADDITIONS_BASENAME)
      version_from_file = version_id_from_version_manifest_xml(version_additions_pathname)
      verify_version_from_xml_file(version_additions_pathname, version_from_file) if version_from_file

      version_inventory_pathname = deposit_bag_pathname.join(VERSION_INVENTORY_BASENAME)
      version_from_file = version_id_from_version_manifest_xml(version_inventory_pathname)
      verify_version_from_xml_file(version_inventory_pathname, version_from_file) if version_from_file
    end

    def last_version_id_from_version_md_xml(version_md_pathname)
      last_version_id_from_xml(version_md_pathname, '/versionMetadata/version/@versionId')
    end

    def version_id_from_version_manifest_xml(version_manifest_xml_pathname)
      last_version_id_from_xml(version_manifest_xml_pathname, '/fileInventory/@versionId')
    end

    def last_version_id_from_xml(pathname, xpath)
      doc = Nokogiri::XML(File.open(pathname.to_s), &:strict)
      version_id = doc.xpath(xpath).last.text unless doc.xpath(xpath).empty?
      return version_id.to_i if version_id
      err_data = {
        version_file: pathname,
        xpath: xpath
      }
      result_array << single_error_hash(VERSION_MISSING_FROM_FILE, err_data) unless version_id
      nil
    rescue StandardError => e
      err_data = {
        file_pathname: pathname,
        err_info: "#{e}\n#{e.backtrace}"
      }
      result_array << single_error_hash(INVALID_VERSION_XXX_XML, err_data)
      nil
    end

    def verify_version_from_xml_file(file_pathname, found)
      return if found == expected_new_version
      err_data = {
        file_pathname: file_pathname,
        new_version: expected_new_version,
        file_version: found
      }
      result_array << single_error_hash(VERSION_MISMATCH_TO_MOAB, err_data)
    end

    # adds to result_array if tagmanifest checksums don't match generated checksums
    def verify_tagmanifests
      tagmanifests_checksums_hash = checksums_hash_from_manifest_files(TAGMANIFEST)
      types_to_generate = checksum_types_from_manifest_checksums_hash(tagmanifests_checksums_hash)
      generated_checksums_hash = generate_tagmanifest_checksums_hash(types_to_generate)
      verify_manifest_checksums(TAGMANIFEST, tagmanifests_checksums_hash, generated_checksums_hash)
    end

    # adds to result_array if manifest checksums don't match generated checksums
    def verify_payload_manifests
      manifests_checksums_hash = checksums_hash_from_manifest_files(MANIFEST)
      types_to_generate = checksum_types_from_manifest_checksums_hash(manifests_checksums_hash)
      generated_checksums_hash = generate_payload_checksums(types_to_generate)
      verify_manifest_checksums(MANIFEST, manifests_checksums_hash, generated_checksums_hash)
    end

    # construct hash based on manifest_type-alg.txt files in bag home dir
    # key: file_name, relative to base_path, value: hash of checksum alg => checksum value
    def checksums_hash_from_manifest_files(manifest_type)
      checksums_hash = {}
      deposit_bag_pathname.children.each do |child_pathname|
        if child_pathname.file?
          child_fname = child_pathname.basename.to_s
          match_result = child_fname.match("^#{manifest_type}-(.*).txt")
          if match_result
            checksum_type = match_result.captures.first.to_sym
            if RECOGNIZED_CHECKSUM_ALGORITHMS.include?(checksum_type)
              child_pathname.readlines.each do |line|
                line.chomp!.strip!
                checksum, file_name = line.split(/[\s*]+/, 2)
                file_checksums = checksums_hash[file_name] || {}
                file_checksums[checksum_type] = checksum
                checksums_hash[file_name] = file_checksums
              end
            else
              result_array << single_error_hash(CHECKSUM_TYPE_UNRECOGNIZED, checksum_type: checksum_type, filename: child_pathname)
            end
          end
        end
      end
      checksums_hash
    end

    # generate hash of checksums by file name for bag home dir files
    def generate_tagmanifest_checksums_hash(types_to_generate)
      # all names in the bag home dir except those starting with 'tagmanifest'
      home_dir_pathnames = deposit_bag_pathname.children.reject { |file| file.basename.to_s.start_with?(TAGMANIFEST) }
      hash_with_full_pathnames = generate_checksums_hash(home_dir_pathnames, types_to_generate)
      # return hash keys as basenames only
      hash_with_full_pathnames.map { |k, v| [Pathname.new(k).basename.to_s, v] }.to_h
    end

    # generate hash of checksums by file name for bag data dir files
    def generate_payload_checksums(types_to_generate)
      data_pathnames = deposit_bag_pathname.join(DATA_DIR_BASENAME).find
      hash_with_full_pathnames = generate_checksums_hash(data_pathnames, types_to_generate)
      # return hash keys beginning with 'data/'
      hash_with_full_pathnames.map { |k, v| [Pathname.new(k).relative_path_from(deposit_bag_pathname).to_s, v] }.to_h
    end

    def generate_checksums_hash(pathnames, types_to_generate)
      file_checksums_hash = {}
      pathnames.each do |pathname|
        file_checksums_hash[pathname.to_s] = generated_checksums(pathname, types_to_generate) if pathname.file?
      end
      file_checksums_hash
    end

    def generated_checksums(pathname, types_to_generate)
      my_digester_hash = digester_hash(types_to_generate)
      pathname.open('r') do |stream|
        while (buffer = stream.read(8192))
          my_digester_hash.each_value { |digest| digest.update(buffer) }
        end
      end
      file_checksums = {}
      my_digester_hash.each do |checksum_type, digest|
        file_checksums[checksum_type] = digest.hexdigest
      end
      file_checksums
    end

    def digester_hash(types_to_generate=DEFAULT_CHECKSUM_TYPES)
      types_to_generate.each_with_object({}) do |checksum_type, digester_hash|
        case checksum_type
        when :md5
          digester_hash[checksum_type] = Digest::MD5.new
        when :sha1
          digester_hash[checksum_type] = Digest::SHA1.new
        when :sha256
          digester_hash[checksum_type] = Digest::SHA2.new(256)
        when :sha384
          digesters[checksum_type] = Digest::SHA2.new(384)
        when :sha512
          digesters[checksum_type] = Digest::SHA2.new(512)
        else
          result_array << single_error_hash(CHECKSUM_TYPE_UNRECOGNIZED, checksum_type: checksum_type, filename: nil)
        end
        digester_hash
      end
    end

    def verify_manifest_checksums(manifest_type, manifests_checksum_hash, generated_checksum_hash)
      diff_hash = {}
      # NOTE: this is intentionally | instead of ||
      (manifests_checksum_hash.keys | generated_checksum_hash.keys).each do |file_name|
        manifest_checksums = manifests_checksum_hash[file_name] || {}
        generated_checksums = generated_checksum_hash[file_name] || {}
        if manifest_checksums != generated_checksums
          cdh = checksums_diff_hash(manifest_checksums, generated_checksums, manifest_type, 'generated')
          diff_hash[file_name] = cdh if cdh
        end
      end
      return if diff_hash.empty?
      err_data = {
        manifest_type: manifest_type,
        diffs: diff_hash
      }
      result_array << single_error_hash(CHECKSUM_MISMATCH, err_data)
    end

    def checksums_diff_hash(left_checksums, right_checksums, left_label, right_label)
      diff_hash = {}
      # NOTE: these are intentionally & and | instead of && and ||
      checksum_types_to_compare = (left_checksums.keys & right_checksums.keys)
      checksum_types_to_compare = (left_checksums.keys | right_checksums.keys) if checksum_types_to_compare.empty?
      checksum_types_to_compare.each do |type|
        left_checksum = left_checksums[type]
        right_checksum = right_checksums[type]
        if left_checksum != right_checksum
          diff_hash[type] = { left_label => left_checksum, right_label => right_checksum }
        end
      end
      diff_hash.empty? ? nil : diff_hash
    end

    def verify_payload_size
      sizes_from_bag_info_file = bag_info_payload_size
      generated_sizes = generated_payload_size
      return if sizes_from_bag_info_file == generated_sizes
      err_data = {
        bag_info_sizes: sizes_from_bag_info_file,
        generated_sizes: generated_sizes
      }
      result_array << single_error_hash(PAYLOAD_SIZE_MISMATCH, err_data)
    end

    def bag_info_payload_size
      bag_info_txt_pathname = deposit_bag_pathname.join(BAG_INFO_TXT_BASENAME)
      bag_info_txt_pathname.readlines.each do |line|
        line.chomp!.strip!
        key, value = line.split(':', 2)
        if key.strip == 'Payload-Oxum'
          num_bytes, num_files = value.strip.split('.') if value
          return { bytes: num_bytes.to_i, files: num_files.to_i }
        end
      end
    end

    def generated_payload_size
      payload_pathname = deposit_bag_pathname.join(DATA_DIR_BASENAME)
      payload_pathname.find.select(&:file?).each_with_object(bytes: 0, files: 0) do |file, hash|
        hash[:bytes] += file.size
        hash[:files] += 1
        hash
      end
    end

    # checksums_hash: { fname => {:md5=>"xxx", :sha1=>"yyy"}, fname => ... }
    def checksum_types_from_manifest_checksums_hash(checksums_hash)
      types = []
      checksums_hash.each_value { |v| v.each_key { |k| types << k unless types.include?(k) } }
      types
    end

    def single_error_hash(error_code, err_data_hash)
      { error_code => error_code_msg(error_code, err_data_hash) }
    end

    def error_code_msg(error_code, err_data_hash)
      ERROR_CODE_TO_MESSAGES[error_code] % err_data_hash
    end
  end
end
