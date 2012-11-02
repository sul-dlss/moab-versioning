require 'moab'

module Moab

  # The fixity properties of a file, used to determine file content equivalence regardless of filename.
  # Placing this data in a class by itself facilitates using file size together with the MD5 and SHA1 checksums
  # as a single key when doing comparisons against other file instances.  The Moab design assumes that this file signature
  # is sufficiently unique to act as a comparator for determining file equality and eliminating file redundancy.
  #
  # The use of signatures for a compare-by-hash mechanism introduces a miniscule (but non-zero) risk
  # that two non-identical files will have the same checksum.  While this risk is only about 1 in 1048
  # when using the SHA1 checksum alone, it can be reduced even further (to about 1 in 1086)
  # if we use the MD5 and SHA1 checksums together.  And we gain a bit more comfort by including a comparison of file sizes.
  #
  # Finally, the "collision" risk is reduced by isolation of each digital object's file pool within an object folder,
  # instead of in a common storage area shared by the whole repository.
  #
  # ====Data Model
  # * {FileInventory} = container for recording information about a collection of related files
  #   * {FileGroup} [1..*] = subset allow segregation of content and metadata files
  #     * {FileManifestation} [1..*] = snapshot of a file's filesystem characteristics
  #       * <b>{FileSignature} [1] = file fixity information</b>
  #       * {FileInstance} [1..*] = filepath and timestamp of any physical file having that signature
  #
  # * {SignatureCatalog} = lookup table containing a cumulative collection of all files ever ingested
  #   * {SignatureCatalogEntry} [1..*] = an row in the lookup table containing storage information about a single file
  #     * <b>{FileSignature} [1] = file fixity information</b>
  #
  # * {FileInventoryDifference} = compares two {FileInventory} instances based on file signatures and pathnames
  #   * {FileGroupDifference} [1..*] = performs analysis and reports differences between two matching {FileGroup} objects
  #     * {FileGroupDifferenceSubset} [1..5] = collects a set of file-level differences of a give change type
  #       * {FileInstanceDifference} [1..*] = contains difference information at the file level
  #         * <b>{FileSignature} [1..2] = contains the file signature(s) of two file instances being compared</b>
  #
  # @see http://searchstorage.techtarget.com/feature/The-skinny-on-data-deduplication
  # @see http://www.ibm.com/developerworks/wikis/download/attachments/106987789/TSMDataDeduplication.pdf
  # @see https://www.redlegg.com/pdf_file/3_1320410927_HowDataDedupeWorks_WP_100809.pdf
  # @see http://www.library.yale.edu/iac/DPC/AN_DPC_FixityChecksFinal11.pdf
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class FileSignature < Serializable

    include HappyMapper

    # The name of the XML element used to serialize this objects data
    tag 'fileSignature'

    # (see Serializable#initialize)
    def initialize(opts={})
      super(opts)
    end

    # @attribute
    # @return [Integer] The size of the file in bytes
    attribute :size, Integer, :on_save => Proc.new { |n| n.to_s }

    # @attribute
    # @return [String] The MD5 checksum value of the file
    attribute :md5, String, :on_save => Proc.new { |n| n.nil? ? "" : n.to_s }

    # @attribute
    # @return [String] The SHA1 checksum value of the file
    attribute :sha1, String, :on_save => Proc.new { |n| n.nil? ? "" : n.to_s }

    # @attribute
    # @return [String] The SHA256 checksum value of the file
    attribute :sha256, String, :on_save => Proc.new { |n| n.nil? ? "" : n.to_s }

    # @api internal
    # @return [Hash<Symbol,String>] An Hasg of fixity data to be compared for equality
    def fixity
      fixity_hash = { :md5 => @md5, :sha1 => @sha1, :sha256 => @sha256 }
      fixity_hash.delete_if { |key,value| value.nil? or value.empty?}
      fixity_hash
    end

    # @api internal
    # @param other [FileSignature] The other file signature being compared to this signature
    # @return [Boolean] Returns true if self and other have the same fixity data.
    def eql?(other)
      size_eql?(other) and fixity_eql?(other)
    end

    def size_eql?(other)
      self.size.to_i == other.size.to_i
    end

    def fixity_eql?(other)
      matching_keys = self.fixity.keys & other.fixity.keys
      return false if matching_keys.size == 0
      matching_keys.each do |key|
        return false if self.fixity[key] != other.fixity[key]
      end
      true
    end

    # @api internal
    # (see #eql?)
    def ==(other)
      eql?(other)
    end

    # @api internal
    # @return [Fixnum] Compute a hash-code for the fixity value array.
    #   Two file instances with the same content will have the same hash code (and will compare using eql?).
    # @note The hash and eql? methods override the methods inherited from Object.
    #   These methods ensure that instances of this class can be used as Hash keys.  See
    #   * {http://www.paulbutcher.com/2007/10/navigating-the-equality-maze/}
    #   * {http://techbot.me/2011/05/ruby-basics-equality-operators-ruby/}
    #   Also overriden is {#==} so that equality tests in other contexts will also return the expected result.
    def hash
      @size.to_i
    end

    # @api internal
    # @param pathname [Pathname] The location of the file to be digested
    # @return [FileSignature] Generate a FileSignature instance containing size and checksums for a physical file
    def signature_from_file(pathname)
      @size = pathname.size
      md5_digest = Digest::MD5.new
      sha1_digest = Digest::SHA1.new
      sha256_digest = Digest::SHA2.new(256)
      pathname.open("r") do |stream|
        while buffer = stream.read(8192)
          md5_digest.update(buffer)
          sha1_digest.update(buffer)
          sha256_digest.update(buffer)
        end
      end
      @md5 = md5_digest.hexdigest
      @sha1 = sha1_digest.hexdigest
      @sha256 = sha256_digest.hexdigest
      self
    end

    # @param pathname [Pathname] The location of the file
    # @param digest [FileSignature] The checksums extracted from the BagIt manifests (or other fixity data source)
    # @return [FileSignature] Fixity data (size and checksums) for a file derived from BagIt manifest, if possible
    def signature_from_file_digest(pathname, digest)
      if digest.md5 && digest.sha1 && digest.sha256
        # for efficiency, use the fixity data we already have
        @size = pathname.size
        @md5 = digest.md5
        @sha1 = digest.sha1
        @sha256 = digest.sha256
      else
        # but if any of the digests are missing, then compute new values and validate against expected
        self.signature_from_file(pathname)
        if digest.md5 && @md5 != digest.md5
          raise "MD5 checksum mismatch for #{pathname} found: #{@md5} expected: #{digest.md5}"
        elsif digest.sha1 && @sha1 != digest.sha1
          raise "SHA1 checksum mismatch for #{pathname} found: #{@sha1} expected: #{digest.sha1}"
        elsif digest.sha256 && @sha256 != digest.sha256
          raise "SHA256 checksum mismatch for #{pathname} found: #{@sha256} expected: #{digest.sha256}"
        end
      end
      self
    end

  end

end
