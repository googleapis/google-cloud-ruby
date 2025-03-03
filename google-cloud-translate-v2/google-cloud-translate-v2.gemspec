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

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "faraday", ">= 1.0", "< 3.a"
  gem.add_dependency "googleapis-common-protos", ">= 1.3.10", "< 2.a"
  gem.add_dependency "googleapis-common-protos-types", ">= 1.0.5", "< 2.a"
  gem.add_dependency "googleauth", ">= 0.16.2", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
