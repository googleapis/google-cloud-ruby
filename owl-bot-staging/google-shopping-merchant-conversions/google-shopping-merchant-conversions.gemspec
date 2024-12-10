# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/shopping/merchant/conversions/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-shopping-merchant-conversions"
  gem.version       = Google::Shopping::Merchant::Conversions::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Programmatically manage your Merchant Center accounts."
  gem.summary       = "Programmatically manage your Merchant Center accounts."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-shopping-merchant-conversions-v1beta", ">= 0.0", "< 2.a"
end
