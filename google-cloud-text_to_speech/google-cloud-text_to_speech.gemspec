# -*- ruby -*-
# encoding: utf-8
require File.expand_path("../lib/google/cloud/text_to_speech/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-text_to_speech"
  gem.version       = Google::Cloud::TextToSpeech::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "google-cloud-text_to_speech is the official library for Cloud Text-to-Speech API."
  gem.summary       = "API Client library for Cloud Text-to-Speech API"
  gem.homepage      = "https://github.com/googleapis/googleapis"
  gem.license       = "Apache-2.0"

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
