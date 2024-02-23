# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/gke_connect/gateway/v1beta1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-gke_connect-gateway-v1beta1"
  gem.version       = Google::Cloud::GkeConnect::Gateway::V1beta1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Connect gateway builds on the power of fleets to let Anthos users connect to and run commands against registered Anthos clusters in a simple, consistent, and secured way, whether the clusters are on Google Cloud, other public clouds, or on premises, and makes it easier to automate DevOps processes across all your clusters. Note that google-cloud-gke_connect-gateway-v1beta1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-gke_connect-gateway instead. See the readme for more details."
  gem.summary       = "The Connect Gateway service allows connectivity from external parties to connected Kubernetes clusters."
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
