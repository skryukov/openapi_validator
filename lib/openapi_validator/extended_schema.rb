require "json-schema"
require "openapi_validator/schema/json_validator"
require "openapi_validator/schema/required_attribute"
require "openapi_validator/schema/type_attribute"

module OpenapiValidator
  class ExtendedSchema < JSON::Schema::Draft4
    def initialize
      super
      @attributes["type"] = TypeAttribute
      @attributes["required"] = RequiredAttribute
      @uri = URI.parse("http://example.com/extended_schema")
      @names = ["http://example.com/extended_schema"]
    end

    JsonValidator.register_validator(new)
    JsonValidator.register_default_validator(new)
  end
end
