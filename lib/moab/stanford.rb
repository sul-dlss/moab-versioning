require 'moab'
require 'stanford/content_inventory'
require 'stanford/dor_metadata'
require 'stanford/storage_repository'
require 'stanford/storage_services'
require 'stanford/active_fedora_object'
require 'stanford/moab_storage_directory'

# Stanford is a module that isolates classes specific to the Stanford Digital Repository
#
# ====Data Model
# * <b>{DorMetadata} = utility methods for interfacing with Stanford metadata files (esp contentMetadata)</b>
#   * {ActiveFedoraObject} [1..*] = utility for extracting content or other information from a Fedora Instance
#
# @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
#   All rights reserved.  See {file:LICENSE.rdoc} for details.
module Stanford
end
