# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/security/public_ca/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-security-public_ca"
  gem.version       = Google::Cloud::Security::PublicCA::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Certificate Manager's Public Certificate Authority (CA) functionality allows you to provision and deploy widely trusted X.509 certificates after validating that the certificate requester controls the domains. Certificate Manager lets you directly and programmatically request publicly trusted TLS certificates that are already in the root of trust stores used by major browsers, operating systems, and applications. You can use these TLS certificates to authenticate and encrypt internet traffic."
  gem.summary       = "API Client library for the Public Certificate Authority API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-security-public_ca-v1beta1", ">= 0.5", "< 2.a"
end
