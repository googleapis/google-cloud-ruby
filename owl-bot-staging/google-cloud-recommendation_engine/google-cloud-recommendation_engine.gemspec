# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/recommendation_engine/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-recommendation_engine"
  gem.version       = Google::Cloud::RecommendationEngine::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Recommendations AI enables you to build an end-to-end personalized recommendation system based on state-of-the-art deep learning ML models, without a need for expertise in ML or recommendation systems."
  gem.summary       = "API Client library for the Recommendations AI API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-recommendation_engine-v1beta1", ">= 0.8", "< 2.a"
end
