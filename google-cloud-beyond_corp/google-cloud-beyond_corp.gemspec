# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/beyond_corp/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-beyond_corp"
  gem.version       = Google::Cloud::BeyondCorp::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Beyondcorp Enterprise provides identity and context aware access controls for enterprise resources and enables zero-trust access. Using the Beyondcorp Enterprise APIs, enterprises can set up multi-cloud and on-prem connectivity using the App Connector hybrid connectivity solution."
  gem.summary       = "API client library for the BeyondCorp API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.6"

  gem.add_dependency "google-cloud-beyond_corp-app_connections-v1", ">= 0.0", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-beyond_corp-app_connectors-v1", ">= 0.0", "< 2.a"
  gem.add_dependency "google-cloud-beyond_corp-app_gateways-v1", ">= 0.0", "< 2.a"
  gem.add_dependency "google-cloud-beyond_corp-client_connector_services-v1", ">= 0.0", "< 2.a"
  gem.add_dependency "google-cloud-beyond_corp-client_gateways-v1", ">= 0.0", "< 2.a"

  gem.add_development_dependency "google-style", "~> 1.26.1"
  gem.add_development_dependency "minitest", "~> 5.16"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "rake", ">= 13.0"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
end
