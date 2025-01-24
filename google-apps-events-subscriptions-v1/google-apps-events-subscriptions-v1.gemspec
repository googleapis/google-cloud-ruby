# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/apps/events/subscriptions/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-apps-events-subscriptions-v1"
  gem.version       = Google::Apps::Events::Subscriptions::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Google Workspace Events API lets you subscribe to events and manage change notifications across Google Workspace applications. Note that google-apps-events-subscriptions-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-apps-events-subscriptions instead. See the readme for more details."
  gem.summary       = "The Google Workspace Events API lets you subscribe to events and manage change notifications across Google Workspace applications."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "gapic-common", ">= 0.25.0", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
end
