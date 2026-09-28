# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/private_catalog/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-private_catalog"
  gem.version       = Google::Cloud::PrivateCatalog::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Enable cloud users to discover private catalogs and products in their organizations."
  gem.summary       = "Enable cloud users to discover private catalogs and products in their organizations."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-private_catalog-v1beta1", ">= 0.6", "< 2.a"
end
