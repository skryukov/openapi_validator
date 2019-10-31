require "json"
require "yaml"

module OpenapiValidator
  class FileLoader
    # @param [String] path path to file
    # @return [Hash] parsed file
    def self.call(path)
      new(path).call
    end

    # @return [Hash] parsed file
    def call
      case File.extname(path)
      when ".yml", ".yaml"
        YAML.load_file(path)
      when ".json"
        JSON.parse(File.read(path))
      else
        raise "Can't parse #{path}. It should be json or yaml file.", Error
      end
    end

    private

    attr_reader :path

    # @param [String] path path to file
    def initialize(path)
      @path = path
    end
  end
end
