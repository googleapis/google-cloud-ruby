# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/dlp/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-dlp"
  gem.version       = Google::Cloud::Dlp::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Discover and protect your sensitive data. A fully managed service designed to help you discover, classify, and protect your valuable data assets with ease."
  gem.summary       = "Discover and protect your sensitive data. A fully managed service designed to help you discover, classify, and protect your valuable data assets with ease."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts", "MIGRATING.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-dlp-v2", ">= 0.20", "< 2.a"
end
