# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/commerce_producer/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-commerce_producer"
  gem.version       = Google::Cloud::CommerceProducer::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Using this API, partners can: * Manage private offers extended to specific customer billing accounts. * Attach documents to private offers, such as custom EULAs or Statements of Work. * Publish private offers to make them available to customers. # Data Model The following resources are exposed by this API: * **Service**: Represents a service offered by a partner on Google Cloud Marketplace. * **StandardOffer**: Represents a standard offer for a product, which can be used as a base for private offers. * **PrivateOffer**: Represents a customized offer extended to a specific customer billing account. * **PrivateOfferDocument**: Represents a document attached to a private offer. * **SkuGroup**: Represents a group of SKUs (Stock Keeping Units) used for pricing or commitment. * **Sku**: Represents a SKU (Stock Keeping Unit) used for pricing or commitment."
  gem.summary       = "Partner API for the Cloud Commerce Producer API Early Access."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-commerce_producer-v1beta", ">= 0.0", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
