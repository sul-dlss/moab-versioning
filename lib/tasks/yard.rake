desc "Generate RDoc"
task :doc => ['doc:generate']

namespace :doc do
  project_root = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
  doc_destination = File.join(project_root, 'doc')

  begin
    require 'yard'
    require 'yard/rake/yardoc_task'

    YARD::Rake::YardocTask.new(:generate) do |yt|
      yt.files   =  Dir.glob(File.join(project_root, 'lib', '*.rb')) + 
                    Dir.glob(File.join(project_root, 'lib', 'serializer', '*.rb')) +
                    Dir.glob(File.join(project_root, 'lib', 'moab', '*.rb')) +
                    Dir.glob(File.join(project_root, 'lib', 'stanford', '*.rb')) +
                    ['-'] +
                   [ File.join(project_root, 'LICENSE.rdoc') ]
                   
      yt.options = ['--output-dir', doc_destination, '--hide-void-return']
    end
  rescue LoadError
    desc "Generate YARD Documentation"
    task :generate do
      abort "Please install the YARD gem to generate rdoc."
    end
  end

  desc "Remove generated documentation"
  task :clean do
    rm_r doc_destination if File.exists?(doc_destination)
  end

end