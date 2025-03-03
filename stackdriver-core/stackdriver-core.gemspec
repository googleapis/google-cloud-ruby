require File.expand_path("lib/stackdriver/core/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "stackdriver-core"
  gem.version       = Stackdriver::Core::VERSION

  gem.authors       = ["Daniel Azuma"]
  gem.email         = ["dazuma@google.com"]
  gem.description   = "stackdriver-core is an internal shared library for the Ruby Stackdriver integration libraries."
  gem.summary       = "Internal shared library for Ruby Stackdriver integration"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby/tree/master/stackdriver-core"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["OVERVIEW.md", "CONTRIBUTING.md", "CHANGELOG.md", "CODE_OF_CONDUCT.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-cloud-core", "~> 1.2"
end
