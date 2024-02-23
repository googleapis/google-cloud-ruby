# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/advisory_notifications/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-advisory_notifications"
  gem.version       = Google::Cloud::AdvisoryNotifications::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "An API for accessing Advisory Notifications in Google Cloud."
  gem.summary       = "An API for accessing Advisory Notifications in Google Cloud."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-advisory_notifications-v1", ">= 0.8", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
