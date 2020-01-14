# frozen_string_literal: true

module Moab
  class MoabRuntimeError < RuntimeError; end
  class MoabStandardError < StandardError; end

  class FileNotFoundException < MoabRuntimeError; end
  class InvalidMetadataException < MoabRuntimeError; end
  class InvalidSuriSyntaxError < MoabRuntimeError; end
  class ObjectNotFoundException < MoabRuntimeError; end
end
