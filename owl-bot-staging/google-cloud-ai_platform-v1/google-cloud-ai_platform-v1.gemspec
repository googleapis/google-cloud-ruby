# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/ai_platform/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-ai_platform-v1"
  gem.version       = Google::Cloud::AIPlatform::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Vertex AI enables data scientists, developers, and AI newcomers to create custom machine learning models specific to their business needs by leveraging Google's state-of-the-art transfer learning and innovative AI research. Note that google-cloud-ai_platform-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-ai_platform instead. See the readme for more details."
  gem.summary       = "Train high-quality custom machine learning models with minimal machine learning expertise and effort."
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
  gem.add_dependency "google-cloud-location", ">= 0.7", "< 2.a"
  gem.add_dependency "google-iam-v1", ">= 0.7", "< 2.a"
end
