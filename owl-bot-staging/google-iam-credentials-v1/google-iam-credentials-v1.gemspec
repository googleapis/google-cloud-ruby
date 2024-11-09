# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/iam/credentials/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-iam-credentials-v1"
  gem.version       = Google::Iam::Credentials::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Service Account Credentials API creates short-lived credentials for Identity and Access Management (IAM) service accounts. You can also use this API to sign JSON Web Tokens (JWTs), as well as blobs of binary data that contain other types of tokens. Note that google-iam-credentials-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-iam-credentials instead. See the readme for more details."
  gem.summary       = "Creates short-lived, limited-privilege credentials for IAM service accounts."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "gapic-common", ">= 0.21.1", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
end
