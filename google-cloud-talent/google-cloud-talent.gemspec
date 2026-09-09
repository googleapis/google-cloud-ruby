# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/talent/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-talent"
  gem.version       = Google::Cloud::Talent::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud Talent Solution provides the capability to create, read, update, and delete job postings, as well as search jobs based on keywords and filters."
  gem.summary       = "Cloud Talent Solution provides the capability to create, read, update, and delete job postings, as well as search jobs based on keywords and filters."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-talent-v4", "~> 1.3"
end
