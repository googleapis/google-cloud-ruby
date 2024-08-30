# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/privileged_access_manager/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-privileged_access_manager-v1"
  gem.version       = Google::Cloud::PrivilegedAccessManager::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "## Overview Privileged Access Manager (PAM) is a Google Cloud native, managed solution to secure, manage and audit privileged access while ensuring operational velocity and developer productivity. PAM enables just-in-time, time-bound, approval-based access elevations, and auditing of privileged access elevations and activity. PAM lets you define the rules of who can request access, what they can request access to, and if they should be granted access with or without approvals based on the sensitivity of the access and emergency of the situation. ## Concepts ### Entitlement An entitlement is an eligibility or license that allows specified users (requesters) to request and obtain access to specified resources subject to a set of conditions such as duration, etc. entitlements can be granted to both human and non-human principals. ### Grant A grant is an instance of active usage against the entitlement. A user can place a request for a grant against an entitlement. The request may be forwarded to an approver for their decision. Once approved, the grant is activated, ultimately giving the user access (roles/permissions) on a resource per the criteria specified in entitlement. ### How does PAM work PAM creates and uses a service agent (Google-managed service account) to perform the required IAM policy changes for granting access at a specific resource/access scope. The service agent requires getIAMPolicy and setIAMPolicy permissions at the appropriate (or higher) access scope - Organization/Folder/Project to make policy changes on the resources listed in PAM entitlements. When enabling PAM for a resource scope, the user/ principal performing that action should have the appropriate permissions at that resource scope (resourcemanager.{projects|folders|organizations}.setIamPolicy, resourcemanager.{projects|folders|organizations}.getIamPolicy, and resourcemanager.{projects|folders|organizations}.get) to list and grant the service agent/account the required access to perform IAM policy changes. Note that google-cloud-privileged_access_manager-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-privileged_access_manager instead. See the readme for more details."
  gem.summary       = "Privileged Access Manager (PAM) helps you on your journey towards least privilege and helps mitigate risks tied to privileged access misuse or abuse. PAM allows you to shift from always-on standing privileges towards on-demand access with just-in-time, time-bound, and approval-based access elevations. PAM allows IAM administrators to create entitlements that can grant just-in-time, temporary access to any resource scope. Requesters can explore eligible entitlements and request the access needed for their task. Approvers are notified when approvals await their decision. Streamlined workflows facilitated by using PAM can support various use cases, including emergency access for incident responders, time-boxed access for developers for critical deployment or maintenance, temporary access for operators for data ingestion and audits, JIT access to service accounts for automated tasks, and more."
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
  gem.add_dependency "google-cloud-location", ">= 0.7", "< 2.a"
end
