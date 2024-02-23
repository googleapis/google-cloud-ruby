# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/commerce/consumer/procurement/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-commerce-consumer-procurement-v1"
  gem.version       = Google::Cloud::Commerce::Consumer::Procurement::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Enables consumers to procure products served by Cloud Marketplace platform. Note that google-cloud-commerce-consumer-procurement-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-commerce-consumer-procurement instead. See the readme for more details."
  gem.summary       = "Enables consumers to procure products served by Cloud Marketplace platform."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "gapic-common", ">= 0.21.1", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
end
