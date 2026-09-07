# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/dialogflow/cx/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-dialogflow-cx"
  gem.version       = Google::Cloud::Dialogflow::CX::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Builds conversational interfaces (for example, chatbots, and voice-powered apps and devices)."
  gem.summary       = "Builds conversational interfaces (for example, chatbots, and voice-powered apps and devices)."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-dialogflow-cx-v3", ">= 0.24", "< 2.a"
end
