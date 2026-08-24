# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/essential_contacts/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-essential_contacts"
  gem.version       = Google::Cloud::EssentialContacts::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Essential Contacts helps you direct critical Google Cloud notifications to the appropriate personnel across your projects, folders, and organization resources."
  gem.summary       = "Essential Contacts helps you direct critical Google Cloud notifications to the appropriate personnel across your projects, folders, and organization resources."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-essential_contacts-v1", ">= 0.6", "< 2.a"
end
