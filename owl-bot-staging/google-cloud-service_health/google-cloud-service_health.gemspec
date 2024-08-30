# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/service_health/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-service_health"
  gem.version       = Google::Cloud::ServiceHealth::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Personalized Service Health helps you gain visibility into disruptive events impacting Google Cloud products."
  gem.summary       = "Personalized Service Health helps you gain visibility into disruptive events impacting Google Cloud products."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-service_health-v1", ">= 0.0", "< 2.a"
end
