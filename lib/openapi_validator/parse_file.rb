require "json"
require "yaml"

module OpenapiValidator
  module ParseFile
    # @param [String] path path to file
    # @return [Hash] parsed file
    def self.call(path)
      case File.extname(path)
      when ".yml", ".yaml"
        YAML.load_file(path)
      when ".json"
        JSON.parse(File.read(path))
      else
        raise "Can't parse #{path}. It should be json or yaml file.", Error
      end
    end
  end
end
