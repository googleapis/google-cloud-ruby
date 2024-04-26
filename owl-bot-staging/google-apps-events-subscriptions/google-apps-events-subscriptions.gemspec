# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/apps/events/subscriptions/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-apps-events-subscriptions"
  gem.version       = Google::Apps::Events::Subscriptions::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Google Workspace Events API lets you subscribe to events and manage change notifications across Google Workspace applications."
  gem.summary       = "The Google Workspace Events API lets you subscribe to events and manage change notifications across Google Workspace applications."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-apps-events-subscriptions-v1", ">= 0.0", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
