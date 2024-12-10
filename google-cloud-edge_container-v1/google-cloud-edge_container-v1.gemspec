# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/edge_container/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-edge_container-v1"
  gem.version       = Google::Cloud::EdgeContainer::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "google-cloud-edge_container-v1 is the official client library for the Distributed Cloud Edge Container V1 API. Note that google-cloud-edge_container-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-edge_container instead. See the readme for more details."
  gem.summary       = "API Client library for the Distributed Cloud Edge Container V1 API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "gapic-common", ">= 0.24.0", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
  gem.add_dependency "google-cloud-location", ">= 0.7", "< 2.a"
end
