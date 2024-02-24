# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/ai_platform/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-ai_platform"
  gem.version       = Google::Cloud::AIPlatform::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Vertex AI enables data scientists, developers, and AI newcomers to create custom machine learning models specific to their business needs by leveraging Google's state-of-the-art transfer learning and innovative AI research."
  gem.summary       = "API Client library for the Vertex AI API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-ai_platform-v1", ">= 0.36", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
