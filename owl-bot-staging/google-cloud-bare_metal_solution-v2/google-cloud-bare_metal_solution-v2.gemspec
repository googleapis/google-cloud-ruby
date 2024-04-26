# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/bare_metal_solution/v2/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-bare_metal_solution-v2"
  gem.version       = Google::Cloud::BareMetalSolution::V2::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Bare Metal Solution is a managed solution that provides purpose-built HPE or Atos bare-metal servers in regional extensions that are connected to Google Cloud by a managed, high-performance connection with a low-latency network fabric. Note that google-cloud-bare_metal_solution-v2 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-bare_metal_solution instead. See the readme for more details."
  gem.summary       = "Provides ways to manage Bare Metal Solution hardware installed in a regional extension located near a Google Cloud data center."
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
