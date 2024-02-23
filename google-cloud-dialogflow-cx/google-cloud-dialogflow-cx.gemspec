# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/dialogflow/cx/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-dialogflow-cx"
  gem.version       = Google::Cloud::Dialogflow::CX::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Dialogflow is an end-to-end, build-once deploy-everywhere development suite for creating conversational interfaces for websites, mobile applications, popular messaging platforms, and IoT devices. You can use it to build interfaces (such as chatbots and conversational IVR) that enable natural and rich interactions between your users and your business. This client is for Dialogflow CX, providing an advanced agent type suitable for large or very complex agents."
  gem.summary       = "API Client library for the Dialogflow CX API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-dialogflow-cx-v3", ">= 0.24", "< 2.a"
end
