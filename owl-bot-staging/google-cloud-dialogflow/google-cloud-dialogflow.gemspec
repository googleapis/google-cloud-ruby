# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/dialogflow/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-dialogflow"
  gem.version       = Google::Cloud::Dialogflow::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Dialogflow is an end-to-end, build-once deploy-everywhere development suite for creating conversational interfaces for websites, mobile applications, popular messaging platforms, and IoT devices. You can use it to build interfaces (such as chatbots and conversational IVR) that enable natural and rich interactions between your users and your business. This client is for Dialogflow ES, providing the standard agent type suitable for small and simple agents."
  gem.summary       = "API Client library for the Dialogflow API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts", "MIGRATING.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-dialogflow-v2", ">= 0.32", "< 2.a"
end
