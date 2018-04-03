require 'moab'

module Moab
  class VerificationResult
    # @return [String] The name of the entity that was verified
    attr_accessor :entity

    # @return [Boolean] The true/false outcome of the verification
    attr_accessor :verified

    # @return [Hash] The details of the comparisons that were made
    attr_accessor :details

    # @return [Array<VerificationResult>] The subentities, if any, on which this verification is based
    attr_accessor :subentities

    # @param entity [Object] The name of the entity being verified
    def initialize(entity)
      @entity = entity
      @verified = false
      @details = nil
      @subentities = Array.new
    end

    # @param entity [Symbol] The name of the entity being verified
    # @param expected [Object] The expected value
    # @param found [Object] The found value
    # @return [VerificationResult] The result of comparing the expected and found values
    def self.verify_value(entity, expected, found)
      result = VerificationResult.new(entity.to_s)
      result.verified = (expected == found)
      result.details = { 'expected' => expected, 'found' => found }
      result
    end

    # @param entity [Symbol] The name of the entity being verified
    # @param expression [Object] The expression that will be evaluated as true or false
    # @param details [Object] optional details that could be reported
    # @return [VerificationResult] The result of evaluating the expression
    def self.verify_truth(entity, expression, details = nil)
      result = VerificationResult.new(entity.to_s)
      # TODO: add expression.empty?
      result.verified = !(expression.nil? or (expression == false))
      result.details = details
      result
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
      hash = Hash.new
      hash['verified'] = @verified
      if (verbose or @verified == false)
        hash['details'] = @details ? @details : subentities_to_hash(verbose, level)
      end
      if level > 0
        hash
      else
        { @entity => hash }
      end
    end

    # @param verbose [Boolean] If true, always provide all details of the verification
    # @param level [Integer] Used to increment the depth of recursion
    # @return [Hash] The verification result of subentities serialized to a hash
    def subentities_to_hash(verbose, level)
      hash = Hash.new
      @subentities.each do |s|
        hash[s.entity] = s.to_hash(verbose, level + 1)
      end
      hash
    end
  end
end
