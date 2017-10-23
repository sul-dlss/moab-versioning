#There is repeating code in here - first pass for audit checks

require 'moab'

module Moab
  class StorageObjectValidator

    EXPECTED_VERSION_SUB_DIRS = ["data", "manifests"].freeze
    EXPECTED_DATA_SUB_DIRS = ["content", "metadata"].freeze
    CORRECT_DIR = 0
    MISSING_DIR = 1
    EXTRA_DIR_DETECTED = 2
    EMPTY = 3
    ALL_XML_FILES = 4
    NO_SIGNATURE_CATALOG = 5
    NO_MANIFEST_INVENTORY = 6
    NO_XML_FILES = 7
    VERSIONS_IN_ORDER = 8
    VERSIONS_NOT_IN_ORDER = 9

    RESPONSE_CODE_TO_MESSAGES = {
      CORRECT_DIR=> "Correct items in path",
      MISSING_DIR => "Missing directory: %{addl}",
      EXTRA_DIR_DETECTED => "Unexpected item in path: %{addl}",
      EMPTY => "No items in path",
      ALL_XML_FILES => "Version: %{addl} Has required metadata files",
      NO_SIGNATURE_CATALOG => "Version: %{addl} Missing signatureCatalog.xml",
      NO_MANIFEST_INVENTORY => "Version: %{addl} Missing manifestInventory.xml",
      NO_XML_FILES => "Version: %{addl} Missing all required metadata files",
      VERSIONS_IN_ORDER => "Version directories are in order",
      VERSIONS_NOT_IN_ORDER => "Version directories are not in order. Here are the current versions: %{addl}"
    }.freeze

    attr_reader :path

    def initialize(storage_object)
      @path = storage_object.object_pathname
    end

    def validate_object
      results = []
      check_manifest_dir_xml(results)
      no_nested_moabs(results)
      sequential_version(results)
    end

    private

    def check_manifest_dir_xml(results)
      version_directories = sub_dirs(@path).sort # sort for travis
      version_directories.each do |version|
        version_path = "#{@path}/#{version}"
        check_manifest_files(version_path, results, version)
      end
      results.flatten
    end
    
    def sequential_version(results)
      ver_dir= sub_dirs(@path).sort # sort for travis
      ver_dir_num = ver_dir.collect { |ver| ver[-2..-1].to_i }
      sequential_order(ver_dir_num, results)
      results.flatten
    end

    def no_nested_moabs(results)
      version_directories = sub_dirs(@path).sort # sort for travis
      version_directories.each do |version|
        version_path = "#{@path}/#{version}"
        version_sub_dirs = sub_dirs(version_path).sort
        check_version_sub_dirs(version_sub_dirs, results, version)
        data_dir_path = "#{version_path}/#{version_sub_dirs[0]}"
        data_sub_dirs = sub_dirs(data_dir_path).sort
        check_data_sub_dirs(data_sub_dirs, results, version, dir=true)
      end
      results.flatten
    end
    
    def check_version_sub_dirs(sub_dirs,results, version, dir=nil)
      sub_dir_count = sub_dirs.count
      if sub_dir_count == 2
        expected_dirs(sub_dirs, results, version, dir)
      elsif sub_dir_count > 2
        found_unexpected(sub_dirs, results, version,dir)
      elsif sub_dir_count < 2
        missing_data(sub_dirs, results, version, dir)
      elsif sub_dir_count.zero?
        results << result_hash(EMPTY)
      end
      results.flatten
    end

    def check_data_sub_dirs(sub_dirs,results, version, dir=nil)
      sub_dir_count = sub_dirs.count
      if sub_dir_count == 2
        expected_dirs(sub_dirs, results, version, dir)
      elsif sub_dir_count > 2
        found_unexpected(sub_dirs, results, version, dir)
      elsif sub_dir_count < 2
        missing_data(sub_dirs, results, version, dir)
      elsif sub_dir_count.zero?
        results << result_hash(EMPTY)
      end
      results.flatten
    end

    def sub_dirs(path)
      Dir.entries(path).select { |entry| File.join(path, entry) unless /^\..*/ =~ entry }
    end

    def found_unexpected(array, results, version, dir=nil)
      required_sub_dirs = dir ? EXPECTED_DATA_SUB_DIRS : EXPECTED_VERSION_SUB_DIRS
      unexpected = (array - required_sub_dirs).pop
      unexpected = "#{unexpected} Version #{version}"
      results << result_hash(EXTRA_DIR_DETECTED, unexpected)
    end

    def missing_data(array, results, version, dir=nil)
      required_sub_dirs = dir ? EXPECTED_DATA_SUB_DIRS : EXPECTED_VERSION_SUB_DIRS
      missing = (required_sub_dirs - array).pop
      missing ="#{missing} Version #{version}"
      results << result_hash(MISSING_DIR, missing)
    end

    def expected_dirs(array, results, version, dir=nil)
      required_sub_dirs = dir ? EXPECTED_DATA_SUB_DIRS : EXPECTED_VERSION_SUB_DIRS
      results << result_hash(CORRECT_DIR) if array == required_sub_dirs
    end

    def result_hash(response_code, addl=nil)
      { response_code => result_code_msg(response_code, addl) }
    end

    def result_code_msg(response_code, addl=nil)
      format(RESPONSE_CODE_TO_MESSAGES[response_code], addl: addl)
    end

    def check_manifest_files(dir, results, version)
       manifest_inventory = File.exist?("#{dir}/manifests/manifestInventory.xml")
       signature_catalog = File.exist?("#{dir}/manifests/signatureCatalog.xml")
       results << if manifest_inventory && signature_catalog
                    result_hash(ALL_XML_FILES, version)
                  elsif manifest_inventory && !signature_catalog
                    result_hash(NO_SIGNATURE_CATALOG, version)
                  elsif !manifest_inventory && signature_catalog
                    result_hash(NO_MANIFEST_INVENTORY, version)
                  else
                    result_hash(NO_XML_FILES, version)
                  end
    end

    def sequential_order(array, results)
      sorted = array.sort
      lastNum = sorted[0]
      sorted[1, sorted.count].each do |n|
        if lastNum + 1 != n
          return results << result_hash(VERSIONS_NOT_IN_ORDER, sorted)
        end
        lastNum = n
      end
      results << result_hash(VERSIONS_IN_ORDER)
    end


  end
end