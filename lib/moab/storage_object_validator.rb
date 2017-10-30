# There is repeating code in here - first pass for audit check - storageobjectvalidator

require 'moab'

module Moab
  # Given a druid path, are the contents actually a well-formed Moab?
  class StorageObjectValidator

    EXPECTED_VERSION_SUB_DIRS = ["data", "manifests"].freeze
    EXPECTED_DATA_SUB_DIRS = ["content", "metadata"].freeze
    IMPLICIT_DIRS = ['.', '..'].freeze # unlike Find.find, Dir.entries returns these

    # error codes
    INCORRECT_DIR = 0
    MISSING_DIR = 1
    EXTRA_CHILD_DETECTED = 2
    EMPTY = 3
    NO_SIGNATURE_CATALOG = 4
    NO_MANIFEST_INVENTORY = 5
    NO_XML_FILES = 6
    VERSIONS_NOT_IN_ORDER = 7
    FILES_IN_VERSION_DIR = 8
    VERSION_DIR_BAD_FORMAT = 9

    RESPONSE_CODE_TO_MESSAGES = {
      INCORRECT_DIR=> "Incorrect items in path",
      MISSING_DIR => "Missing directory: %{addl}",
      EXTRA_CHILD_DETECTED => "Unexpected item in path: %{addl}",
      EMPTY => "No items in path",
      FILES_IN_VERSION_DIR => "Should contain only sequential version directories. Also contains files: %{addl}",
      NO_SIGNATURE_CATALOG => "Version: %{addl} Missing signatureCatalog.xml",
      NO_MANIFEST_INVENTORY => "Version: %{addl} Missing manifestInventory.xml",
      NO_XML_FILES => "Version: %{addl} Missing all required metadata files",
      VERSIONS_NOT_IN_ORDER => "Should contain only sequential version directories. Current directories: %{addl}",
      VERSION_DIR_BAD_FORMAT => "Version directory name not in 'v00xx' format"
    }.freeze

    attr_reader :storage_obj_path

    def initialize(storage_object)
      @storage_obj_path = storage_object.object_pathname
      @directory_entries_hash = {}
    end

    def validate_object
      results = []
      results.concat correctly_named_ver_dir
      results.concat check_for_only_sequential_version_dirs if results.empty?
      # if we only have sequential version directories uder the root object path, proceed
      # to check for expected version subdirs, and to check contents of the data dir

      results.concat correctly_formed_moab if results.empty?

      results
    end
    # TODO: Figure out which methods should be public

    private

    def check_for_only_sequential_version_dirs
      results = []

      sub_dirs(storage_obj_path).each_with_index do |dir_name, index|
        expected_vers_num = index + 1 # version numbering starts at 1, array indexing starts at 0
        begin
          if dir_name[1..-1].to_i != expected_vers_num
            results << result_hash(VERSIONS_NOT_IN_ORDER, sub_dirs(storage_obj_path))
            break
          end
        rescue ArgumentError
          results << result_hash(VERSIONS_NOT_IN_ORDER, sub_dirs(storage_obj_path))
        end
      end

      unless files_in_dir(storage_obj_path).empty?
        results << result_hash(FILES_IN_VERSION_DIR, files_in_dir(storage_obj_path))
      end

      results
    end

    def correctly_named_ver_dir
      results = []
      sub_dirs(storage_obj_path).each do |version_dir|
        if version_dir =~ /^[v]\d{4}/
          nil
        else
          results << result_hash(VERSION_DIR_BAD_FORMAT)
        end
      end
      results
    end

    def correctly_formed_moab
      results = []

      version_directories = sub_dirs(storage_obj_path)
      version_directories.each do |version_dir|
        version_path = "#{storage_obj_path}/#{version_dir}"
        version_sub_dirs = sub_dirs(version_path)
        # Need to add before_result_size and after_result_size because if everything is expected
        # and good, then no error message will be added to the result array, so if it stays the same
        # size then it is ready to be checked for the data_sub_dirs and manfist_xml
        before_result_size = results.size
        results.concat check_sub_dirs(version_sub_dirs, version_dir, EXPECTED_VERSION_SUB_DIRS)
        after_result_size = results.size
        # don't bother checking the data sub dir if we didn't find the expected two subdirs

        # Before it was result.size === 0, however for each version that is not correctly constructed,
        # error messages will be concat to the array. By the time the loop reaches a version that is
        # correctly constructe the size will stay the same as before (because it has the old error messages)
        # so we must make sure before and after result size are the same - aka no error message was added
        # and the version directory was correctly constructed

        if before_result_size == after_result_size
          data_dir_path = "#{version_path}/#{version_sub_dirs[0]}"
          data_sub_dirs = sub_dirs(data_dir_path)
          results.concat check_sub_dirs(data_sub_dirs, version_dir, EXPECTED_DATA_SUB_DIRS)
          results.concat check_manifest_files(version_path, version_dir)
        end
      end

      results
    end

    def check_sub_dirs(sub_dirs, version, required_sub_dirs)
      results = []
      sub_dir_count = sub_dirs.size
      if sub_dir_count == 2
        results.concat expected_dirs(sub_dirs, version, required_sub_dirs)
      elsif sub_dir_count > 2
        results.concat found_unexpected(sub_dirs, version, required_sub_dirs)
      elsif sub_dir_count < 2
        results.concat missing_data(sub_dirs, version, required_sub_dirs)
      elsif sub_dir_count.zero?
        results << result_hash(EMPTY)
      end
      results
    end

    def directory_entries(path)
      @directory_entries_hash[path] ||=
        begin
          ret_val = { files: [], dirs: [] }
          (Dir.entries(path).sort - IMPLICIT_DIRS).each do |child|
            if FileTest.file? child
              ret_val[:files] << child
            else
              ret_val[:dirs] << child
            end
          end
          ret_val
        end
    end

    def sub_dirs(path)
      directory_entries(path)[:dirs]
    end

    def files_in_dir(path)
      directory_entries(path)[:files]
    end

    def found_unexpected(array, version, required_sub_dirs)
      results = []
      unexpected = (array - required_sub_dirs) # removed .pop for now
      unexpected = "#{unexpected} Version: #{version}"
      results << result_hash(EXTRA_CHILD_DETECTED, unexpected)
      results
    end

    def missing_data(array, version, required_sub_dirs)
      results = []
      missing = (required_sub_dirs - array) # removed .pop for now
      missing ="#{missing} Version: #{version}"
      results << result_hash(MISSING_DIR, missing)
      results
    end

    def expected_dirs(array, _version, required_sub_dirs)
      results = []
      results << result_hash(INCORRECT_DIR) unless array == required_sub_dirs
      results
    end

    def result_hash(response_code, addl=nil)
      { response_code => result_code_msg(response_code, addl) }
    end

    def result_code_msg(response_code, addl=nil)
      format(RESPONSE_CODE_TO_MESSAGES[response_code], addl: addl)
    end

    def check_manifest_files(dir, version)
      results = []
      manifest_inventory = File.exist?("#{dir}/manifests/manifestInventory.xml")
      signature_catalog = File.exist?("#{dir}/manifests/signatureCatalog.xml")
      result = if manifest_inventory && signature_catalog
                 nil
               elsif manifest_inventory && !signature_catalog
                 result_hash(NO_SIGNATURE_CATALOG, version)
               elsif !manifest_inventory && signature_catalog
                 result_hash(NO_MANIFEST_INVENTORY, version)
               else
                 result_hash(NO_XML_FILES, version)
               end
      results << result if result
      results
    end
  end
end
