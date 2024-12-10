# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/api_hub/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-api_hub-v1"
  gem.version       = Google::Cloud::ApiHub::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "API hub lets you consolidate and organize information about all of the APIs of interest to your organization. API hub lets you capture critical information about APIs that allows developers to discover and evaluate them easily and leverage the work of other teams wherever possible. API platform teams can use API hub to have visibility into and manage their portfolio of APIs. Note that google-cloud-api_hub-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-api_hub instead. See the readme for more details."
  gem.summary       = "API Client library for the API hub V1 API"
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
