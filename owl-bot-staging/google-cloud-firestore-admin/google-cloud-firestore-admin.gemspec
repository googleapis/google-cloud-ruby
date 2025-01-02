# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/firestore/admin/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-firestore-admin"
  gem.version       = Google::Cloud::Firestore::Admin::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud Firestore is a NoSQL document database built for automatic scaling, high performance, and ease of application development."
  gem.summary       = "API Client library for the Cloud Firestore Admin API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-firestore-admin-v1", ">= 0.14", "< 2.a"
end
