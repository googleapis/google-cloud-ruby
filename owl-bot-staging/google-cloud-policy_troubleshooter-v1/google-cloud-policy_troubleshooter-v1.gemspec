# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/policy_troubleshooter/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-policy_troubleshooter-v1"
  gem.version       = Google::Cloud::PolicyTroubleshooter::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Policy Troubleshooter makes it easier to understand why a user has access to a resource or doesn't have permission to call an API. Given an email, resource, and permission, Policy Troubleshooter will examine all IAM policies that apply to the resource. It then reveals whether the member's roles include the permission on that resource and, if so, which policies bind the member to those roles. Note that google-cloud-policy_troubleshooter-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-policy_troubleshooter instead. See the readme for more details."
  gem.summary       = "API Client library for the IAM Policy Troubleshooter V1 API"
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
  gem.add_dependency "grpc-google-iam-v1", "~> 1.1"
end
