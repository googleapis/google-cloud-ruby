# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/compute/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-compute"
  gem.version       = Google::Cloud::Compute::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Compute Engine is an infrastructure as a service (IaaS) product that offers self-managed virtual machine (VM) instances and bare metal instances."
  gem.summary       = "Compute Engine is an infrastructure as a service (IaaS) product that offers self-managed virtual machine (VM) instances and bare metal instances."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-compute-v1", "~> 2.15"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
