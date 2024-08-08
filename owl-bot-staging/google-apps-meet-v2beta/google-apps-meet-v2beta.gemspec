# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/apps/meet/v2beta/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-apps-meet-v2beta"
  gem.version       = Google::Apps::Meet::V2beta::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Create and manage meetings in Google Meet. Note that google-apps-meet-v2beta is a version-specific client library. For most uses, we recommend installing the main client library google-apps-meet instead. See the readme for more details."
  gem.summary       = "Create and manage meetings in Google Meet."
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
