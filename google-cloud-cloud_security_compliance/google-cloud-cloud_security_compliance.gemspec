# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/cloud_security_compliance/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-cloud_security_compliance"
  gem.version       = Google::Cloud::CloudSecurityCompliance::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Compliance Manager uses software-defined controls that let you assess support for multiple compliance programs and security requirements within a Google Cloud organization."
  gem.summary       = "Compliance Manager uses software-defined controls that let you assess support for multiple compliance programs and security requirements within a Google Cloud organization."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-cloud_security_compliance-v1", ">= 0.0", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
