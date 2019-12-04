require "dry-initializer"

require "openapi_validator/documentation_validation"
require "openapi_validator/request"
require "openapi_validator/request_validator"

module OpenapiValidator
  class Validator
    extend Dry::Initializer

    param :api_doc
    option :api_base_path, default: -> { "".freeze }
    option :additional_schemas, default: -> { [] }
    option :unvalidated_requests, default: -> { build_unvalidated_requests }

    # @return [Result] validation result
    def validate_documentation
      DocumentationValidation.call(api_doc: api_doc, additional_schemas: additional_schemas)
    end

    # @return [RequestValidator]
    def validate_request(**params)
      RequestValidator.call(request: Request.new(**params), validator: self)
    end

    # @param [Array] request
    def remove_validated_path(request)
      unvalidated_requests.delete(request)
    end

    private

    # @return [Array]
    def build_unvalidated_requests
      http_methods = %w[get put post delete options head patch trace]
      requests = []
      api_doc["paths"]&.each do |path, methods|
        methods.each do |method, values|
          next unless http_methods.include?(method)

          values["responses"]&.each_key do |code|
            requests << [path, method, code]
          end
        end
      end
      requests
    end
  end
end
