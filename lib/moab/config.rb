# frozen_string_literal: true

module Moab
  # A place to store configuration for the gem
  class Configuration
    def initialize
      @path_method = :druid_tree
      @checksum_algos = [:md5, :sha1, :sha256]
    end

    def configure(...)
      instance_eval(...)
    end

    def storage_roots(new_value = nil)
      @storage_roots = new_value if new_value
      @storage_roots
    end

    def storage_trunk(new_value = nil)
      @storage_trunk = new_value if new_value
      @storage_trunk
    end

    def deposit_trunk(new_value = nil)
      @deposit_trunk = new_value if new_value
      @deposit_trunk
    end

    def path_method(new_value = nil)
      @path_method = new_value if new_value
      @path_method
    end

    def checksum_algos(new_value = nil)
      @checksum_algos = new_value if new_value
      @checksum_algos
    end
  end

  # @return [Moab::Configuration] the configuration data
  Config = Configuration.new
end
