# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/chronicle/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-chronicle"
  gem.version       = Google::Cloud::Chronicle::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Google Cloud Security Operations API, popularly known as the Chronicle API, serves endpoints that enable security analysts to analyze and mitigate a security threat throughout its lifecycle."
  gem.summary       = "The Google Cloud Security Operations API, popularly known as the Chronicle API, serves endpoints that enable security analysts to analyze and mitigate a security threat throughout its lifecycle."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-cloud-chronicle-v1", ">= 0.0", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
