# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/developer_connect/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-developer_connect-v1"
  gem.version       = Google::Cloud::DeveloperConnect::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Developer Connect streamlines integration with third-party source code management platforms by simplifying authentication, authorization, and networking configuration. Note that google-cloud-developer_connect-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-developer_connect instead. See the readme for more details."
  gem.summary       = "Connect third-party source code management to Google."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "gapic-common", ">= 0.25.0", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
  gem.add_dependency "google-cloud-location", ">= 0.7", "< 2.a"
end
