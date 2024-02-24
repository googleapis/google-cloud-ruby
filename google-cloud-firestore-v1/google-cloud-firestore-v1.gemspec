# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/firestore/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-firestore-v1"
  gem.version       = Google::Cloud::Firestore::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud Firestore is a NoSQL document database built for automatic scaling, high performance, and ease of application development. Note that google-cloud-firestore-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-firestore instead. See the readme for more details."
  gem.summary       = "Accesses the NoSQL document database built for automatic scaling, high performance, and ease of application development."
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
end
