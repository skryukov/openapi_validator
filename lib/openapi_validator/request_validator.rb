require "dry-initializer"

require "openapi_validator/path_validator"
require "openapi_validator/path"
require "openapi_validator/schema/json_validator"

module OpenapiValidator
  class RequestValidator
    extend Dry::Initializer

    attr_reader :path

    option :errors, default: -> { [] }
    option :validator
    option :request

    def self.call(**params)
      new(**params).call
    end

    def call
      validate_path
      self
    end

    def valid?
      errors.empty?
    end

    def validate_response(body:, code:, media_type: request.media_type)
      if request.code != code.to_s
        @errors << "Path #{request.path} did not respond with expected status code. Expected #{request.code} got #{code}"
      end

      if path.empty_schema?
        @errors << "Path #{request.path} should return empty response." unless body.empty?
      else
        begin
          fragment = path.fragment(media_type: media_type)
        rescue Path::Error => e
          @errors << e.message
        end
        @errors += JsonValidator.fully_validate(validator.api_doc, body, fragment: fragment, response: true)
      end

      validator.remove_validated_path(path.path) if @errors.empty?
      self
    end

    private

    def validate_path
      @path = PathValidator.call(request: request, api_doc: validator.api_doc)
    rescue PathValidator::Error => e
      @errors << e.message
    end
  end
end
