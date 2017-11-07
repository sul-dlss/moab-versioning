require 'moab'

module Moab
  # Given a druid path, are the contents actually a well-formed Moab?
  # Shameless green: repetitious code included.
  class StorageObjectValidator

    EXPECTED_DATA_SUB_DIRS = ["content", "metadata"].freeze
    IMPLICIT_DIRS = ['.', '..'].freeze # unlike Find.find, Dir.entries returns these
    DATA_DIR_NAME = "data".freeze
    EXPECTED_VERSION_SUB_DIRS = [DATA_DIR_NAME, "manifests"].freeze
    MANIFEST_INVENTORY_PATH = 'manifests/manifestInventory.xml'.freeze
    SIGNATURE_CATALOG_PATH = 'manifests/signatureCatalog.xml'.freeze

    # error codes
    INCORRECT_DIR = 0
    MISSING_DIR = 1
    EXTRA_CHILD_DETECTED = 2
    VERSION_DIR_BAD_FORMAT = 3
    NO_SIGNATURE_CATALOG = 4
    NO_MANIFEST_INVENTORY = 5
    NO_XML_FILES = 6
    VERSIONS_NOT_IN_ORDER = 7
    FILES_IN_VERSION_DIR = 8

    attr_reader :storage_obj_path

    def initialize(storage_object)
      @storage_obj_path = storage_object.object_pathname
      @directory_entries_hash = {}
    end

    def validation_errors
      errors = []
      errors.concat check_correctly_named_version_dirs
      errors.concat check_sequential_version_dirs if errors.empty?
      errors.concat check_correctly_formed_moabs if errors.empty?
      errors
    end

    def self.error_code_to_messages
      @error_code_to_messages ||=
        {
          INCORRECT_DIR => "Incorrect items in path",
          MISSING_DIR => "Missing directory: %{addl}",
          EXTRA_CHILD_DETECTED => "Unexpected item in path: %{addl}",
          VERSION_DIR_BAD_FORMAT => "Version directory name not in 'v00xx' format",
          FILES_IN_VERSION_DIR => "Top level should contain only sequential version directories. Also contains files: %{addl}",
          NO_SIGNATURE_CATALOG => "Version: %{addl} Missing signatureCatalog.xml",
          NO_MANIFEST_INVENTORY => "Version: %{addl} Missing manifestInventory.xml",
          NO_XML_FILES => "Version: %{addl} Missing all required metadata files",
          VERSIONS_NOT_IN_ORDER => "Should contain only sequential version directories. Current directories: %{addl}"
        }.freeze
    end

    # TODO: Figure out which methods should be public

    private

    def version_directories
      @vdirs ||= sub_dirs(storage_obj_path)
    end

    def check_correctly_named_version_dirs
      errors = []
      version_directories.each do |version_dir|
        errors << result_hash(VERSION_DIR_BAD_FORMAT) unless version_dir =~ /^[v]\d{4}$/
      end
      errors
    end

    # This method will be called only if the version directories are correctly named
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

    def check_correctly_formed_moabs
      errors = []
      version_directories.each do |version_dir|
        version_path = "#{storage_obj_path}/#{version_dir}"
        version_sub_dirs = sub_dirs(version_path)
        before_result_size = errors.size
        errors.concat check_sub_dirs(version_sub_dirs, version_dir, EXPECTED_VERSION_SUB_DIRS)
        after_result_size = errors.size
        # run the following checks if this version dir passes check_sub_dirs, even if some prior version dirs didn't
        if before_result_size == after_result_size
          data_dir_path = "#{version_path}/#{DATA_DIR_NAME}"
          data_sub_dirs = sub_dirs(data_dir_path)
          errors.concat check_sub_dirs(data_sub_dirs, version_dir, EXPECTED_DATA_SUB_DIRS)
          errors.concat check_required_manifest_files(version_path, version_dir)
        end
      end

      errors
    end

    def check_sub_dirs(sub_dirs, version, required_sub_dirs)
      errors = []
      sub_dir_count = sub_dirs.size
      if sub_dir_count == required_sub_dirs.size
        errors.concat expected_dirs(sub_dirs, version, required_sub_dirs)
      elsif sub_dir_count > required_sub_dirs.size
        errors.concat found_unexpected(sub_dirs, version, required_sub_dirs)
      elsif sub_dir_count < required_sub_dirs.size
        errors.concat missing_dir(sub_dirs, version, required_sub_dirs)
      end
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

    def sub_dirs(path)
      directory_entries(path)
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

    def expected_dirs(array, _version, required_sub_dirs)
      errors = []
      errors << result_hash(INCORRECT_DIR) unless array == required_sub_dirs
      errors
    end

    def result_hash(response_code, addl=nil)
      { response_code => error_code_msg(response_code, addl) }
    end

    def error_code_msg(response_code, addl=nil)
      format(self.class.error_code_to_messages[response_code], addl: addl)
    end

    def check_required_manifest_files(dir, version)
      errors = []
      has_manifest_inventory = File.exist?("#{dir}/#{MANIFEST_INVENTORY_PATH}")
      has_signature_catalog = File.exist?("#{dir}/#{SIGNATURE_CATALOG_PATH}")
      result = if has_manifest_inventory && has_signature_catalog
                 nil
               elsif has_manifest_inventory && !has_signature_catalog
                 result_hash(NO_SIGNATURE_CATALOG, version)
               elsif !has_manifest_inventory && has_signature_catalog
                 result_hash(NO_MANIFEST_INVENTORY, version)
               else
                 result_hash(NO_XML_FILES, version)
               end
      errors << result if result
      errors
    end

    def latest_manifest_inventory
      "#{storage_obj_path}/#{version_directories.last}/#{MANIFEST_INVENTORY_PATH}"
    end

    def object_id_from_manifest_inventory
      Nokogiri::XML(File.open(latest_manifest_inventory)).at_xpath('//fileInventory/@objectId').value
    end
  end
end
