require "dry-initializer"

module OpenapiValidator
  class Request
    extend Dry::Initializer

    option :path, proc(&:to_s)
    option :method, proc(&:to_s)
    option :code, proc(&:to_s)
    option :media_type, proc(&:to_s), default: -> { "application/json" }

    def path_key
      path[%r{(/[-_/\{\}\w]*)}]
    end
  end
end
