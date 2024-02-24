# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/storage_insights/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-storage_insights"
  gem.version       = Google::Cloud::StorageInsights::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Provides insights capability on Google Cloud Storage."
  gem.summary       = "Provides insights capability on Google Cloud Storage."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-storage_insights-v1", ">= 0.4", "< 2.a"
end
