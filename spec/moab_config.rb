Moab::Config.configure do
  repository_home File.join(File.dirname(__FILE__),"fixtures/derivatives/ingests")
  path_method :druid
end