# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/vmware_engine/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-vmware_engine-v1"
  gem.version       = Google::Cloud::VmwareEngine::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Google Cloud VMware Engine is a fully managed service that lets you run the VMware platform in Google Cloud. VMware Engine provides you with VMware operational continuity so you can benefit from a cloud consumption model and lower your total cost of ownership. VMware Engine also offers on-demand provisioning, pay-as-you-grow, and capacity optimization. Note that google-cloud-vmware_engine-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-vmware_engine instead. See the readme for more details."
  gem.summary       = "The Google VMware Engine API lets you programmatically manage VMware environments."
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
  gem.add_dependency "google-iam-v1", ">= 0.7", "< 2.a"
end
