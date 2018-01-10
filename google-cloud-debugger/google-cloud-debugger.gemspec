# -*- encoding: utf-8 -*-
require File.expand_path("../lib/google/cloud/debugger/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-debugger"
  gem.version       = Google::Cloud::Debugger::VERSION

  gem.authors       = ["Heng Xiong"]
  gem.email         = ["hexiong@google.com"]
  gem.description   = "google-cloud-debugger is the official library for Stackdriver Debugger."
  gem.summary       = "API Client and instrumentation library for Stackdriver Debugger"
  gem.homepage      = "https://github.com/GoogleCloudPlatform/google-cloud-ruby/tree/master/google-cloud-debugger"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files -- lib/* ext/*`.split("\n") +
                      ["README.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.2.0"

  gem.extensions << "ext/google/cloud/debugger/debugger_c/extconf.rb"

  gem.add_dependency "binding_of_caller", "~> 0.7"
  gem.add_dependency "google-cloud-core", "~> 1.1"
  gem.add_dependency "google-cloud-logging", "~> 1.0"
  gem.add_dependency "google-gax", "~> 1.0"
  gem.add_dependency "stackdriver-core", "~> 1.2"

  gem.add_development_dependency "minitest", "~> 5.10"
  gem.add_development_dependency "minitest-autotest", "~> 1.0"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "autotest-suffix", "~> 1.1"
  gem.add_development_dependency "rubocop", "~> 0.52"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
  gem.add_development_dependency "yard-doctest", "~> 0.1.8"
  gem.add_development_dependency "railties", "~> 4.0"
  gem.add_development_dependency "rack", ">= 0.1"
  gem.add_development_dependency "rake-compiler", "~> 1.0"
end
