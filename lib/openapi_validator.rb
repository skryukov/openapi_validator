require "openapi_validator/extended_schema"
require "openapi_validator/validator"
require "openapi_validator/version"

module OpenapiValidator
  class Error < StandardError; end

  # @see Validator#initialize
  def self.call(*attrs)
    Validator.new(*attrs)
  end
end
