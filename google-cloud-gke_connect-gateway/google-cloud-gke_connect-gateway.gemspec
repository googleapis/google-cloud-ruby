# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/gke_connect/gateway/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-gke_connect-gateway"
  gem.version       = Google::Cloud::GkeConnect::Gateway::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Connect Gateway service allows connectivity from external parties to connected Kubernetes clusters."
  gem.summary       = "The Connect Gateway service allows connectivity from external parties to connected Kubernetes clusters."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-gke_connect-gateway-v1", ">= 0.2", "< 2.a"
end
