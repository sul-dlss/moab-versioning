require 'spec_helper'

feature "Accessioning of a new digital object version" do
  #  In order to: incorporate a new version into the DOR workflow
  #  The application needs to: obtain version identity information

  background(:all) do

  end

  scenario "Accession the first version or a new full version" do
    # given: a objectId (druid)
    #      : an indication whether this is a new object or a new version
    #      : the version label and full description
    #      : information about the previous version, if any
    #      : a folder containing a set of files
    # action: verify whether object or version already exists
    #       : validate the version number and other identity information
    #       : harvest the file properties for all files being submitted
    # outcome: submission of the accessioning package
    #        : transfer of the package to DOR workspace
    #        : initiate DOR workflow

    pending("need to implement '#description' functionality")
  end

  scenario "Accession a new version with subset of files" do
    # given: a objectId (druid)
    #      : an indication whether this is a new object or a new version
    #      : the version label and full description
    #      : a folder containing a set of files
    # action: verify whether object or version already exists
    #       : validate the version number and other identity information
    #       : harvest the file properties for all files being submitted
    #       : retrieve information about the previous version
    #       : verify the completeness of the file set with respect to version differences
    # outcome: submission of the accessioning package
    #        : transfer of the package to DOR workspace
    #        : initiate DOR workflow

    pending("need to implement '#description' functionality")
  end
end