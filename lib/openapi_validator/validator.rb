require "json-schema"
require "openapi_validator/file_loader"
require "openapi_validator/documentation_validator"
require "openapi_validator/request_validator"

module OpenapiValidator
  class Validator

    attr_reader :api_base_path

    # @return [DocumentationValidator] validation result
    def validate_documentation
      DocumentationValidator.call(api_doc, additional_schemas: additional_schemas)
    end

    def validate_request(**params)
      RequestValidator.call(api_doc, **params)
    end

    private

    attr_reader :api_doc, :additional_schemas

    # @param [String] path path to openapi documentation
    # @param [Array<String>] additional_schemas paths to custom schemas
    def initialize(path, additional_schemas: [], api_base_path: "")
      @api_doc = FileLoader.call(path)
      @api_base_path = api_base_path
      @additional_schemas = additional_schemas
    end
  end
end
