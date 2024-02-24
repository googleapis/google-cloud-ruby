# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/eventarc/publishing/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-eventarc-publishing"
  gem.version       = Google::Cloud::Eventarc::Publishing::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Eventarc lets you asynchronously deliver events from Google services, SaaS, and your own apps using loosely coupled services that react to state changes. Eventarc requires no infrastructure management — you can optimize productivity and costs while building a modern, event-driven solution."
  gem.summary       = "API Client library for the Eventarc Publishing API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-eventarc-publishing-v1", ">= 0.8", "< 2.a"
end
