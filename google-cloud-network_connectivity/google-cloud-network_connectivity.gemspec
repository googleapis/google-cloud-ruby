# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/network_connectivity/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-network_connectivity"
  gem.version       = Google::Cloud::NetworkConnectivity::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "This API enables connectivity with and between Google Cloud resources."
  gem.summary       = "This API enables connectivity with and between Google Cloud resources."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-network_connectivity-v1", "~> 1.3"
end
