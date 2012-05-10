require 'moab'

module Moab

  # @return [Confstruct::Configuration] the configuration data
  Config = Confstruct::Configuration.new do
      repository_home  "/services-disk/sdr2objects"
      path_method :druid_tree
  end

end
