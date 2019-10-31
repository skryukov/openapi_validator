require "openapi_validator/response_validators/json_validator"
require "openapi_validator/response_validators/image_validator"

module OpenapiValidator
  class ResponseValidator
    attr_reader :errors

    def valid?
      errors.empty?
    end

    def self.call(**params)
      new(**params).call
    end

    def call
      validate_response
      self
    end

    private

    attr_reader :request, :schema, :data, :fragment, :response

    def initialize(request:, schema:, data:, fragment:, response:)
      @request = request
      @schema = schema
      @data = data
      @fragment = fragment
      @response = response
      @errors = []
    end

    def validate_response
      @errors += validator.new(schema: schema, data: data, fragment: fragment, media_type: request.media_type, response: response).validate
    end

    def validator
      case request.media_type
      when "application/json"
        OpenapiValidator::ResponseValidator::JsonValidator
      when %r{^image/[^/]*$}
        OpenapiValidator::ResponseValidator::ImageValidator
      end
    end
  end
end
