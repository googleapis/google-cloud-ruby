require File.expand_path("lib/stackdriver/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "stackdriver"
  gem.version       = Stackdriver::VERSION

  gem.authors       = ["Heng Xiong"]
  gem.email         = ["hxiong388@gmail.com"]
  gem.description   = "stackdriver is the official library for Google Stackdriver APIs."
  gem.summary       = "API Client library for Google Stackdriver"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby/tree/master/stackdriver"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["OVERVIEW.md", "INSTRUMENTATION_CONFIGURATION.md", "CONTRIBUTING.md", "CHANGELOG.md",
                       "CODE_OF_CONDUCT.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_runtime_dependency "google-cloud-error_reporting", "~> 0.41"
  gem.add_runtime_dependency "google-cloud-logging", "~> 2.1"
  gem.add_runtime_dependency "google-cloud-trace", "~> 0.40"
end
