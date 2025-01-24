# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/shopping/merchant/products/v1beta/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-shopping-merchant-products-v1beta"
  gem.version       = Google::Shopping::Merchant::Products::V1beta::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Merchant API consists of multiple Sub-APIs. Accounts Sub-API: Enables you to programmatically manage your accounts. Conversions Sub-API: Enables you to programmatically manage your conversion sources for a merchant account. Datasources Sub-API: Enables you to programmatically manage your datasources. Inventories Sub-API: This bundle enables you to programmatically manage your local and regional inventories. Local Feeds Partnerships Sub-API: This bundle enables LFP partners to submit local inventories for a merchant. Notifications Sub-API: This bundle enables you to programmatically manage your notification subscriptions. Products Sub-API: This bundle enables you to programmatically manage your products. Promotions Sub-API: This bundle enables you to programmatically manage your promotions for products. Quota Sub-API: This bundle enables you to list your quotas for all APIs you are using. Reports Sub-API: This bundle enables you to programmatically retrieve reports and insights about products, their performance and their competitive environment. Note that google-shopping-merchant-products-v1beta is a version-specific client library. For most uses, we recommend installing the main client library google-shopping-merchant-products instead. See the readme for more details."
  gem.summary       = "Programmatically manage your Merchant Center Accounts."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "gapic-common", ">= 0.25.0", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
  gem.add_dependency "google-shopping-type", "> 0.0", "< 2.a"
end
