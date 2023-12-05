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

  gem.required_ruby_version = ">= 2.5"

  gem.add_dependency "google-cloud-env", ">= 1.0", "< 3.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"

  gem.add_development_dependency "autotest-suffix", "~> 1.1"
  gem.add_development_dependency "google-style", "~> 1.25.1"
  gem.add_development_dependency "minitest", "~> 5.14"
  gem.add_development_dependency "minitest-autotest", "~> 1.0"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
  gem.add_development_dependency "yard-doctest", "~> 0.1.13"
end
