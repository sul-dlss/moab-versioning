Moab::Config.configure do
  storage_roots [File.join(File.dirname(__FILE__),"fixtures/derivatives"),File.join(File.dirname(__FILE__),"fixtures/newnode")]
  storage_trunk 'ingests'
  deposit_trunk 'packages'
  path_method :druid
end