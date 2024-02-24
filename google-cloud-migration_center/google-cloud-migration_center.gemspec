# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/migration_center/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-migration_center"
  gem.version       = Google::Cloud::MigrationCenter::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "A unified platform that helps you accelerate your end-to-end cloud journey from your current on-premises or cloud environments to Google Cloud."
  gem.summary       = "A unified platform that helps you accelerate your end-to-end cloud journey from your current on-premises or cloud environments to Google Cloud."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-migration_center-v1", ">= 0.2", "< 2.a"
end
