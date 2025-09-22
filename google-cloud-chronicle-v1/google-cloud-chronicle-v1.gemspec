# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/chronicle/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-chronicle-v1"
  gem.version       = Google::Cloud::Chronicle::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Google Cloud Security Operations API, popularly known as the Chronicle API, serves endpoints that enable security analysts to analyze and mitigate a security threat throughout its lifecycle. Note that google-cloud-chronicle-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-chronicle instead. See the readme for more details."
  gem.summary       = "The Google Cloud Security Operations API, popularly known as the Chronicle API, serves endpoints that enable security analysts to analyze and mitigate a security threat throughout its lifecycle."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.1"

  gem.add_dependency "gapic-common", "~> 1.2"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
end
