require 'openapi_validator/path_validator'
require 'openapi_validator/response_validator'
require 'openapi_validator/schema/json_validator'

module OpenapiValidator
  class RequestValidator

    attr_reader :errors, :api_doc, :path_validator

    def valid?
      errors.empty?
    end

    def self.call(**params)
      new(**params).call
    end

    def call
      validate_path
      self
    end

    def validate_response(body:, code:)
      if request.code != code.to_s
        @errors << "Path #{request.path} did not respond with expected status code. Expected #{request.code} got #{code}"
      end

      if path_validator.empty_schema?
        @errors << "Path #{request.path} should return empty response." unless body.empty?
      else
        @errors += OpenapiValidator::ResponseValidator.call(
          request: request, schema: validator.api_doc, data: body, fragment: path_validator.fragment, response: true
        ).errors
      end

      validator.remove_validated_path(path_validator.path) if @errors.empty?
      self
    end

    private

    attr_reader :request, :validator

    def initialize(request:, validator:)
      @validator = validator
      @request = request
      @errors = []
    end

    def validate_path
      @path_validator = PathValidator.call(request: request, api_doc: validator.api_doc)
    rescue PathValidator::Error => e
      @errors << e.message
    end
  end
end
