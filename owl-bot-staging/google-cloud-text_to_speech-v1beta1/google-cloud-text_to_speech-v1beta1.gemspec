# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/text_to_speech/v1beta1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-text_to_speech-v1beta1"
  gem.version       = Google::Cloud::TextToSpeech::V1beta1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Text-to-Speech converts text or Speech Synthesis Markup Language (SSML) input into audio data of natural human speech. Note that google-cloud-text_to_speech-v1beta1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-text_to_speech instead. See the readme for more details."
  gem.summary       = "Synthesizes natural-sounding speech by applying powerful neural network models."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "gapic-common", ">= 0.21.1", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
end
