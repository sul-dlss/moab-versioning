module Moab
  # @return [Confstruct::Configuration] the configuration data
  Config = Confstruct::Configuration.new do
    storage_roots nil
    storage_trunk nil
    deposit_trunk nil
    path_method :druid_tree
    checksum_algos [:md5, :sha1, :sha256]
  end
end
