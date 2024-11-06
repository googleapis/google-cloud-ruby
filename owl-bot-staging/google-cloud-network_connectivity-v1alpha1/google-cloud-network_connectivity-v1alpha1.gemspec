# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/network_connectivity/v1alpha1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-network_connectivity-v1alpha1"
  gem.version       = Google::Cloud::NetworkConnectivity::V1alpha1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Network Connectivity is Google's suite of products that provide enterprise connectivity from your on-premises network or from another cloud provider to your Virtual Private Cloud (VPC) network. Note that google-cloud-network_connectivity-v1alpha1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-network_connectivity instead. See the readme for more details."
  gem.summary       = "The Network Connectivity API will be home to various services which provide information pertaining to network connectivity."
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
