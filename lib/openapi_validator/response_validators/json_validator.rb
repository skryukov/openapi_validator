module OpenapiValidator
  class ResponseValidator
    class JsonValidator
      def initialize(schema:, data:, fragment:, media_type:, response:)
        @schema = schema
        @data = data
        @fragment = fragment
        @media_type = media_type
        @response = response
      end

      def validate
        OpenapiValidator::JsonValidator.fully_validate(schema, data, fragment: fragment, response: response)
      end

      private

      attr_reader :schema, :data, :fragment, :media_type, :response, :errors
    end
  end
end
