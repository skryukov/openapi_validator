require "json-schema"
require "openapi_validator/schema/required_attribute"
require "openapi_validator/schema/type_attribute"

module OpenapiValidator
  class ExtendedSchema < JSON::Schema::Draft4
    def initialize
      super
      @attributes['type'] = TypeAttribute
      @attributes['required'] = RequiredAttribute
      @uri = URI.parse('http://example.com/extended_schema')
      @names = ['http://example.com/extended_schema']
    end

    JSON::Validator.register_validator(self.new)
    JSON::Validator.register_default_validator(self.new)
  end
end
