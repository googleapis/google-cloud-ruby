# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/speech/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-speech"
  gem.version       = Google::Cloud::Speech::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Google Speech-to-Text enables developers to convert audio to text by applying powerful neural network models in an easy-to-use API. The API recognizes more than 120 languages and variants to support your global user base. You can enable voice command-and-control, transcribe audio from call centers, and more. It can process real-time streaming or prerecorded audio, using Google's machine learning technology."
  gem.summary       = "API Client library for the Cloud Speech-to-Text API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts", "MIGRATING.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-speech-v1", ">= 0.16", "< 2.a"
  gem.add_dependency "google-cloud-speech-v1p1beta1", ">= 0.20", "< 2.a"
end
