require "json-schema/attributes/type_v4"

module OpenapiValidator
  class ExtendedTypeAttribute < JSON::Schema::TypeV4Attribute
    def self.validate(current_schema, data, fragments, processor, validator, options = {})
      return if data.nil? && current_schema.schema["nullable"] == true
      super
    end
  end
end
