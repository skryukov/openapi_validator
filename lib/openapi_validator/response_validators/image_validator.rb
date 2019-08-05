module OpenapiValidator
  class ResponseValidator
    class ImageValidator
      def initialize(schema:, data:, fragment:, media_type:, response:)
        @schema = schema
        @data = data
        @fragment = fragment
        @media_type = media_type
        @response = response
        @property_name = JSON::Schema::Attribute.build_fragment([fragment])
        @errors = []
      end

      def validate
        validate_media_type
        validate_schema

        @errors
      end

      private

      attr_reader :schema, :data, :fragment, :media_type, :response, :property_name

      def validate_media_type
        type, sub_type = media_type.split('/')
        content = MimeMagic.by_magic(data)

        if content&.mediatype != type && (content&.subtype == sub_type || sub_type == '*')
          @errors << "Content-type of property '#{property_name}' did not match the following content-type: #{media_type}"
        end
      end

      def validate_schema
        unless JSON::Schema::Attribute.data_valid_for_type?(data, 'string')
           @errors << "The property '#{property_name}' did not match the following type: #{type}"
        end
      end
    end
  end
end
