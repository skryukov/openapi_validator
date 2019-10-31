require "json-schema/attributes/required"

module OpenapiValidator
  class RequiredAttribute < JSON::Schema::RequiredAttribute
    def self.validate(current_schema, data, fragments, processor, validator, options = {})
      return unless data.is_a?(Hash)

      schema = current_schema.schema
      defined_properties = schema["properties"]

      schema["required"].each do |property, _property_schema|
        next if data.key?(property.to_s)
        prop_defaults = options[:insert_defaults] &&
          defined_properties &&
          defined_properties[property] &&
          !defined_properties[property]["default"].nil? &&
          !defined_properties[property]["readonly"]

        skip_error = processor.options[:response] && defined_properties.dig(property, "writeOnly")

        if !prop_defaults && !skip_error
          message = "The property '#{build_fragment(fragments)}' did not contain a required property of '#{property}'"
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
        end
      end
    end
  end
end
