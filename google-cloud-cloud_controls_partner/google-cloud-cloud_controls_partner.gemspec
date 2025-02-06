# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/cloud_controls_partner/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-cloud_controls_partner"
  gem.version       = Google::Cloud::CloudControlsPartner::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Provides insights about your customers and their Assured Workloads based on your Sovereign Controls by Partners offering."
  gem.summary       = "Provides insights about your customers and their Assured Workloads based on your Sovereign Controls by Partners offering."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-cloud-cloud_controls_partner-v1", ">= 0.0", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
