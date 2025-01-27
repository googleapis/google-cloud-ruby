# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/ads/ad_manager/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-ads-ad_manager"
  gem.version       = Google::Ads::AdManager::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Ad Manager API enables an app to integrate with Google Ad Manager. You can read Ad Manager data and run reports using the API."
  gem.summary       = "Manage your Ad Manager inventory, run reports and more."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-ads-ad_manager-v1", ">= 0.0", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
