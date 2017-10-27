#There is repeating code in here - first pass for audit check - storageobjectvalidator

require 'moab'

module Moab
  class StorageObjectValidator

    EXPECTED_VERSION_SUB_DIRS = ["data", "manifests"].freeze
    EXPECTED_DATA_SUB_DIRS = ["content", "metadata"].freeze
    IMPLICIT_DIRS = ['.', '..'].freeze # unlike Find.find, Dir.entries returns these

    # error codes
    INCORRECT_DIR = 0
    MISSING_DIR = 1
    EXTRA_DIR_DETECTED = 2
    EMPTY = 3
    NO_SIGNATURE_CATALOG = 5
    NO_MANIFEST_INVENTORY = 6
    NO_XML_FILES = 7
    VERSIONS_NOT_IN_ORDER = 9
    FILES_IN_VERSION_DIR = 10

    RESPONSE_CODE_TO_MESSAGES = {
      INCORRECT_DIR=> "Incorrect items in path",
      MISSING_DIR => "Missing directory: %{addl}",
      EXTRA_DIR_DETECTED => "Unexpected item in path: %{addl}",
      EMPTY => "No items in path",
      FILES_IN_VERSION_DIR => "Should contain only sequential version directories. Also contains files: %{addl}",
      NO_SIGNATURE_CATALOG => "Version: %{addl} Missing signatureCatalog.xml",
      NO_MANIFEST_INVENTORY => "Version: %{addl} Missing manifestInventory.xml",
      NO_XML_FILES => "Version: %{addl} Missing all required metadata files",
      VERSIONS_NOT_IN_ORDER => "Should contain only sequential version directories. Current directories: %{addl}"
    }.freeze

    attr_reader :storage_obj_path

    def initialize(storage_object)
      @storage_obj_path = storage_object.object_pathname
      @directory_entries_hash = {}
    end

    # def validate_object
    #   results = []
    #   if check_for_only_sequential_version_dirs.empty?
    #     p "yay in order"
    #     version_directories = sub_dirs(storage_obj_path).sort 
    #     version_directories.each do |version|
    #       # return false if Dir["#{storage_obj_path}/#{version}"].empty?
    #       version_path = "#{storage_obj_path}/#{version}"
    #       version_sub_dirs = sub_dirs(version_path).sort
    #       p check_sub_dirs(version_sub_dirs, version)
    #     end
    #   else 
    #     p results
    #   end
    # end


    # def validate_object
    #   results = []
    #   # results.concat check_manifest_dir_xml
    #   results.concat check_for_only_sequential_version_dirs
    #   # results.concat check_no_nested_moabs
    # end


    def validate_object
      results = []

      results.concat check_for_only_sequential_version_dirs

      # if we only have sequential version directories uder the root object path, proceed
      # to check for expected version subdirs, and to check contents of the data dir 
      if results.size == 0
        results.concat check_no_nested_moabs
      end

      results
    end


    # private


    def check_manifest_dir_xml
      results = []
      version_directories = sub_dirs(storage_obj_path).sort # sort for travis
      version_directories.each do |version|
        version_path = "#{storage_obj_path}/#{version}"
        results.concat check_manifest_files(version_path, version)
      end
      results
    end
    
    def check_for_only_sequential_version_dirs
      results = []

      # ver_dir = sub_dirs(storage_obj_path).sort # sort for travis
      # ver_dir_num = ver_dir.collect { |ver| ver[-2..-1].to_i }
      # results.concat sequential_order(ver_dir_num)

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

      if files_in_dir(storage_obj_path).size > 0
        results << result_hash(FILES_IN_VERSION_DIR, files_in_dir(storage_obj_path))
      end

      results
    end

    def check_no_nested_moabs
      results = []

      version_directories = sub_dirs(storage_obj_path)
      version_directories.each do |version_dir|
        version_path = "#{storage_obj_path}/#{version_dir}"
        version_sub_dirs = sub_dirs(version_path)
        results.concat check_sub_dirs(version_sub_dirs, version_dir, EXPECTED_VERSION_SUB_DIRS)

        data_dir_path = "#{version_path}/#{version_sub_dirs[0]}"
        data_sub_dirs = sub_dirs(data_dir_path)
        results.concat check_sub_dirs(data_sub_dirs, version_dir, EXPECTED_DATA_SUB_DIRS)
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
      unexpected = (array - required_sub_dirs).pop
      unexpected = "#{unexpected} Version #{version}"
      results << result_hash(EXTRA_DIR_DETECTED, unexpected)
      results
    end

    def missing_data(array, version, required_sub_dirs)
      results = []
      missing = (required_sub_dirs - array).pop
      missing ="#{missing} Version #{version}"
      results << result_hash(MISSING_DIR, missing)
      results
    end

    def expected_dirs(array, version, required_sub_dirs)
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

    # def sequential_order(array)
    #   results = []
    #   sorted = array.sort
    #   lastNum = sorted[0]
    #   sorted[1, sorted.count].each do |n|
    #     if lastNum + 1 != n
    #       results << result_hash(VERSIONS_NOT_IN_ORDER, sorted) 
    #       break
    #     end
    #     lastNum = n
    #   end
    #   results
    # end

    def only_expected_directories?(dir_path)
      # files = Dir.entries(dir_path).select { |f| File.file?(dir_path+f) unless /^\..*/ =~ f }
      # files.empty? ? true : false
    end

    def only_expected_files?(dir_path)
      directories = Dir.entries(dir_path).select { |f| File.directory?(dir_path+f) unless /^\..*/ =~ f }
      directories.empty? ? true : false
    end


  end
end