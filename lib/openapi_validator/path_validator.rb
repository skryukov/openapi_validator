require "forwardable"

module OpenapiValidator
  class PathValidator
    class Error < StandardError; end

    extend Forwardable

    def empty_schema?
      @empty_schema || false
    end

    def path
      [path_key, method, @schema_code]
    end

    def fragment
      build_fragment.tap do |array|
        array.define_singleton_method(:split) do |_|
          self
        end
      end
    end

    def self.call(**params)
      new(**params).call
    end

    def call
      validate_path_exists
      self
    end

    private

    attr_reader :api_doc

    def_delegators :@request, :media_type, :method, :path_key, :code

    def initialize(request:, api_doc:)
      @request = request
      @api_doc = api_doc
    end

    def validate_path_exists
      if code_schema.nil?
        @empty_schema = true
        return
      end
      code_schema.dig(media_type) ||
        raise(Error, "OpenAPI documentation does not have a documented response"\
                     " for #{media_type} media-type at path #{method.upcase} #{path_key}")
    end

    def code_schema
      schema = schema_code
      ref_schema(schema) || content_schema(schema)
    end

    def content_schema(responses)
      responses.dig("content")
    end

    def ref_schema(responses)
      schema = responses.dig("$ref")
      return unless schema

      @fragment_path = schema
      api_doc.dig(*schema[2..-1].split("/"), "content")
    end

    def schema_code
      responses = responses_schema
      if responses.dig(code)
        @schema_code = code
      elsif responses.dig("default")
        @schema_code = "default"
      else
        raise(Error, "OpenAPI documentation does not have a documented response for code #{code}"\
                    " at path #{method.upcase} #{path_key}")
      end

      responses.dig(@schema_code)
    end

    def responses_schema
      path_schema.dig(method, "responses") ||
        raise(Error, "OpenAPI documentation does not have a documented path for #{method.upcase} #{path_key}")
    end

    def path_schema
      api_doc.dig("paths", path_key) ||
        raise(Error, "OpenAPI documentation does not have a documented path for #{path_key}")
    end

    def build_fragment
      fragment =
        if @fragment_path
          @fragment_path.split("/")
        else
          ["#", "paths", path_key, method, "responses", @schema_code]
        end

      fragment += ["content", media_type, "schema"] unless @empty_schema

      fragment
    end
  end
end
