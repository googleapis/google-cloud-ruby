# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/eventarc/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-eventarc"
  gem.version       = Google::Cloud::Eventarc::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Build event-driven applications on Google Cloud Platform."
  gem.summary       = "Build event-driven applications on Google Cloud Platform."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-eventarc-v1", "~> 2.0"
end
