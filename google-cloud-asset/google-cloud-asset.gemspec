# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/asset/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-asset"
  gem.version       = Google::Cloud::Asset::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Cloud Asset API manages the history and inventory of Google Cloud resources."
  gem.summary       = "The Cloud Asset API manages the history and inventory of Google Cloud resources."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts", "MIGRATING.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-asset-v1", ">= 0.29", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
