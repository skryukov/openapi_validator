module OpenapiValidator
  class Request
    attr_reader :path, :method, :code, :media_type

    def self.call(**params)
      new(**params)
    end

    def path_key
      path[%r{(/[-_/\{\}\w]*)(\.[\{\}\w]*)?}]
    end

    private

    def initialize(path:, method:, code:, media_type: "application/json")
      @path = path
      @method = method.to_s
      @code = code.to_s
      @media_type = media_type.to_s
    end
  end
end
