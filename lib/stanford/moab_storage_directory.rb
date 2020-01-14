# frozen_string_literal: true

require 'find'

module Stanford
  ##
  # methods for dealing with a directory which stores Moab objects
  class MoabStorageDirectory
    DRUID_TREE_REGEXP = '[[:lower:]]{2}/\\d{3}/[[:lower:]]{2}/\\d{4}'
    DRUID_REGEXP = '[[:lower:]]{2}\\d{3}[[:lower:]]{2}\\d{4}'

    def self.find_moab_paths(storage_dir)
      Find.find(storage_dir) do |path|
        Find.prune unless File.directory?(path) # don't bother with a matching on files, we only care about directories
        path_match_data = storage_dir_regexp(storage_dir).match(path)
        if path_match_data
          yield path_match_data[1], path, path_match_data # yield the druid, the full path, and the MatchData object
          Find.prune # we don't care about what's in the moab dir, we just want the paths that look like moabs
        end
      end
    end

    def self.list_moab_druids(storage_dir)
      druids = []
      find_moab_paths(storage_dir) { |druid, _path, _path_match_data| druids << druid }
      druids
    end

    private_class_method def self.storage_dir_regexps
      @storage_dir_regexps ||= {}
    end

    # this regexp caching makes things many times faster (e.g. went from ~2200 s to crawl disk11, down to ~300 s)
    private_class_method def self.storage_dir_regexp(storage_dir)
      storage_dir_regexps[storage_dir] ||= Regexp.new("^#{storage_dir}/#{DRUID_TREE_REGEXP}/(#{DRUID_REGEXP})$")
    end
  end
end
