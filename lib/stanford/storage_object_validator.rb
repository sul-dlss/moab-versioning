require 'moab'

module Stanford
  # druids are Stanford specific entities
  class StorageObjectValidator < Moab::StorageObjectValidator

    # TODO: test to make sure constants don't collide on underlying int vals?
    # keep from stepping on previously defined error code constants.
    DRUID_MISMATCH = superclass.error_code_to_messages.keys.max + 1

    def validation_errors
      errors = []
      errors.concat super
      errors.concat(identify_druid) if errors.empty?
      errors
    end

    def identify_druid
      druid_from_filepath == object_id_from_manifest_inventory ? [] : [result_hash(DRUID_MISMATCH)]
    end

    # the Stanford validator expects keys to be in ascending numerical order
    def self.error_code_to_messages
      @error_code_to_messages ||=
        {
          DRUID_MISMATCH => 'manifestInventory object_id does not match druid'
        }.merge!(superclass.error_code_to_messages).freeze
    end

    private

    def druid_from_filepath
      "druid:#{File.basename(storage_obj_path)}"
    end
  end
end
