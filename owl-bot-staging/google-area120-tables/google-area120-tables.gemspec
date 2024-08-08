# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/area120/tables/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-area120-tables"
  gem.version       = Google::Area120::Tables::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Using the Area 120 Tables API, you can query for tables, and update/create/delete rows within tables programmatically."
  gem.summary       = "API Client library for the Area 120 Tables API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-area120-tables-v1alpha1", ">= 0.7", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
