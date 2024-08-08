# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/private_catalog/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-private_catalog"
  gem.version       = Google::Cloud::PrivateCatalog::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "With Private Catalog, developers and cloud admins can make their solutions discoverable to their internal enterprise users. Cloud admins can manage their solutions and ensure their users are always launching the latest versions."
  gem.summary       = "API Client library for the Private Catalog API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-private_catalog-v1beta1", ">= 0.6", "< 2.a"
end
