# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/service_directory/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-service_directory"
  gem.version       = Google::Cloud::ServiceDirectory::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Service Directory is the single place to register, browse, and resolve application services."
  gem.summary       = "API Client library for the Service Directory API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-service_directory-v1", ">= 0.10", "< 2.a"
  gem.add_dependency "google-cloud-service_directory-v1beta1", ">= 0.14", "< 2.a"
end
