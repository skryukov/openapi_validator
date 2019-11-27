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

    attr_reader :request, :schema, :data, :fragment, :response, :media_type

    def initialize(request:, schema:, data:, fragment:, response:, media_type:)
      @request = request
      @schema = schema
      @data = data
      @media_type = media_type
      @fragment = fragment
      @response = response
      @errors = []
    end

    def validate_response
      @errors += validator.new(schema: schema, data: data, fragment: fragment, media_type: media_type, response: response).validate
    end

    def validator
      case media_type
      when %r{^image/[^/]*$}
        OpenapiValidator::ResponseValidator::ImageValidator
      else
        OpenapiValidator::ResponseValidator::JsonValidator
      end
    end
  end
end
