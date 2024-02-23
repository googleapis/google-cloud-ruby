# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/gke_connect/gateway/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-gke_connect-gateway"
  gem.version       = Google::Cloud::GkeConnect::Gateway::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Connect gateway builds on the power of fleets to let Anthos users connect to and run commands against registered Anthos clusters in a simple, consistent, and secured way, whether the clusters are on Google Cloud, other public clouds, or on premises, and makes it easier to automate DevOps processes across all your clusters."
  gem.summary       = "API Client library for the Connect Gateway API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-gke_connect-gateway-v1beta1", ">= 0.5", "< 2.a"
end
