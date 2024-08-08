# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/workstations/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-workstations"
  gem.version       = Google::Cloud::Workstations::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Allows administrators to create managed developer environments in the cloud."
  gem.summary       = "Allows administrators to create managed developer environments in the cloud."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-workstations-v1", ">= 0.0", "< 2.a"
  gem.add_dependency "google-cloud-workstations-v1beta", ">= 0.0", "< 2.a"
end
