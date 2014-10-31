module Serializer

  # Subclass of {Serializable} that adds methods for marshalling/unmarshalling data
  # to a persistent XML file format.
  #
  # ====Data Model
  # * {Serializable} = utility methods to faciliate serialization to Hash, JSON, or YAML
  #   * <b>{Manifest} = subclass adds methods for marshalling/unmarshalling data to XML file format</b>
  #
  # @see Serializable
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class Manifest < Serializable

    include HappyMapper

    # @api internal
    # @param filename [String] Optional filename if one wishes to override the default filename
    # @return [String] Returns the standard filename (derived from the class name) to be used for serializing an object
    def self.xml_filename(filename=nil)
      if filename
        filename
      else
        cname = self.name.split(/::/).last
        cname[0, 1].downcase + cname[1..-1] + '.xml'
      end
    end

    # @api internal
    # @param parent_dir [Pathname,String] The location of the directory in which the xml file is located
    # @param filename [String] Optional filename if one wishes to override the default filename
    # @return [Pathname] The location of the xml file
    def self.xml_pathname(parent_dir, filename=nil)
      Pathname.new(parent_dir).join(self.xml_filename(filename))
    end

    # @api external
    # @param parent_dir [Pathname,String] The location of the directory in which the xml file is located
    # @param filename [String] Optional filename if one wishes to override the default filename
    # @return [Boolean] Returns true if the xml file exists
    def self.xml_pathname_exist?(parent_dir, filename=nil)
      self.xml_pathname(parent_dir, filename).exist?
    end

    # @api external
    # @param parent_dir [Pathname,String] The location of the directory in which the xml file is located
    # @param filename [String] Optional filename if one wishes to override the default filename
    # @return [Serializable] Read the xml file and return the parsed XML
    # @example {include:file:spec/features/serializer/read_xml_spec.rb}
    def self.read_xml_file(parent_dir, filename=nil)
      self.parse(self.xml_pathname(parent_dir, filename).read)
    end

    # @api external
    # @param xml_object [Serializable]
    # @param parent_dir [Pathname,String] The location of the directory in which the xml file is located
    # @param filename [String] Optional filename if one wishes to override the default filename
    # @return [void] Serializize the in-memory object to a xml file instance
    def self.write_xml_file(xml_object, parent_dir, filename=nil)
      parent_dir.mkpath
      self.xml_pathname(parent_dir, filename).open('w') do |f|
        xmlBuilder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8')
        xmlBuilder = xml_object.to_xml(xmlBuilder)
        f << xmlBuilder.to_xml
      end
      nil
    end

    # @api external
    # @param parent_dir [Pathname,String] The location of the directory in which the xml file is located
    # @param filename [String] Optional filename if one wishes to override the default filename
    # @return [void] Serializize the in-memory object to a xml file instance
    # @example {include:file:spec/features/serializer/write_xml_spec.rb}
    def write_xml_file(parent_dir, filename=nil)
      self.class.write_xml_file(self, parent_dir, filename)
    end

  end

end
