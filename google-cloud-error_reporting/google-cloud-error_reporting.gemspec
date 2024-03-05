# -*- encoding: utf-8 -*-
require File.expand_path("../lib/google/cloud/error_reporting/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-error_reporting"
  gem.version       = Google::Cloud::ErrorReporting::VERSION

  gem.authors       = ["Google Inc"]
  gem.email         = ["googleapis-packages@google.com"]
  gem.description   = "google-cloud-error_reporting is the official library for Error Reporting."
  gem.summary       = "API Client library for Error Reporting"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-error_reporting"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["OVERVIEW.md", "AUTHENTICATION.md", "INSTRUMENTATION.md", "LOGGING.md", "CONTRIBUTING.md", "TROUBLESHOOTING.md", "CHANGELOG.md", "CODE_OF_CONDUCT.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.5"
  gem.add_dependency "stackdriver-core", "~> 1.3"
  gem.add_dependency "google-cloud-error_reporting-v1beta1", "~> 0.0"
  gem.add_dependency "concurrent-ruby", "~> 1.1"
end
