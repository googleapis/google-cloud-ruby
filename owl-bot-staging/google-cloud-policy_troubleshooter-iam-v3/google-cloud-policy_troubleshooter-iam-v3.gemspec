# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/policy_troubleshooter/iam/v3/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-policy_troubleshooter-iam-v3"
  gem.version       = Google::Cloud::PolicyTroubleshooter::Iam::V3::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "google-cloud-policy_troubleshooter-iam-v3 is the official client library for the Policy Troubleshooter V3 API. Note that google-cloud-policy_troubleshooter-iam-v3 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-policy_troubleshooter-iam instead. See the readme for more details."
  gem.summary       = "API Client library for the Policy Troubleshooter V3 API"
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
  gem.add_dependency "google-iam-v1", "> 0.5", "< 2.a"
  gem.add_dependency "google-iam-v2", "> 0.3", "< 2.a"
end
