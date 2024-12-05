# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/dialogflow/cx/v3/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-dialogflow-cx-v3"
  gem.version       = Google::Cloud::Dialogflow::CX::V3::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Dialogflow is an end-to-end, build-once deploy-everywhere development suite for creating conversational interfaces for websites, mobile applications, popular messaging platforms, and IoT devices. You can use it to build interfaces (such as chatbots and conversational IVR) that enable natural and rich interactions between your users and your business. This client is for Dialogflow CX, providing an advanced agent type suitable for large or very complex agents. Note that google-cloud-dialogflow-cx-v3 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-dialogflow-cx instead. See the readme for more details."
  gem.summary       = "Builds conversational interfaces (for example, chatbots, and voice-powered apps and devices)."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "gapic-common", ">= 0.21.1", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
  gem.add_dependency "google-cloud-location", ">= 0.7", "< 2.a"
end
