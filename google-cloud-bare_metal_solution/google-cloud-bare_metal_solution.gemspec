# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/bare_metal_solution/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-bare_metal_solution"
  gem.version       = Google::Cloud::BareMetalSolution::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Provides ways to manage Bare Metal Solution hardware installed in a regional extension located near a Google Cloud data center."
  gem.summary       = "Provides ways to manage Bare Metal Solution hardware installed in a regional extension located near a Google Cloud data center."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-bare_metal_solution-v2", "~> 1.0"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
