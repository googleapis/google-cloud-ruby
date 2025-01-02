# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/resource_settings/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-resource_settings"
  gem.version       = Google::Cloud::ResourceSettings::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "You can use Resource Settings to centrally configure settings for your Google Cloud projects, folders, and organization. These settings are inherited by their descendants in the resource hierarchy. Each setting is created and managed by Google."
  gem.summary       = "API Client library for the Resource Settings API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-resource_settings-v1", ">= 0.6", "< 2.a"
end
