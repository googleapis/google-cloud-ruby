require File.expand_path("lib/google/cloud/core/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-core"
  gem.version       = Google::Cloud::Core::VERSION

  gem.authors       = ["Mike Moore", "Chris Smith"]
  gem.email         = ["mike@blowmage.com", "quartzmo@gmail.com"]
  gem.description   = "google-cloud-core is the internal shared library for google-cloud-ruby."
  gem.summary       = "Internal shared library for google-cloud-ruby"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-core"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "CONTRIBUTING.md", "CODE_OF_CONDUCT.md", "LICENSE",
                       ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-cloud-env", ">= 1.0", "< 3.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
end
