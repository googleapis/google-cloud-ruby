# -*- encoding: utf-8 -*-
require File.expand_path("../lib/google/cloud/pubsub/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-pubsub"
  gem.version       = Google::Cloud::Pubsub::VERSION

  gem.authors       = ["Mike Moore", "Chris Smith"]
  gem.email         = ["mike@blowmage.com", "quartzmo@gmail.com"]
  gem.description   = "google-cloud-pubsub is the official library for Google Cloud Pub/Sub."
  gem.summary       = "API Client library for Google Cloud Pub/Sub"
  gem.homepage      = "http://googlecloudplatform.github.io/google-cloud-ruby/"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files -- lib/*`.split("\n")
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.0.0"

  gem.add_dependency "google-cloud-core", "~> 0.21.0"
  gem.add_dependency "grpc", "~> 1.0"
  gem.add_dependency "google-protobuf", "~> 3.0"
  gem.add_dependency "googleapis-common-protos", "~> 1.3"
  gem.add_dependency "grpc-google-iam-v1", "~> 0.6.8"
  gem.add_dependency "google-gax", "~> 0.6.0"

  gem.add_development_dependency "minitest", "~> 5.9"
  gem.add_development_dependency "minitest-autotest", "~> 1.0"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "autotest-suffix", "~> 1.1"
  gem.add_development_dependency "rubocop", "<= 0.35.1"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
  gem.add_development_dependency "yard-doctest", "= 0.1.7"
end
