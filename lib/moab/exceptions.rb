module Moab
  class ObjectNotFoundException < RuntimeError
  end

  class FileNotFoundException < RuntimeError
  end

  class InvalidMetadataException < RuntimeError
  end

  class ValidationException < RuntimeError
  end
end
