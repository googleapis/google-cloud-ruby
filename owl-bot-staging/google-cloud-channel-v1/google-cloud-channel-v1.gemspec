# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/channel/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-channel-v1"
  gem.version       = Google::Cloud::Channel::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "You can use Channel Services to manage your relationships with your partners and your customers. Channel Services include a console and APIs to view and provision links between distributors and resellers, customers and entitlements. Note that google-cloud-channel-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-channel instead. See the readme for more details."
  gem.summary       = "The Cloud Channel API enables Google Cloud partners to have a single unified resale platform and APIs across all of Google Cloud including GCP, Workspace, Maps and Chrome."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.6"

  gem.add_dependency "gapic-common", ">= 0.20.0", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"

  gem.add_development_dependency "google-style", "~> 1.26.3"
  gem.add_development_dependency "minitest", "~> 5.16"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "rake", ">= 13.0"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.18"
  gem.add_development_dependency "yard", "~> 0.9"
end
