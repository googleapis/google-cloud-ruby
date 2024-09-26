# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/shopping/merchant/accounts/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-shopping-merchant-accounts"
  gem.version       = Google::Shopping::Merchant::Accounts::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Merchant API consists of multiple Sub-APIs. Accounts Sub-API: Enables you to programmatically manage your accounts. Conversions Sub-API: Enables you to programmatically manage your conversion sources for a merchant account. Datasources Sub-API: Enables you to programmatically manage your datasources. Inventories Sub-API: This bundle enables you to programmatically manage your local and regional inventories. Local Feeds Partnerships Sub-API: This bundle enables LFP partners to submit local inventories for a merchant. Notifications Sub-API: This bundle enables you to programmatically manage your notification subscriptions. Products Sub-API: This bundle enables you to programmatically manage your products. Promotions Sub-API: This bundle enables you to programmatically manage your promotions for products. Quota Sub-API: This bundle enables you to list your quotas for all APIs you are using. Reports Sub-API: This bundle enables you to programmatically retrieve reports and insights about products, their performance and their competitive environment."
  gem.summary       = "Programmatically manage your Merchant Center Accounts."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-shopping-merchant-accounts-v1beta", ">= 0.0", "< 2.a"
end
