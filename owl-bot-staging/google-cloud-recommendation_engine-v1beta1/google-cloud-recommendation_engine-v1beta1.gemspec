# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/recommendation_engine/v1beta1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-recommendation_engine-v1beta1"
  gem.version       = Google::Cloud::RecommendationEngine::V1beta1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Recommendations AI enables you to build an end-to-end personalized recommendation system based on state-of-the-art deep learning ML models, without a need for expertise in ML or recommendation systems. Note that google-cloud-recommendation_engine-v1beta1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-recommendation_engine instead. See the readme for more details."
  gem.summary       = "Recommendations AI service enables customers to build end-to-end personalized recommendation systems without requiring a high level of expertise in machine learning, recommendation system, or Google Cloud."
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
