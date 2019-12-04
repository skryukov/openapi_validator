require "dry-initializer"

module OpenapiValidator
  class Path
    class Error < StandardError; end

    extend Dry::Initializer

    option :schema_code
    option :code_schema
    option :request
    option :fragment_path

    def empty_schema?
      code_schema.nil?
    end

    def path
      [request.path_key, request.method, schema_code]
    end

    def fragment(media_type: request.media_type)
      if code_schema[media_type].nil?
        raise(Error, "OpenAPI documentation does not have a documented response"\
                     " for #{media_type} media-type at path #{request.method.upcase} #{request.path_key}")
      end

      fragment = fragment_path
      fragment += ["content", media_type, "schema"] if code_schema
      fragment.tap do |array|
        array.define_singleton_method(:split) do |_|
          self
        end
      end
      fragment
    end

  end
end
