require "openapi_validator/schema/extended_schema"
require "openapi_validator/parse_file"
require "openapi_validator/validator"
require "openapi_validator/version"

module OpenapiValidator
  class Error < StandardError; end

  # @see Validator#initialize
  def self.call(doc, **params)
    Validator.new(parse_doc(doc), **params)
  end

  def self.parse_doc(doc)
    if doc.is_a? String
      ParseFile.call(doc)
    elsif doc.is_a? Hash
      doc
    else
      raise ArgumentError, "Please provide parsed OpenAPI doc as Hash or path to file as String. Passed: #{doc.class}"
    end
  end
end
