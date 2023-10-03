# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/security/public_ca/v1beta1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-security-public_ca-v1beta1"
  gem.version       = Google::Cloud::Security::PublicCA::V1beta1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Certificate Manager's Public Certificate Authority (CA) functionality allows you to provision and deploy widely trusted X.509 certificates after validating that the certificate requester controls the domains. Certificate Manager lets you directly and programmatically request publicly trusted TLS certificates that are already in the root of trust stores used by major browsers, operating systems, and applications. You can use these TLS certificates to authenticate and encrypt internet traffic. Note that google-cloud-security-public_ca-v1beta1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-security-public_ca instead. See the readme for more details."
  gem.summary       = "The Public Certificate Authority API may be used to create and manage ACME external account binding keys associated with Google Trust Services' publicly trusted certificate authority."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.6"

  gem.add_dependency "gapic-common", ">= 0.20.0", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"

  gem.add_development_dependency "google-style", "~> 1.26.3"
  gem.add_development_dependency "minitest", "~> 5.16"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "rake", ">= 13.0"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.18"
  gem.add_development_dependency "yard", "~> 0.9"
end
