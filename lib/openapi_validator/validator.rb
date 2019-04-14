require "json-schema"
require "openapi_validator/file_loader"
require "openapi_validator/documentation_validator"
require "openapi_validator/request_validator"

module OpenapiValidator
  class Validator

    attr_reader :api_base_path, :unvalidated_requests

    # @return [DocumentationValidator] validation result
    def validate_documentation
      DocumentationValidator.call(api_doc, additional_schemas: additional_schemas)
    end

    def validate_request(**params)
      RequestValidator.call(api_doc, **params, unvalidated_requests: unvalidated_requests)
    end

    private

    attr_reader :api_doc, :additional_schemas

    # @param [Hash] doc parsed openapi documentation
    # @param [Array<String>] additional_schemas paths to custom schemas
    def initialize(doc, additional_schemas: [], api_base_path: "")
      @api_doc = doc
      @api_base_path = api_base_path
      @additional_schemas = additional_schemas
      @unvalidated_requests = build_unvalidated_requests
    end

    def build_unvalidated_requests
      requests = []
      api_doc["paths"] && api_doc["paths"].each do |path, methods|
        methods.each do |method, values|
          values["responses"] && values["responses"].each_key do |code|
            requests << [path, method, code]
          end
        end
      end
      requests
    end
  end
end
