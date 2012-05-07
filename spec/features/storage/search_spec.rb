require 'spec_helper'

feature "Create reconstructed digital object for a version" do
  #  In order to: disseminate a copy of a digital object version
  #  The application needs to: reconstruct the version's file structure from the storage location

  background(:all) do

  end

  scenario "Search for version based on objectId and versionId" do
    # given: the objectId and versionId
    # action: determine the object and version location
    # outcome: the versionMetadata for the version

    pending("need to implement '#{description}'")
  end

  scenario "Search for version based on objectId and datetime" do
    # given: the objectId and version datetime
    # action: determine the object and version location
    # outcome: the versionMetadata for the version

    pending("need to implement '#{description}'")
  end

  scenario "Browse for version based on objectId" do
    # given: the objectId
    # action: determine the object location
    #       : retrieve copies of all versionMetadata files
    # outcome: a list of versions for the object

    pending("need to implement '#{description}'")
  end

  scenario "Generate a copy of a full version in a temp location" do
    # given: the version's data folder containing version's files
    #      : the versionMetadata manifest
    #      : the existing index of storage location by file signature
    # action: copy (link) files to the temp location,
    #       : using the storage location index to locate files
    #       : and the versionMetadata manifest to provide original filenames
    # outcome: a temp folder containing the version's files

    pending("need to implement '#description' functionality")
  end

  scenario "Generate a copy of a partial version in a temp location" do
    # given: the version's data folder containing version's files
    #      : the versionMetadata manifest
    #      : the existing index of storage location by file signature
    #      : the list of desired files to be retrieved
    # action: copy (link) selected files to the temp location,
    #       : using the storage location index to locate files
    #       : and the versionMetadata manifest to provide original filenames
    # outcome: a temp folder containing a subset of   the version's files

    pending("need to implement '#{description}'")
  end

end