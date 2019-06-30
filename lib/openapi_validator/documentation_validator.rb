require "json-schema"
require "openapi_validator/file_loader"
require "openapi_validator/schema/json_validator"

module OpenapiValidator
  class DocumentationValidator

    attr_reader :errors

    # @param [Hash] api_doc parsed openapi documentation
    # @param [Array<String>] additional_schemas paths to custom schemas
    # @return [DocumentationValidator] validation result
    def self.call(api_doc, additional_schemas: [])
      new(api_doc, additional_schemas: additional_schemas).call
    end

    # @return [DocumentationValidator]
    def call
      validate
    end

    # @return [true, false]
    def valid?
      errors.empty?
    end

    private

    attr_reader :api_doc, :schemas

    # @return [DocumentationValidator]
    def validate
      parsed_schemas.each do |schema|
        errors.concat JsonValidator.fully_validate(schema, api_doc)
      end

      self
    end

    # @return [Array<Hash>] parsed custom schemas
    def parsed_schemas
      schemas.map { |schema| FileLoader.call(schema) }
    end

    # @param [Hash] api_doc parsed openapi documentation
    # @param [Array<String>] additional_schemas paths to custom schemas
    def initialize(api_doc, additional_schemas:)
      @api_doc = api_doc
      @schemas = additional_schemas.unshift openapi_schema
      @errors = []
    end

    # @return [String] path to openapi v3 schema
    def openapi_schema
      File.expand_path("../../../data/openapi-3.0.json", __FILE__)
    end
  end
end
