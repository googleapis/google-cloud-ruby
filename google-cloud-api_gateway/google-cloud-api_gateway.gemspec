# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/api_gateway/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-api_gateway"
  gem.version       = Google::Cloud::ApiGateway::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "API Gateway enables you to provide secure access to your backend services through a well-defined REST API that is consistent across all of your services, regardless of the service implementation. Clients consume your REST APIS to implement standalone apps for a mobile device or tablet, through apps running in a browser, or through any other type of app that can make a request to an HTTP endpoint."
  gem.summary       = "API Client library for the API Gateway API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-api_gateway-v1", ">= 0.6", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
