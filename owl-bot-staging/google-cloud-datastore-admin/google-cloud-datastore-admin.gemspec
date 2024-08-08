# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/datastore/admin/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-datastore-admin"
  gem.version       = Google::Cloud::Datastore::Admin::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Firestore in Datastore mode is a NoSQL document database built for automatic scaling, high performance, and ease of application development."
  gem.summary       = "API Client library for the Firestore in Datastore mode Admin API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-datastore-admin-v1", ">= 0.11", "< 2.a"
end
