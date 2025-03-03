# -*- encoding: utf-8 -*-
require File.expand_path("../lib/google/cloud/datastore/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-datastore"
  gem.version       = Google::Cloud::Datastore::VERSION

  gem.authors       = ["Mike Moore", "Chris Smith"]
  gem.email         = ["mike@blowmage.com", "quartzmo@gmail.com"]
  gem.description   = "google-cloud-datastore is the official library for Google Cloud Datastore."
  gem.summary       = "API Client library for Google Cloud Datastore"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-datastore"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["OVERVIEW.md", "AUTHENTICATION.md", "EMULATOR.md", "LOGGING.md", "CONTRIBUTING.md", "TROUBLESHOOTING.md", "CHANGELOG.md", "CODE_OF_CONDUCT.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-cloud-core", "~> 1.5"
  gem.add_dependency "google-cloud-datastore-v1", ">= 0.0", "< 2.a"
end
