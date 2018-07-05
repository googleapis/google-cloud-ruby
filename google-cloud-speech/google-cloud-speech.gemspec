# -*- ruby -*-
# encoding: utf-8

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-speech"
  gem.version       = "0.30.0"

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "google-cloud-speech is the official library for Cloud Speech API."
  gem.summary       = "API Client library for Cloud Speech API"
  gem.homepage      = "https://github.com/googleapis/googleapis"
  gem.license       = "Apache-2.0"

  gem.post_install_message =
    "The 0.30.0 release introduced breaking changes relative to the "\
    "previous release, 0.29.0. For more details and instructions to migrate "\
    "your code, please visit the migration guide: "\
    "https://cloud.google.com/speech-to-text/docs/ruby-client-migration."

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.0.0"

  gem.add_dependency "google-gax", "~> 1.3"

  gem.add_development_dependency "minitest", "~> 5.10"
  gem.add_development_dependency "rubocop", "~> 0.50.0"
  gem.add_development_dependency "simplecov", "~> 0.9"
end
