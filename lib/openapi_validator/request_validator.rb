module OpenapiValidator
  class RequestValidator

    attr_reader :errors

    def valid?
      errors.empty?
    end

    def self.call(api_doc, **params)
      new(api_doc, **params).call
    end

    def call
      validate_path_exists
      self
    end

    def validate_response(body:, code:)
      response_body = body
      response_code = code.to_s
      if @code != response_code
        @errors << "Path #{path} did not respond with expected status code. Expected #{@code} got #{response_code}"
      end
      @errors += JSON::Validator.fully_validate(api_doc, response_body, fragment: fragment)
      self
    end

    private

    attr_reader :api_doc, :path, :method, :code, :media_type

    def initialize(api_doc, path:, method:, code:, media_type: "application/json")
      @api_doc = api_doc
      @path = path
      @method = method.to_s
      @code = code.to_s
      @media_type = media_type.to_s
      @errors = []
    end

    def path_key
      path[/(\/[-_\/\{\}\w]*)/]
    end

    def fragment
      @fragment.tap do |array|
        array.define_singleton_method(:split) do |_|
          self
        end
       end
    end

    def validate_path_exists
      path_schema = api_doc.dig("paths", path_key)
      unless path_schema
        errors << "OpenAPI documentation does not have a documented path for #{path_key}"
        return
      end

      responses_schema = path_schema.dig(method, "responses")
      unless responses_schema
        errors << "OpenAPI documentation does not have a documented path for #{method.upcase} #{path_key}"
        return
      end

      content_schema = responses_schema.dig(code, "$ref") || responses_schema.dig(code, "content") || responses_schema.dig("default", "$ref") || responses_schema.dig("default", "content")
      unless content_schema
        errors << "OpenAPI documentation does not have a documented response for code #{code}"\
                  " at path #{method.upcase} #{path_key}"
        return
      end      
      
      if content_schema.is_a?(String)
        @fragment = content_schema.split('/')
        content_schema = api_doc.dig(*content_schema[2..-1].split('/'), "content")
      else
        @fragment = ["#", "paths", path_key, method, "responses", code]
      end

      response_schema = content_schema.dig(media_type)
      unless response_schema
        errors << "OpenAPI documentation does not have a documented response for #{media_type}"\
                  " media-type at path #{method.upcase} #{path_key}"
      end
      @fragment += ["content", media_type, "schema"]
    end
  end
end
