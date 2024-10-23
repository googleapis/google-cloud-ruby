# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/area120/tables/v1alpha1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-area120-tables-v1alpha1"
  gem.version       = Google::Area120::Tables::V1alpha1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Using the Area 120 Tables API, you can query for tables, and update/create/delete rows within tables programmatically. Note that google-area120-tables-v1alpha1 is a version-specific client library. For most uses, we recommend installing the main client library google-area120-tables instead. See the readme for more details."
  gem.summary       = "API Client library for the Area 120 Tables V1alpha1 API"
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
end
