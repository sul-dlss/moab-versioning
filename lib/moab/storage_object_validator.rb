require 'moab'
require 'set'

module Moab
  # Given a druid path, are the contents actually a well-formed Moab?
  # Shameless green: repetitious code included.
  class StorageObjectValidator

    METADATA_DIR = "metadata".freeze
    CONTENT_DIR = "content".freeze
    EXPECTED_DATA_SUB_DIRS = [CONTENT_DIR, METADATA_DIR].freeze
    IMPLICIT_DIRS = ['.', '..', '.keep'].freeze # unlike Find.find, Dir.entries returns the current/parent dirs
    DATA_DIR = "data".freeze
    MANIFESTS_DIR = 'manifests'.freeze
    EXPECTED_VERSION_SUB_DIRS = [DATA_DIR, MANIFESTS_DIR].freeze
    MANIFEST_INVENTORY_PATH = File.join(MANIFESTS_DIR, "manifestInventory.xml").freeze
    SIGNATURE_CATALOG_PATH = File.join(MANIFESTS_DIR, "signatureCatalog.xml").freeze

    FORBIDDEN_CONTENT_SUB_DIRS = ([DATA_DIR, MANIFESTS_DIR] + EXPECTED_DATA_SUB_DIRS).freeze

    # error codes
    INCORRECT_DIR_CONTENTS = 0
    MISSING_DIR = 1
    EXTRA_CHILD_DETECTED = 2
    VERSION_DIR_BAD_FORMAT = 3
    NO_SIGNATURE_CATALOG = 4
    NO_MANIFEST_INVENTORY = 5
    NO_FILES_IN_MANIFEST_DIR= 6
    VERSIONS_NOT_IN_ORDER = 7
    METADATA_SUB_DIRS_DETECTED = 8
    FILES_IN_VERSION_DIR = 9
    NO_FILES_IN_METADATA_DIR = 10
    NO_FILES_IN_CONTENT_DIR = 11
    CONTENT_SUB_DIRS_DETECTED = 12
    BAD_SUB_DIR_IN_CONTENT_DIR = 13

    attr_reader :storage_obj_path

    def initialize(storage_object)
      @storage_obj_path = storage_object.object_pathname
      @directory_entries_hash = {}
    end

    def validation_errors
      errors = []
      errors.concat check_correctly_named_version_dirs
      errors.concat check_sequential_version_dirs if errors.empty?
      errors.concat check_correctly_formed_moab if errors.empty?
      errors
    end

    def self.error_code_to_messages
      @error_code_to_messages ||=
        {
          INCORRECT_DIR_CONTENTS => "Incorrect items under %{addl} directory",
          MISSING_DIR => "Missing directory: %{addl}",
          EXTRA_CHILD_DETECTED => "Unexpected item in path: %{addl}",
          VERSION_DIR_BAD_FORMAT => "Version directory name not in 'v00xx' format: %{addl}",
          FILES_IN_VERSION_DIR => "Version directory %{addl} should not contain files; only the manifests and data directories",
          NO_SIGNATURE_CATALOG => "Version %{addl}: Missing signatureCatalog.xml",
          NO_MANIFEST_INVENTORY => "Version %{addl}: Missing manifestInventory.xml",
          NO_FILES_IN_MANIFEST_DIR => "Version %{addl}: No files present in manifest dir",
          METADATA_SUB_DIRS_DETECTED => "Version %{addl}: metadata directory should only contain files, not directories",
          VERSIONS_NOT_IN_ORDER => "Should contain only sequential version directories. Current directories: %{addl}",
          NO_FILES_IN_METADATA_DIR => "Version %{addl}: No files present in metadata dir",
          NO_FILES_IN_CONTENT_DIR => "Version %{addl}: No files present in content dir",
          CONTENT_SUB_DIRS_DETECTED => "Version %{addl}: content directory should only contain files, not directories",
          BAD_SUB_DIR_IN_CONTENT_DIR => "Version %{addl}: content directory has forbidden sub-directory name: vnnnn or #{FORBIDDEN_CONTENT_SUB_DIRS}"
        }.freeze
    end

    private

    def version_directories
      @vdirs ||= directory_entries(storage_obj_path)
    end

    def check_correctly_named_version_dirs
      errors = []
      errors << result_hash(MISSING_DIR, 'no versions exist') unless version_directories.count > 0
      version_directories.each do |version_dir|
        errors << result_hash(VERSION_DIR_BAD_FORMAT, version_dir) unless version_dir_format?(version_dir)
      end
      errors
    end

    def version_dir_format?(dirname)
      dirname =~ /^[v]\d{4}$/
    end

    # call only if the version directories are "correctly named" vdddd
    def check_sequential_version_dirs
      errors = []
      version_directories.each_with_index do |dir_name, index|
        expected_vers_num = index + 1 # version numbering starts at 1, array indexing starts at 0
        if dir_name[1..-1].to_i != expected_vers_num
          errors << result_hash(VERSIONS_NOT_IN_ORDER, version_directories)
          break
        end
      end
      errors
    end

    def check_correctly_formed_moab
      errors = []
      version_directories.each do |version_dir|
        version_path = File.join(storage_obj_path, version_dir)
        version_error_count = errors.size
        errors.concat check_version_sub_dirs(version_path, version_dir)
        errors.concat check_required_manifest_files(version_path, version_dir) if version_error_count == errors.size
        errors.concat check_data_directory(version_path, version_dir) if version_error_count == errors.size
      end
      errors
    end

    def check_version_sub_dirs(version_path, version)
      errors = []
      version_sub_dirs = directory_entries(version_path)
      version_sub_dir_count = version_sub_dirs.size
      if version_sub_dir_count == EXPECTED_VERSION_SUB_DIRS.size
        errors.concat expected_version_sub_dirs(version_path, version)
      elsif version_sub_dir_count > EXPECTED_VERSION_SUB_DIRS.size
        errors.concat found_unexpected(version_sub_dirs, version, EXPECTED_VERSION_SUB_DIRS)
      elsif version_sub_dir_count < EXPECTED_VERSION_SUB_DIRS.size
        errors.concat missing_dir(version_sub_dirs, version, EXPECTED_VERSION_SUB_DIRS)
      end
      errors
    end

    def check_data_directory(version_path, version)
      errors = []
      data_dir_path = File.join(version_path, DATA_DIR)
      data_sub_dirs = directory_entries(data_dir_path)
      errors.concat check_data_sub_dirs(version, data_sub_dirs)
      errors.concat check_metadata_dir_files_only(version_path) if errors.empty?
      errors.concat check_optional_content_dir(version_path) if data_sub_dirs.include?('content') && errors.empty?
      errors
    end

    def check_data_sub_dirs(version, data_sub_dirs)
      errors = []
      if data_sub_dirs.size > EXPECTED_DATA_SUB_DIRS.size
        errors.concat found_unexpected(data_sub_dirs, version, EXPECTED_DATA_SUB_DIRS)
      else
        errors.concat missing_dir(data_sub_dirs, version, [METADATA_DIR]) unless data_sub_dirs.include?(METADATA_DIR)
        errors.concat found_unexpected(data_sub_dirs, version, EXPECTED_DATA_SUB_DIRS) unless subset?(data_sub_dirs,
                                                                                                      EXPECTED_DATA_SUB_DIRS)
      end
      errors
    end

    def check_optional_content_dir(version_path)
      errors = []
      content_dir_path = File.join(version_path, DATA_DIR, CONTENT_DIR)
      errors << result_hash(NO_FILES_IN_CONTENT_DIR, basename(version_path)) if directory_entries(content_dir_path).empty?
      if contains_sub_dir?(content_dir_path) && contains_forbidden_content_sub_dir?(content_dir_path)
        errors << result_hash(BAD_SUB_DIR_IN_CONTENT_DIR, basename(version_path))
      end
      errors
    end

    def contains_forbidden_content_sub_dir?(path)
      sub_dirs(path).detect { |sub_dir| content_sub_dir_forbidden?(sub_dir) }
    end

    def content_sub_dir_forbidden?(dirname)
      FORBIDDEN_CONTENT_SUB_DIRS.include?(dirname) || version_dir_format?(dirname)
    end

    def subset?(first_array, second_array)
      first_array.to_set.subset?(second_array.to_set)
    end

    def check_metadata_dir_files_only(version_path)
      errors = []
      metadata_dir_path = File.join(version_path, DATA_DIR, METADATA_DIR)
      errors << result_hash(NO_FILES_IN_METADATA_DIR, basename(version_path)) if directory_entries(metadata_dir_path).empty?
      errors << result_hash(METADATA_SUB_DIRS_DETECTED, basename(version_path)) if contains_sub_dir?(metadata_dir_path)
      errors
    end

    # This method removes the implicit '.' and '..' directories.
    # Returns an array of strings.
    def directory_entries(path)
      @directory_entries_hash[path] ||=
        begin
          dirs = []
          (Dir.entries(path).sort - IMPLICIT_DIRS).each do |child|
            dirs << child
          end
          dirs
        end
    end

    def found_unexpected(array, version, required_sub_dirs)
      errors = []
      unexpected = (array - required_sub_dirs)
      unexpected = "#{unexpected} Version: #{version}"
      errors << result_hash(EXTRA_CHILD_DETECTED, unexpected)
      errors
    end

    def missing_dir(array, version, required_sub_dirs)
      errors = []
      missing = (required_sub_dirs - array)
      missing ="#{missing} Version: #{version}"
      errors << result_hash(MISSING_DIR, missing)
      errors
    end

    def expected_version_sub_dirs(version_path, version)
      errors = []
      version_sub_dirs = directory_entries(version_path)
      errors << result_hash(INCORRECT_DIR_CONTENTS, version) unless version_sub_dirs == EXPECTED_VERSION_SUB_DIRS
      if contains_file?(version_path)
        errors << result_hash(FILES_IN_VERSION_DIR, version)
      end
      errors
    end

    def contains_sub_dir?(path)
      directory_entries(path).detect { |entry| File.directory?(File.join(path, entry)) }
    end

    def contains_file?(path)
      directory_entries(path).detect { |entry| File.file?(File.join(path, entry)) }
    end

    def sub_dirs(path)
      directory_entries(path).select { |entry| File.directory?(File.join(path, entry)) }
    end

    def basename(path)
      path.split(File::SEPARATOR)[-1]
    end

    def result_hash(response_code, addl=nil)
      { response_code => error_code_msg(response_code, addl) }
    end

    def error_code_msg(response_code, addl=nil)
      format(self.class.error_code_to_messages[response_code], addl: addl)
    end

    def check_required_manifest_files(dir, version)
      errors = []
      unless contains_file?(File.join(dir, MANIFESTS_DIR))
        errors << result_hash(NO_FILES_IN_MANIFEST_DIR, version)
        return errors
      end

      unless File.exist?(File.join(dir, MANIFEST_INVENTORY_PATH))
        errors << result_hash(NO_MANIFEST_INVENTORY, version)
      end
      unless File.exist?(File.join(dir, SIGNATURE_CATALOG_PATH))
        errors << result_hash(NO_SIGNATURE_CATALOG, version)
      end
      errors
    end

    def latest_manifest_inventory
      File.join(storage_obj_path, version_directories.last, MANIFEST_INVENTORY_PATH)
    end

    def object_id_from_manifest_inventory
      Nokogiri::XML(File.open(latest_manifest_inventory)).at_xpath('//fileInventory/@objectId').value
    end
  end
end
