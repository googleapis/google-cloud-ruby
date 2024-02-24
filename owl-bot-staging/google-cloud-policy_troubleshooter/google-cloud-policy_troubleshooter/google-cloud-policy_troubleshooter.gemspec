# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/policy_troubleshooter/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-policy_troubleshooter"
  gem.version       = Google::Cloud::PolicyTroubleshooter::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Policy Troubleshooter makes it easier to understand why a user has access to a resource or doesn't have permission to call an API. Given an email, resource, and permission, Policy Troubleshooter will examine all IAM policies that apply to the resource. It then reveals whether the member's roles include the permission on that resource and, if so, which policies bind the member to those roles."
  gem.summary       = "API Client library for the IAM Policy Troubleshooter API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-policy_troubleshooter-v1", ">= 0.10", "< 2.a"
end
