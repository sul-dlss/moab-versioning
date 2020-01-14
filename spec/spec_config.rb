Moab::Config.configure do
  root_path1 = File.join(File.dirname(__FILE__), "fixtures/derivatives")
  root_path2 = File.join(File.dirname(__FILE__), "fixtures/derivatives2")
  root_path3 = File.join(File.dirname(__FILE__), "fixtures/newnode")
  storage_roots [root_path1, root_path2, root_path3]
  storage_trunk 'ingests'
  deposit_trunk 'packages'
  path_method :druid
end
