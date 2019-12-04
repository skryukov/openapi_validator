require "dry-initializer"
require "openapi_validator/path"

module OpenapiValidator
  class PathValidator
    class Error < StandardError; end

    extend Dry::Initializer

    option :api_doc
    option :request


    def self.call(**params)
      new(**params).call
    end

    def call
      build_path
    end

    private

    def build_path
      Path.new(request: request,
               code_schema: code_schema,
               fragment_path: @fragment_path,
               schema_code: @schema_code)
    end

    def code_schema
      schema = schema_code
      if schema && schema["$ref"]
        @fragment_path = schema["$ref"].split("/")
        api_doc.dig(*(schema["$ref"][2..-1].split("/")))
      else
        @fragment_path = ["#", "paths", request.path_key, request.method, "responses", @schema_code]
        schema
      end["content"]
    end

    def schema_code
      responses = responses_schema
      if responses[request.code]
        @schema_code = request.code
      elsif responses["default"]
        @schema_code = "default"
      else
        raise(Error, "OpenAPI documentation does not have a documented response for code #{request.code}"\
                    " at path #{request.method.upcase} #{request.path_key}")
      end

      responses.dig(@schema_code)
    end

    def responses_schema
      path_schema.dig(request.method, "responses") ||
        raise(Error, "OpenAPI documentation does not have a documented path for #{request.method.upcase} #{request.path_key}")
    end

    def path_schema
      api_doc.dig("paths", request.path_key) ||
        raise(Error, "OpenAPI documentation does not have a documented path for #{request.path_key}")
    end
  end
end
