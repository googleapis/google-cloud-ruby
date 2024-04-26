# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/beyond_corp/app_connectors/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-beyond_corp-app_connectors"
  gem.version       = Google::Cloud::BeyondCorp::AppConnectors::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Beyondcorp Enterprise provides identity and context aware access controls for enterprise resources and enables zero-trust access. Using the Beyondcorp Enterprise APIs, enterprises can set up multi-cloud and on-prem connectivity using the App Connector hybrid connectivity solution."
  gem.summary       = "API Client library for the BeyondCorp AppConnectors API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-beyond_corp-app_connectors-v1", ">= 0.4", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
