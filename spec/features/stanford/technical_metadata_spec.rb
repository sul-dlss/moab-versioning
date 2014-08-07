require 'spec_helper'

feature "Process technicalMetadata datastream" do
  #  In order to: update the technicalMetadata datastream
  #  The application needs to: capture JHOVE output for a subset of an object's files

  background(:all) do

  end

  scenario "Generate Jhove output new or modified files" do |example|
    # given: a report listing new and modified content files
    # action: Generate Jhove output for only the new or modified files
    # outcome: a report containing Jhove output for selected files

    skip("need to implement '#{example.description}'")
  end

  scenario "Merge new Jhove output into technicalMetadata" do |example|
    # given: a report listing all content file changes
    #      : a report containing Jhove output for selected files
    # action: delete technicalMetadata entries for changed files
    #       : add technicalMetadata entries for new or updated files
    # outcome: a new technicalMetadata datastream for the new version

    skip("need to implement '#{example.description}'")
  end

  scenario "Merge new technicalMetadata into contentMetadata" do |example|
    # given: a report listing all content file changes
    #      : a technicalMetadata datastream for the new version
    # action: delete contentMetadata entries for changed files
    #       : add contentMetadata entries for new or updated files
    # outcome: a new contentMetadata datastream for the new version

    skip("need to implement '#{example.description}'")
  end

end