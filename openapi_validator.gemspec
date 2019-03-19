lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "openapi_validator/version"

Gem::Specification.new do |spec|
  spec.name          = "openapi_validator"
  spec.version       = OpenapiValidator::VERSION
  spec.authors       = ["Svyatoslav Kryukov"]
  spec.email         = ["s.g.kryukov@yandex.ru"]

  spec.summary       = "Validator used for openapi_rspec"
  spec.homepage      = "https://github.com/llcmedsolutions/openapi_validator"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "json-schema", "~> 2.8"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
