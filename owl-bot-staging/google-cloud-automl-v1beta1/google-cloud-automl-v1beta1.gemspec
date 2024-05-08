# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/automl/v1beta1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-automl-v1beta1"
  gem.version       = Google::Cloud::AutoML::V1beta1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "AutoML makes the power of machine learning available to you even if you have limited knowledge of machine learning. You can use AutoML to build on Google's machine learning capabilities to create your own custom machine learning models that are tailored to your business needs, and then integrate those models into your applications and web sites. Note that google-cloud-automl-v1beta1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-automl instead. See the readme for more details."
  gem.summary       = "Train high-quality custom machine learning models with minimum effort and machine learning expertise."
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
