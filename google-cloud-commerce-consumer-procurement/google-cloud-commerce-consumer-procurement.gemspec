# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/commerce/consumer/procurement/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-commerce-consumer-procurement"
  gem.version       = Google::Cloud::Commerce::Consumer::Procurement::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Enables consumers to procure products served by Cloud Marketplace platform."
  gem.summary       = "Enables consumers to procure products served by Cloud Marketplace platform."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-commerce-consumer-procurement-v1", ">= 0.3", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
