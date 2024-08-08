# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/recaptcha_enterprise/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-recaptcha_enterprise"
  gem.version       = Google::Cloud::RecaptchaEnterprise::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "reCAPTCHA Enterprise is a service that protects your site from spam and abuse."
  gem.summary       = "API Client library for the reCAPTCHA Enterprise API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts", "MIGRATING.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-recaptcha_enterprise-v1", ">= 0.17", "< 2.a"
  gem.add_dependency "google-cloud-recaptcha_enterprise-v1beta1", ">= 0.12", "< 2.a"
end
