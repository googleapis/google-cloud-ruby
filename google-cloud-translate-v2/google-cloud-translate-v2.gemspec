require File.expand_path("lib/google/cloud/translate/v2/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-translate-v2"
  gem.version       = Google::Cloud::Translate::V2::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud Translation can dynamically translate text between thousands of language pairs. Translation lets websites and programs programmatically integrate with the translation service."
  gem.summary       = "API Client library for Cloud Translation V2 API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", "CHANGELOG.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.4"

  gem.add_dependency "faraday", ">= 0.17.3", "< 2.0"
  gem.add_dependency "google-cloud-core", "~> 1.5"
  gem.add_dependency "googleapis-common-protos", ">= 1.3.10", "< 2.0"
  gem.add_dependency "googleapis-common-protos-types", ">= 1.0.5", "< 2.0"
  gem.add_dependency "googleauth", "~> 0.12"

  gem.add_development_dependency "google-style", "~> 1.24.0"
  gem.add_development_dependency "minitest", "~> 5.14"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "rake", ">= 12.0"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.18"
  gem.add_development_dependency "yard", "~> 0.9"
  gem.add_development_dependency "yard-doctest", "~> 0.1.13"
end
