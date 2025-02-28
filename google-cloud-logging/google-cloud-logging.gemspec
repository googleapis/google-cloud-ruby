# -*- encoding: utf-8 -*-
require File.expand_path("../lib/google/cloud/logging/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-logging"
  gem.version       = Google::Cloud::Logging::VERSION

  gem.authors       = ["Mike Moore", "Chris Smith"]
  gem.email         = ["mike@blowmage.com", "quartzmo@gmail.com"]
  gem.description   = "google-cloud-logging is the official library for Stackdriver Logging."
  gem.summary       = "API Client library for Stackdriver Logging"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-logging"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["OVERVIEW.md", "AUTHENTICATION.md", "INSTRUMENTATION.md", "LOGGING.md", "CONTRIBUTING.md", "TROUBLESHOOTING.md", "CHANGELOG.md", "CODE_OF_CONDUCT.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-cloud-core", "~> 1.5"
  gem.add_dependency "google-cloud-logging-v2", ">= 0.0", "< 2.a"
  gem.add_dependency "stackdriver-core", "~> 1.3"
  gem.add_dependency "concurrent-ruby", "~> 1.1"
end
