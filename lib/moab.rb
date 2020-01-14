# frozen_string_literal: true

# Moab is a module that provides a distintive namespace for the collection of classes it contains.
#
# ====Data Model
#
# * <b>{FileInventory} = container for recording information about a collection of related files</b>
#   * {FileGroup} [1..*] = subset allow segregation of content and metadata files
#     * {FileManifestation} [1..*] = snapshot of a file's filesystem characteristics
#       * {FileSignature} [1] = file fixity information
#       * {FileInstance} [1..*] = filepath and timestamp of any physical file having that signature
#
# * <b>{SignatureCatalog} = lookup table containing a cumulative collection of all files ever ingested</b>
#   * {SignatureCatalogEntry} [1..*] = an row in the lookup table containing storage information about a single file
#     * {FileSignature} [1] = file fixity information
#
# * <b>{FileInventoryDifference} = compares two {FileInventory} instances based on file signatures and pathnames</b>
#   * {FileGroupDifference} [1..*] = performs analysis and reports differences between two matching {FileGroup} objects
#     * {FileGroupDifferenceSubset} [1..5] = collects a set of file-level differences of a give change type
#       * {FileInstanceDifference} [1..*] = contains difference information at the file level
#         * {FileSignature} [1..2] = contains the file signature(s) of two file instances being compared
#
# * <b>{VersionMetadata} = descriptive information about a digital object's versions</b>
#   * {VersionMetadataEntry} [1..*] = attributes of a digital object version
#     * {VersionMetadataEvent} [1..*] = object version lifecycle events with timestamps
#
# * <b>{StorageObject} = represents a digital object's repository storage location and ingest/dissemination methods</b>
#   * {StorageObjectVersion} [1..*] = represents a version subdirectory within an object's home directory
#     * {Bagger} [1] = utility for creating bagit packages for ingest or dissemination
#
# @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
#   All rights reserved.  See {file:LICENSE.rdoc} for details.
module Moab
  DEFAULT_CHECKSUM_TYPES = %i[md5 sha1 sha256].freeze
end

require 'serializer'
require 'confstruct/configuration'
require 'moab/config'
require 'moab/utc_time'
require 'moab/file_signature'
require 'moab/file_instance'
require 'moab/file_manifestation'
require 'moab/file_group'
require 'moab/file_inventory'
require 'moab/signature_catalog_entry'
require 'moab/signature_catalog'
require 'moab/file_instance_difference'
require 'moab/file_group_difference_subset'
require 'moab/file_group_difference'
require 'moab/file_inventory_difference'
require 'moab/version_metadata_event'
require 'moab/version_metadata_entry'
require 'moab/version_metadata'
require 'moab/bagger'
require 'moab/storage_object'
require 'moab/storage_object_version'
require 'moab/storage_repository'
require 'moab/storage_services'
require 'moab/exceptions'
require 'moab/verification_result'
require 'moab/storage_object_validator'
require 'moab/deposit_bag_validator'
