# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/debugger/v2/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-debugger-v2"
  gem.version       = Google::Cloud::Debugger::V2::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Cloud Debugger API allows applications to interact with the Google Cloud Debugger backends. It provides two interfaces: the Debugger interface and the Controller interface. The Controller interface allows you to implement an agent that sends state data -- for example, the value of program variables and the call stack -- to Cloud Debugger when the application is running. The Debugger interface allows you to implement a Cloud Debugger client that allows users to set and delete the breakpoints at which the state data is collected, as well as read the data that is captured. Note that google-cloud-debugger-v2 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-debugger instead. See the readme for more details."
  gem.summary       = "API Client library for the Cloud Debugger V2 API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.5"

  gem.add_dependency "gapic-common", ">= 0.7", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"

  gem.add_development_dependency "google-style", "~> 1.25.1"
  gem.add_development_dependency "minitest", "~> 5.14"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "rake", ">= 12.0"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.18"
  gem.add_development_dependency "yard", "~> 0.9"
end
