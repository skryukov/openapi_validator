require "openapi_validator/extended_schema"
require "openapi_validator/validator"
require "openapi_validator/version"

module OpenapiValidator
  class Error < StandardError; end

  # @see Validator#initialize
  def self.call(doc, **params)
    if doc.is_a? String
      parsed_doc = FileLoader.call(doc)
    elsif doc.is_a? Hash
      parsed_doc = doc
    else
      raise ArgumentError, "Please provide parsed OpenAPI doc as Hash or path to file as String. Passed: #{doc.class}"
    end

    Validator.new(parsed_doc, **params)
  end
end
