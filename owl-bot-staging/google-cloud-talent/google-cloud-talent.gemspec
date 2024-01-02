# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/talent/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-talent"
  gem.version       = Google::Cloud::Talent::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Transform your job search and candidate matching capabilities with Cloud Talent Solution, designed to support enterprise talent acquisition technology and evolve with your growing needs. This AI solution includes features such as Job Search and Profile Search (Beta) to provide candidates and employers with an enhanced talent acquisition experience."
  gem.summary       = "API Client library for the Cloud Talent Solution API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts", "MIGRATING.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.6"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-talent-v4", ">= 0.9", "< 2.a"
  gem.add_dependency "google-cloud-talent-v4beta1", ">= 0.7", "< 2.a"

  gem.add_development_dependency "google-style", "~> 1.26.1"
  gem.add_development_dependency "minitest", "~> 5.16"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "rake", ">= 13.0"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
end
