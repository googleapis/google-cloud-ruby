# -*- ruby -*-
# encoding: utf-8

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-error_reporting"
  gem.version       = "0.22.0"

  gem.authors       = ["Google Inc"]
  gem.email         = ["googleapis-packages@google.com"]
  gem.description   = "google-cloud-error_reporting is the official library for Stackdriver Error Reporting."
  gem.summary       = "API Client library for Stackdriver Error Reporting"
  gem.homepage      = "http://googlecloudplatform.github.io/google-cloud-ruby/"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.0.0"

  gem.add_dependency "google-cloud-core", "~> 0.21.0"
  gem.add_dependency "google-gax", "~> 0.7.1"
  gem.add_dependency "googleapis-common-protos", "~> 1.3.5"

  gem.add_development_dependency "minitest", "~> 5.10"
  gem.add_development_dependency "minitest-autotest", "~> 1.0"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "rubocop", "<= 0.35.1"
  gem.add_development_dependency "actionpack", "~> 4.0"
  gem.add_development_dependency "railties", "~> 4.0"
  gem.add_development_dependency "rack", ">= 0.1"
end
