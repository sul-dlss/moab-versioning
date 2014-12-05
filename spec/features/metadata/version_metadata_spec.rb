require 'spec_helper'
require 'pp'

describe "Build a version metadata datastream" do
  #  In order to:
  #  The application needs to:

  before(:all) do
    @fixtures = File.join(File.dirname(__FILE__), '..', '..','fixtures')
  end


  scenario "test" do
    skip ("needs a rewrite to eliminate events")
    # given:
    # action:
    # outcome:
    vm = VersionMetadata.new(:digital_object_id => 'druid:ab123cd4567')

    vme = VersionMetadataEntry.new
    vme.version_id=1
    vme.significance = 'major'
    vme.description = 'Preserve my data please'
    vme.note = 'Initial object submission'
    vme.content_changes = FileGroupDifference.new(
        :group_id => 'content',
        :identical => 20,
        :renamed => 2,
        :modified => 0,
        :added => 1,
        :deleted => 0
    )
    vme.metadata_changes = FileGroupDifference.new(
        :group_id => 'metadata',
        :identical => 4,
        :renamed => 0,
        :modified => 3,
        :added => 0,
        :deleted => 0
    )
    vme.events << VersionMetadataEvent.new(
        :type => "reopen",
        :datetime => Time.now
    )
    vme.events << VersionMetadataEvent.new(
        :type => "submit",
        :datetime => Time.now
    )
    vme.events << VersionMetadataEvent.new(
        :type => "accession",
        :datetime => Time.now
    )

    vm.versions << vme
    fixtures = Pathname.new(File.dirname(__FILE__)).join('..','..','fixtures')
    parent_pathname=fixtures.join('derivatives','metadata')
    parent_pathname.mkpath
    vm.write_xml_file(parent_pathname)

  end


end


