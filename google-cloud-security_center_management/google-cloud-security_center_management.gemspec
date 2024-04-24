# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/security_center_management/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-security_center_management"
  gem.version       = Google::Cloud::SecurityCenterManagement::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Management API for Security Command Center, a built-in security and risk management solution for Google Cloud. Use this API to programmatically update the settings and configuration of Security Command Center."
  gem.summary       = "Management API for Security Command Center, a built-in security and risk management solution for Google Cloud. Use this API to programmatically update the settings and configuration of Security Command Center."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-security_center_management-v1", ">= 0.0", "< 2.a"
end
