# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/privileged_access_manager/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-privileged_access_manager"
  gem.version       = Google::Cloud::PrivilegedAccessManager::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Privileged Access Manager (PAM) helps you on your journey towards least privilege and helps mitigate risks tied to privileged access misuse or abuse. PAM allows you to shift from always-on standing privileges towards on-demand access with just-in-time, time-bound, and approval-based access elevations. PAM allows IAM administrators to create entitlements that can grant just-in-time, temporary access to any resource scope. Requesters can explore eligible entitlements and request the access needed for their task. Approvers are notified when approvals await their decision. Streamlined workflows facilitated by using PAM can support various use cases, including emergency access for incident responders, time-boxed access for developers for critical deployment or maintenance, temporary access for operators for data ingestion and audits, JIT access to service accounts for automated tasks, and more."
  gem.summary       = "Privileged Access Manager (PAM) helps you on your journey towards least privilege and helps mitigate risks tied to privileged access misuse or abuse. PAM allows you to shift from always-on standing privileges towards on-demand access with just-in-time, time-bound, and approval-based access elevations. PAM allows IAM administrators to create entitlements that can grant just-in-time, temporary access to any resource scope. Requesters can explore eligible entitlements and request the access needed for their task. Approvers are notified when approvals await their decision. Streamlined workflows facilitated by using PAM can support various use cases, including emergency access for incident responders, time-boxed access for developers for critical deployment or maintenance, temporary access for operators for data ingestion and audits, JIT access to service accounts for automated tasks, and more."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-privileged_access_manager-v1", "~> 1.0"
end
