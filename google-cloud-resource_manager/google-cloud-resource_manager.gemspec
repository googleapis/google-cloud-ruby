# -*- encoding: utf-8 -*-
require File.expand_path("../lib/google/cloud/resource_manager/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-resource_manager"
  gem.version       = Google::Cloud::ResourceManager::VERSION

  gem.authors       = ["Mike Moore", "Chris Smith"]
  gem.email         = ["mike@blowmage.com", "quartzmo@gmail.com"]
  gem.description   = "google-cloud-resource_manager is the official library for Google Cloud Resource Manager."
  gem.summary       = "API Client library for Google Cloud Resource Manager"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-resource_manager"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["OVERVIEW.md", "AUTHENTICATION.md", "LOGGING.md", "CONTRIBUTING.md", "TROUBLESHOOTING.md", "CHANGELOG.md", "CODE_OF_CONDUCT.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.0.0"

  gem.add_dependency "google-cloud-core", "~> 1.2"
  gem.add_dependency "google-api-client", "~> 0.23"
  gem.add_dependency "googleauth", ">= 0.6.2", "< 0.8.0"

  gem.add_development_dependency "minitest", "~> 5.10"
  gem.add_development_dependency "minitest-autotest", "~> 1.0"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "autotest-suffix", "~> 1.1"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "rubocop", "~> 0.59.2"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
  gem.add_development_dependency "yard-doctest", "~> 0.1.13"
end
