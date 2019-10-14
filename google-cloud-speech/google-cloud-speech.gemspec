# -*- ruby -*-
# encoding: utf-8
require File.expand_path("../lib/google/cloud/speech/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-speech"
  gem.version       = Google::Cloud::Speech::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "google-cloud-speech is the official library for Cloud Speech-to-Text API."
  gem.summary       = "API Client library for Cloud Speech-to-Text API"
  gem.homepage      = "https://github.com/googleapis/googleapis"
  gem.license       = "Apache-2.0"

  gem.post_install_message =
    "The 0.30.0 release introduced breaking changes relative to the "\
    "previous release, 0.29.0. For more details and instructions to migrate "\
    "your code, please visit the migration guide: "\
    "https://cloud.google.com/speech-to-text/docs/ruby-client-migration."

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.0.0"

  gem.add_dependency "google-gax", "~> 1.7"

  gem.add_development_dependency "minitest", "~> 5.10"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "rubocop", "~> 0.64.0"
  gem.add_development_dependency "simplecov", "~> 0.17"
  gem.add_development_dependency "yard", "~> 0.9"
end
