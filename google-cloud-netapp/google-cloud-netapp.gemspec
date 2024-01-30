# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/netapp/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-netapp"
  gem.version       = Google::Cloud::NetApp::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Google Cloud NetApp Volumes is a fully-managed, cloud-based data storage service that provides advanced data management capabilities and highly scalable performance with global availability."
  gem.summary       = "Google Cloud NetApp Volumes is a fully-managed, cloud-based data storage service that provides advanced data management capabilities and highly scalable performance with global availability."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.6"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-netapp-v1", ">= 0.4", "< 2.a"

  gem.add_development_dependency "google-style", "~> 1.26.1"
  gem.add_development_dependency "minitest", "~> 5.16"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "rake", ">= 13.0"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
end
