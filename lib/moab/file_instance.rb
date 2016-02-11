require 'moab'

module Moab

  # The file path and last modification date properties of a file
  #
  # ====Data Model
  # * {FileInventory} = container for recording information about a collection of related files
  #   * {FileGroup} [1..*] = subset allow segregation of content and metadata files
  #     * {FileManifestation} [1..*] = snapshot of a file's filesystem characteristics
  #       * {FileSignature} [1] = file fixity information
  #       * <b>{FileInstance} [1..*] = filepath and timestamp of any physical file having that signature</b>
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class FileInstance < Serializer::Serializable

    include HappyMapper

    # The name of the XML element used to serialize this objects data
    tag 'fileInstance'

    # (see Serializable#initialize)
    def initialize(opts={})
      super(opts)
    end

    # @attribute
    # @return [String] The id is the filename path, relative to the file group's base directory
    attribute :path, String, :key => true

    # @attribute
    # @return [String] gsub(/\n/,' ')
    attribute :datetime, String

    def datetime=(event_datetime)
      @datetime=Moab::UtcTime.input(event_datetime)
    end

    def datetime
      Moab::UtcTime.output(@datetime)
    end


    # @api internal
    # @param pathname [Pathname] The location of the physical file
    # @param base_directory [Pathname] The full path used as the basis of the relative paths reported
    # @return [FileInstance] Returns a file instance containing a physical file's' properties
    def instance_from_file(pathname, base_directory)
      @path = pathname.expand_path.relative_path_from(base_directory.expand_path).to_s
      @datetime = pathname.mtime.iso8601
      self
    end

    # @api internal
    # @param other [FileInstance] The other file instance being compared to this instance
    # @return [Boolean] Returns true if self and other have the same path.
    def eql?(other)
      return false unless other.respond_to?(:path)  # Cannot equal an incomparable type!
      self.path == other.path
    end

    # @api internal
    # (see #eql?)
    def ==(other)
      eql?(other)
    end

    # @api internal
    # @return [Fixnum] Compute a hash-code for the path string.
    # Two file instances with the same relative path will have the same hash code (and will compare using eql?).
    # @note The hash and eql? methods override the methods inherited from Object.
    #   These methods ensure that instances of this class can be used as Hash keys.  See
    #   * {http://www.paulbutcher.com/2007/10/navigating-the-equality-maze/}
    #   * {http://techbot.me/2011/05/ruby-basics-equality-operators-ruby/}
    #   Also overriden is {#==} so that equality tests in other contexts will also return the expected result.
    def hash
      path.hash
    end

  end

end
