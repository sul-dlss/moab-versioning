require 'moab'

module Moab

  #class Configuration < Confstruct::Configuration
  #
  #  def configure(*args, &block)
  #    super(*args, &block)
  #
  #    # Whatever you want to do after configuration
  #    # Something.initialize(self.repository_home)
  #  end
  #end

  # @return [Confstruct::Configuration] the configuration data
  Config = Confstruct::Configuration.new do
      repository_home  nil
      path_method :druid_tree
  end

end
