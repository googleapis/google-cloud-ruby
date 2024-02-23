# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/automl/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-automl"
  gem.version       = Google::Cloud::AutoML::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "AutoML makes the power of machine learning available to you even if you have limited knowledge of machine learning. You can use AutoML to build on Google's machine learning capabilities to create your own custom machine learning models that are tailored to your business needs, and then integrate those models into your applications and web sites."
  gem.summary       = "API Client library for the Cloud AutoML API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts", "MIGRATING.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-automl-v1", ">= 0.9", "< 2.a"
  gem.add_dependency "google-cloud-automl-v1beta1", ">= 0.10", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
