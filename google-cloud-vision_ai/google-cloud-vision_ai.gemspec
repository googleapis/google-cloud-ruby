# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/vision_ai/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-vision_ai"
  gem.version       = Google::Cloud::VisionAI::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Vertex AI Vision is an AI-powered platform to ingest, analyze and store video data."
  gem.summary       = "Vertex AI Vision is an AI-powered platform to ingest, analyze and store video data."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-vision_ai-v1", "~> 1.0"
end
