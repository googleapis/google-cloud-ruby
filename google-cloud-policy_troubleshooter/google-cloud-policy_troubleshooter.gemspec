# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/policy_troubleshooter/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-policy_troubleshooter"
  gem.version       = Google::Cloud::PolicyTroubleshooter::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Policy Troubleshooter helps you understand whether a principal can access a resource. Given a principal, a resource, and a permission, Policy Troubleshooter examines the allow policies, deny policies, and principal access boundary (PAB) policies that impact the principal's access."
  gem.summary       = "Policy Troubleshooter helps you understand whether a principal can access a resource. Given a principal, a resource, and a permission, Policy Troubleshooter examines the allow policies, deny policies, and principal access boundary (PAB) policies that impact the principal's access."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-policy_troubleshooter-v1", ">= 0.10", "< 2.a"
  gem.add_dependency "google-cloud-policy_troubleshooter-iam-v3", ">= 0.3", "< 2.a"
end
