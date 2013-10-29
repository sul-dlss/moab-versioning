require 'moab'

module Moab

  # @return [Confstruct::Configuration] the configuration data
  Config = Confstruct::Configuration.new do
      storage_roots nil
      storage_trunk nil
      deposit_trunk nil
      path_method :druid_tree
  end

end
