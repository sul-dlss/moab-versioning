require 'spec_helper'

feature "Import digital object version to SDR" do
  #  In order to: ingest a new version of a digital object into SDR
  #  The application needs to: process a Bagit bag containing a subset of object files

  background(:all) do

  end

  scenario "Verify bag manifest completeness" do
    # given: a Bagit bag manifest for each checksum type
    #      : the new version's versionMetadata datastream
    #      : the previous version's versionManifest (unless first version)
    # action: compare new versionMetadata against previous versionMetadata
    #       : compare bag manifest against version differences report
    # outcome: confirmation that the bag manifest is complete
    #        : detailed report of any discrepancies

    pending("need to implement '#{description}'")
  end

  scenario "Verify versionMetadata completeness" do
    # given: the Bagit bag manifest for each checksum type
    #      : the new version manifest
    #      : the existing index of storage location by file signature
    # action: compare the versionMetadata's manifest
    #       : against the bag manifest and the storage location index
    # outcome: confirmation that the versionMetadata manifest is complete
    #        : detailed report of any discrepancies

    pending("need to implement '#{description}'")
  end

  scenario "Verify data file fixity" do
    # given: the Bagit bag containing a subset of object files
    #      : the bag manifest
    # action: verify bag manifest against the files in the bag's data folder
    # outcome: true/false verification that the bag data files are not corrupted
    #        : detailed report of any discrepancies

    pending("need to implement '#{description}'")
  end


  scenario "Create a new version storage folder" do
    # given: the Bagit bag containing a subset of object files
    #      : the complete versionMetadata datastream
    # action: extract the version identity information from the versionMetadata
    #       : create the new version's storage folder
    #       : and any version-level metadata files, such as logs
    # outcome: version storage folder

    pending("need to implement '#description' functionality")
  end

  scenario "Copy unique data files to storage folder of new version" do
    # given: the Bagit bag containing a subset of object files
    #      : the bag manifest
    #      : the existing index of storage location by file signature
    # action: move files from the bag to the version storage location
    #       : update the storage location index
    # outcome: version's data folder containing version's files

    pending("need to implement '#{description}'")
  end

  scenario "Create or update the storage location index" do
    # given: version's data folder containing version's files
    #      : the bag manifest
    #      : the existing index of storage location by file signature
    # action: update the storage location index
    #       : verify the storage location index against all versions
    # outcome: revised storage location index

    pending("need to implement '#{description}'")
  end

end