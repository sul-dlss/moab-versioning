#There is repeating code in here - first pass for audit check - storageobjectvalidator

require 'moab'

module Moab
  class StorageObjectValidator

    EXPECTED_VERSION_SUB_DIRS = ["data", "manifests"].freeze
    EXPECTED_DATA_SUB_DIRS = ["content", "metadata"].freeze
    INCORRECT_DIR = 0
    MISSING_DIR = 1
    EXTRA_DIR_DETECTED = 2
    EMPTY = 3
    NO_SIGNATURE_CATALOG = 5
    NO_MANIFEST_INVENTORY = 6
    NO_XML_FILES = 7
    VERSIONS_NOT_IN_ORDER = 9
    EXTRA_FILE_IN_VERSION_DIR = 10

    RESPONSE_CODE_TO_MESSAGES = {
      INCORRECT_DIR=> "Incorrect items in path",
      MISSING_DIR => "Missing directory: %{addl}",
      EXTRA_DIR_DETECTED => "Unexpected item in path: %{addl}",
      EMPTY => "No items in path",
      EXTRA_FILE_IN_VERSION_DIR => "extra file in versino dir",
      NO_SIGNATURE_CATALOG => "Version: %{addl} Missing signatureCatalog.xml",
      NO_MANIFEST_INVENTORY => "Version: %{addl} Missing manifestInventory.xml",
      NO_XML_FILES => "Version: %{addl} Missing all required metadata files",
      VERSIONS_NOT_IN_ORDER => "Version directories are not in order. Here are the current versions: %{addl}"
    }.freeze

    attr_reader :path

    def initialize(storage_object)
      @path = storage_object.object_pathname
    end

    def validate_object
      results = []
      if sequential_version.empty?
        p "yay in order"
        version_directories = sub_dirs(path).sort 
        version_directories.each do |version|
          # return false if Dir["#{path}/#{version}"].empty?
          version_path = "#{@path}/#{version}"
          version_sub_dirs = sub_dirs(version_path).sort
          p check_version_sub_dirs(version_sub_dirs, version)
        end
      else 
        p results
      end
    end


    # def validate_object
    #   results = []
    #   # results.concat check_manifest_dir_xml
    #   results.concat sequential_version
    #   # results.concat no_nested_moabs
    # end




    # private


    def check_manifest_dir_xml
      results = []
      version_directories = sub_dirs(@path).sort # sort for travis
      version_directories.each do |version|
        version_path = "#{@path}/#{version}"
        results.concat check_manifest_files(version_path, version)
      end
      results
    end
    
    def sequential_version
      results = []

      ver_dir = sub_dirs(path).sort # sort for travis
      ver_dir_num = ver_dir.collect { |ver| ver[-2..-1].to_i }
      results.concat sequential_order(ver_dir_num)

      if Dir.entries(path).detect { |entry| FileTest.file?(entry) }
        results << result_hash(EXTRA_FILE_IN_VERSION_DIR)
      end

      results
    end

    def no_nested_moabs
      results = []
      version_directories = sub_dirs(@path).sort # sort for travis
      version_directories.each do |version|
        version_path = "#{@path}/#{version}"
        version_sub_dirs = sub_dirs(version_path).sort
        results.concat check_version_sub_dirs(version_sub_dirs, version)
        data_dir_path = "#{version_path}/#{version_sub_dirs[0]}"
        data_sub_dirs = sub_dirs(data_dir_path).sort
        results.concat check_data_sub_dirs(data_sub_dirs, version, dir=true)
      end
      results
    end
    
    def check_version_sub_dirs(sub_dirs, version, dir=nil)
      results = []
      sub_dir_count = sub_dirs.size
      if sub_dir_count == 2
        results.concat expected_dirs(sub_dirs, version, dir)
      elsif sub_dir_count > 2
        results.concat found_unexpected(sub_dirs, version,dir)
      elsif sub_dir_count < 2
        results.concat missing_data(sub_dirs, version, dir)
      elsif sub_dir_count.zero?
        results << result_hash(EMPTY)
      end
      results
    end

    def check_data_sub_dirs(sub_dirs, version, dir=nil)
      results = []
      sub_dir_count = sub_dirs.size
      if sub_dir_count == 2
        results.concat expected_dirs(sub_dirs, version, dir)
      elsif sub_dir_count > 2
        results.concat found_unexpected(sub_dirs, version, dir)
      elsif sub_dir_count < 2
        results.concat missing_data(sub_dirs, version, dir)
      elsif sub_dir_count.zero?
        results << result_hash(EMPTY)
      end
      results
    end

    def sub_dirs(path)
      Dir.entries(path).select { |entry| File.join(path, entry) unless /^\..*/ =~ entry }
    end

    def found_unexpected(array, version, dir=nil) #maybe just add required_sub_dirs = EXPECTED_DATA_SUB_DIRS as a parameter
      results = []
      required_sub_dirs = dir ? EXPECTED_DATA_SUB_DIRS : EXPECTED_VERSION_SUB_DIRS
      unexpected = (array - required_sub_dirs).pop
      unexpected = "#{unexpected} Version #{version}"
      results << result_hash(EXTRA_DIR_DETECTED, unexpected)
      results
    end

    def missing_data(array, version, dir=nil)
      results = []
      required_sub_dirs = dir ? EXPECTED_DATA_SUB_DIRS : EXPECTED_VERSION_SUB_DIRS
      missing = (required_sub_dirs - array).pop
      missing ="#{missing} Version #{version}"
      results << result_hash(MISSING_DIR, missing)
      results
    end

    def expected_dirs(array, version, dir=nil)
      results = []
      required_sub_dirs = dir ? EXPECTED_DATA_SUB_DIRS : EXPECTED_VERSION_SUB_DIRS
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

    def sequential_order(array)
      results = []
      sorted = array.sort
      lastNum = sorted[0]
      sorted[1, sorted.count].each do |n|
        if lastNum + 1 != n
          results << result_hash(VERSIONS_NOT_IN_ORDER, sorted) 
          break
        end
        lastNum = n
      end
      results
    end

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