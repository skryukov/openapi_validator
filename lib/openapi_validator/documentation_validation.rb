require "openapi_validator/schema/json_validator"
require "openapi_validator/parse_file"
require "openapi_validator/result"

module OpenapiValidator
  module DocumentationValidation
    OPEN_API_SCHEMA = File.expand_path("../../../data/openapi-3.0.json", __FILE__).freeze

    # @param [Hash] api_doc parsed openapi documentation
    # @param [Array<String>] additional_schemas paths to custom schemas
    # @return [Result]
    def self.call(api_doc:, additional_schemas:)
      errors = []
      parsed_schemas(additional_schemas).each do |schema|
        errors.concat JsonValidator.fully_validate(schema, api_doc)
      end

      Result.new(errors: errors)
    end

    # @return [Array<Hash>] parsed custom schemas
    def self.parsed_schemas(additional_schemas)
      additional_schemas.unshift(OPEN_API_SCHEMA).map { |schema| ParseFile.call(schema) }
    end
  end
end
