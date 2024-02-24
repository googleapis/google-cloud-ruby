# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/vpc_access/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-vpc_access"
  gem.version       = Google::Cloud::VpcAccess::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Serverless VPC Access enables you to connect from a serverless environment on Google Cloud (Cloud Run, Cloud Functions, or the App Engine standard environment) directly to your VPC network. This connection makes it possible for your serverless environment to access Compute Engine VM instances, Memorystore instances, and any other resources with an internal IP address."
  gem.summary       = "API Client library for the Serverless VPC Access API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-vpc_access-v1", ">= 0.7", "< 2.a"
end
