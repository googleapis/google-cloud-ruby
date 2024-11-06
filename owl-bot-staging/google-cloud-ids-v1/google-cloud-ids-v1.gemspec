# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/ids/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-ids-v1"
  gem.version       = Google::Cloud::IDS::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud IDS is an intrusion detection service that provides threat detection for intrusions, malware, spyware, and command-and-control attacks on your network. Cloud IDS works by creating a Google-managed peered network with mirrored VMs. Traffic in the peered network is mirrored, and then inspected by Palo Alto Networks threat protection technologies to provide advanced threat detection. You can mirror all traffic or you can mirror filtered traffic, based on protocol, IP address range, or ingress and egress. Note that google-cloud-ids-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-ids instead. See the readme for more details."
  gem.summary       = "Cloud IDS (Cloud Intrusion Detection System) detects malware, spyware, command-and-control attacks, and other network-based threats. Its security efficacy is industry leading, built with Palo Alto Networks technologies. When you use this product, your organization name and consumption levels will be shared with Palo Alto Networks."
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
end
