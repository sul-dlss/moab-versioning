# frozen_string_literal: true

module Moab
  # A recursive "Tree" type object for verifications
  class VerificationResult
    # @return [String] The name of the entity that was verified
    attr_accessor :entity

    # @return [Boolean] The true/false outcome of the verification
    attr_accessor :verified

    # @return [Hash] The details of the comparisons that were made
    attr_accessor :details

    # @return [Array<VerificationResult>] The subentities, if any, on which this verification is based
    attr_accessor :subentities

    # @param entity [#to_s] The name of the entity being verified
    # @param verified [Boolean]
    # @param details [Hash]
    def initialize(entity, verified = false, details = nil)
      @entity = entity.to_s  # force to string
      @verified = !!verified # rubocop:disable Style/DoubleNegation
      @details = details
      @subentities = Array.new
    end

    # @param entity [#to_s] The name of the entity being verified
    # @param expected [Object] The expected value
    # @param found [Object] The found value
    # @return [VerificationResult] The result of comparing the expected and found values
    def self.verify_value(entity, expected, found)
      details = { 'expected' => expected, 'found' => found }
      new(entity, (expected == found), details)
    end

    # @deprecated Just use the constructor
    # @param entity [#to_s] The name of the entity being verified
    # @param expression [Object] The expression that will be evaluated as true or false
    # @param details [Object] optional details that could be reported
    # @return [VerificationResult] The result of evaluating the expression
    def self.verify_truth(entity, expression, details = nil)
      new(entity, expression, details)
    end

    # @param verbose [Boolean] If true, always provide all details of the verification
    # @return [String] The verification result serialized to JSON
    def to_json(verbose = false)
      JSON.pretty_generate(to_hash(verbose))
    end

    # @param verbose [Boolean] If true, always provide all details of the verification
    # @param level [Integer] Used to test the depth of recursion
    # @return [Hash] The verification result serialized to a hash
    def to_hash(verbose = false, level = 0)
      hash = { 'verified' => verified }
      hash['details'] = details || subentities_to_hash(verbose, level) if verbose || !verified
      return hash if level > 0

      { entity => hash }
    end

    private

    # @param verbose [Boolean] If true, always provide all details of the verification
    # @param level [Integer] Used to increment the depth of recursion
    # @return [Hash] The verification result of subentities serialized to a hash
    def subentities_to_hash(verbose, level)
      subentities.map { |s| [s.entity, s.to_hash(verbose, level + 1)] }.to_h
    end
  end
end
