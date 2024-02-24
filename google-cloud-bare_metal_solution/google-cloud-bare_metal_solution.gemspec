# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/bare_metal_solution/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-bare_metal_solution"
  gem.version       = Google::Cloud::BareMetalSolution::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Bare Metal Solution is a managed solution that provides purpose-built HPE or Atos bare-metal servers in regional extensions that are connected to Google Cloud by a managed, high-performance connection with a low-latency network fabric."
  gem.summary       = "API Client library for the Bare Metal Solution API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-bare_metal_solution-v2", ">= 0.7", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
