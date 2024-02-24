# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/vision/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-vision"
  gem.version       = Google::Cloud::Vision::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud Vision API allows developers to easily integrate vision detection features within applications, including image labeling, face and landmark detection, optical character recognition (OCR), and tagging of explicit content."
  gem.summary       = "API Client library for the Cloud Vision API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts", "MIGRATING.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-vision-v1", ">= 0.13", "< 2.a"
  gem.add_dependency "google-cloud-vision-v1p3beta1", ">= 0.12", "< 2.a"
end
