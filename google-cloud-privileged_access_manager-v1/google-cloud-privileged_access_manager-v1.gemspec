# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/privileged_access_manager/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-privileged_access_manager-v1"
  gem.version       = Google::Cloud::PrivilegedAccessManager::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Privileged Access Manager (PAM) helps you on your journey towards least privilege and helps mitigate risks tied to privileged access misuse or abuse. PAM allows you to shift from always-on standing privileges towards on-demand access with just-in-time, time-bound, and approval-based access elevations. PAM allows IAM administrators to create entitlements that can grant just-in-time, temporary access to any resource scope. Requesters can explore eligible entitlements and request the access needed for their task. Approvers are notified when approvals await their decision. Streamlined workflows facilitated by using PAM can support various use cases, including emergency access for incident responders, time-boxed access for developers for critical deployment or maintenance, temporary access for operators for data ingestion and audits, JIT access to service accounts for automated tasks, and more. Note that google-cloud-privileged_access_manager-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-privileged_access_manager instead. See the readme for more details."
  gem.summary       = "Privileged Access Manager (PAM) helps you on your journey towards least privilege and helps mitigate risks tied to privileged access misuse or abuse. PAM allows you to shift from always-on standing privileges towards on-demand access with just-in-time, time-bound, and approval-based access elevations. PAM allows IAM administrators to create entitlements that can grant just-in-time, temporary access to any resource scope. Requesters can explore eligible entitlements and request the access needed for their task. Approvers are notified when approvals await their decision. Streamlined workflows facilitated by using PAM can support various use cases, including emergency access for incident responders, time-boxed access for developers for critical deployment or maintenance, temporary access for operators for data ingestion and audits, JIT access to service accounts for automated tasks, and more."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "gapic-common", "~> 1.3"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
  gem.add_dependency "google-cloud-location", "~> 1.0"
end
