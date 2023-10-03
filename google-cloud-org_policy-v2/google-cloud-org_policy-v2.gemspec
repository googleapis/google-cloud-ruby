# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/org_policy/v2/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-org_policy-v2"
  gem.version       = Google::Cloud::OrgPolicy::V2::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Cloud Org Policy service provides a simple mechanism for organizations to restrict the allowed configurations across their entire Cloud Resource hierarchy. Note that google-cloud-org_policy-v2 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-org_policy instead. See the readme for more details."
  gem.summary       = "The Organization Policy API allows users to configure governance rules on their Google Cloud resources across the resource hierarchy."
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
