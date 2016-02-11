# Serializer is a module containing classes whose methods faciliate serialization
# of data fields to various formats.  To obtain those benefits, a dependent class
# should inherit from {Serializable} or {Manifest}
# depending on whether XML serialization is required.
#
# ====Data Model
# * <b>{Serializable} = utility methods to faciliate serialization to Hash, JSON, or YAML</b>
#   * {Manifest} = adds methods for marshalling/unmarshalling data to a persistent XML file format
#
# @see https://github.com/dam5s/happymapper
# @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
#   All rights reserved.  See {file:LICENSE.rdoc} for details.
module Serializer
end

require 'nokogiri'
require 'happymapper'
require 'json'
require 'psych'
#require 'json/pure'
require 'pathname'
require 'fileutils'
require 'time'
require 'digest/md5'
require 'digest/sha1'

require 'serializer/serializable'
require 'serializer/manifest'

