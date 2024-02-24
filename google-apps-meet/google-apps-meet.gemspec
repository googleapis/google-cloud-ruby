# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/apps/meet/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-apps-meet"
  gem.version       = Google::Apps::Meet::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Create and manage meetings in Google Meet."
  gem.summary       = "Create and manage meetings in Google Meet."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-apps-meet-v2", ">= 0.0", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
