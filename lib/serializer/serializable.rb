module Serializer
  # Some utility methods to faciliate serialization of data fields to Hash, JSON, or YAML shared by all subclasses.
  # This class assumes that HappyMapper is used for declaration of fields to be serialized.
  #
  # ====Data Model
  # * <b>{Serializable} = utility methods to faciliate serialization to Hash, JSON, or YAML</b>
  #   * {Manifest} = adds methods for marshalling/unmarshalling data to a persistent XML file format
  #
  # @see https://github.com/jnunemaker/happymapper
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class Serializable
    include HappyMapper

    # A flexible initializer based on the DataMapper "create factory" design pattern.
    # @see http://datamapper.org/docs/create_and_destroy.html
    # @see Serializable#initialize
    # @param opts [Hash<Symbol,Object>] a hash containing any number of symbol => value pairs.
    #   The symbols should correspond to attributes declared using HappyMapper syntax
    def initialize(opts = {})
      opts.each do |key, value|
        errmsg = "#{key} is not a variable name in #{self.class.name}"
        raise(Moab::MoabRuntimeError, errmsg) unless variable_names.include?(key.to_s) || key == :test
        instance_variable_set("@#{key}", value)
      end
    end

    # @api internal
    # @return [Array] A list of HappyMapper xml attribute, element and text nodes declared for the class
    def variables
      attributes = self.class.attributes
      elements   = self.class.elements
      attributes + elements
      # text_node enhancement added by unhappymapper, which is not being used
      # It enables elements having both attributes and a text value
      #text_node = []
      #if self.class.instance_variable_defined?("@text_node")
      #  text_node << self.class.instance_variable_get("@text_node")
      #end
      #attributes + elements + text_node
    end

    # @api internal
    # @return [Array] Extract the names of the variables
    def variable_names
      variables.collect(&:name)
    end

    # @api internal
    # @return [String] Determine which attribute was marked as an object instance key.
    #   Keys are indicated by option :key=true when declaring the object's variables.
    #   This follows the same convention as used by DataMapper
    # @see http://datamapper.org/docs/properties.html
    def key_name
      unless defined?(@key_name)
        @key_name = nil
        self.class.attributes.each do |attribute|
          if attribute.options[:key]
            @key_name = attribute.name
            break
          end
        end
      end
      @key_name
    end

    # @api internal
    # @return [String] For the current object instance, return the string to use as a hash key
    def key
      return send(key_name) if key_name
      nil
    end

    # @api internal
    # @param array [Array] The array to be converted to a hash
    # @return [Hash] Generate a hash from an array of objects.
    #   If the array member has a field tagged as a key, that field will be used as the hash.key.
    #   Otherwise the index position of the array member will be used as the key
    def array_to_hash(array, summary = false)
      item_hash = {}
      array.each_index do |index|
        item = array[index]
        ikey = item.respond_to?(:key) && item.key ? item.key : index
        item_hash[ikey] = item.respond_to?(:to_hash) ? item.to_hash(summary) : item
      end
      item_hash
    end

    # @api internal
    # @return [Hash] Recursively generate an Hash containing the object's properties
    # @param summary [Boolean] Controls the depth and detail of recursion
    def to_hash(summary = false)
      oh = {}
      vars = summary ? variables.select { |v| summary_fields.include?(v.name) } : variables
      vars.each do |variable|
        key = variable.name.to_s
        value = send(variable.name)
        oh[key] = case value
                  when Array
                    array_to_hash(value, summary)
                  when Serializable
                    value.to_hash
                  else
                    value
                  end
      end
      oh
    end

    # @return [Hash] Calls to_hash(summary=true)
    def summary
      to_hash(summary = true)
    end

    # @api internal
    # @param other [Serializable] The other object being compared
    # @return [Hash] Generate a hash containing the differences between two objects of the same type
    def diff(other)
      raise(Moab::MoabRuntimeError, "Cannot compare different classes") if self.class != other.class
      left = other.to_hash
      right = to_hash
      if key.nil? || other.key.nil?
        ltag = :old
        rtag = :new
      else
        ltag = other.key
        rtag = key
      end
      Serializable.deep_diff(ltag, left, rtag, right)
    end

    # @api internal
    # @param hashes [Array<Hash>] The hashes to be compared, with optional name tags
    # @return [Hash] Generate a hash containing the differences between two hashes
    #   (recursively descend parallel trees of hashes)
    # @see https://gist.github.com/146844
    def self.deep_diff(*hashes)
      diff = {}
      case hashes.length
      when 4
        ltag, left, rtag, right = hashes
      when 2
        ltag = :left
        left = hashes[0]
        rtag = :right
        right = hashes[1]
      else
        raise ArgumentError, "wrong number of arguments (#{hashes.length} for 2 or 4)"
      end
      (left.keys | right.keys).each do |k|
        if left[k] != right[k]
          diff[k] = if left[k].is_a?(Hash) && right[k].is_a?(Hash)
                      deep_diff(ltag, left[k], rtag, right[k])
                    else
                      Hash.[](ltag, left[k], rtag, right[k])
                    end
        end
      end
      diff
    end

    # @api internal
    # @return [String] Generate JSON output from a hash of the object's variables
    def to_json(summary = false)
      hash = to_hash(summary)
      JSON.pretty_generate(hash)
    end

    # @api internal
    # @return [String] Generate YAML output from a hash of the object's variables
    def to_yaml(summary = false)
      to_hash(summary).to_yaml
    end
  end
end
