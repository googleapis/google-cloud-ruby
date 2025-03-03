require File.expand_path("lib/google/cloud/errors/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-errors"
  gem.version       = Google::Cloud::Errors::VERSION

  gem.authors       = ["Mike Moore", "Chris Smith"]
  gem.email         = ["mike@blowmage.com", "quartzmo@gmail.com"]
  gem.description   = "google-cloud-errors defines error classes for google-cloud-ruby."
  gem.summary       = "Error classes for google-cloud-ruby"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-errors"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "CONTRIBUTING.md", "CODE_OF_CONDUCT.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"
end
