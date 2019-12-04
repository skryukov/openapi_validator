require "dry-initializer"

module OpenapiValidator
  class Result
    extend Dry::Initializer

    option :errors, default: -> { [] }

    # @return [true, false]
    def valid?
      errors.empty?
    end
  end
end
