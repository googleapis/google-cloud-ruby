# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/api_hub/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-api_hub"
  gem.version       = Google::Cloud::ApiHub::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "API hub lets you consolidate and organize information about all of the APIs of interest to your organization. API hub lets you capture critical information about APIs that allows developers to discover and evaluate them easily and leverage the work of other teams wherever possible. API platform teams can use API hub to have visibility into and manage their portfolio of APIs."
  gem.summary       = "API Client library for the API hub API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-cloud-api_hub-v1", ">= 0.0", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
