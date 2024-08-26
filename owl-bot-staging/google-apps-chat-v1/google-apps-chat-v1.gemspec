# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/apps/chat/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-apps-chat-v1"
  gem.version       = Google::Apps::Chat::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Google Chat API lets you build Chat apps to integrate your services with Google Chat and manage Chat resources such as spaces, members, and messages. Note that google-apps-chat-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-apps-chat instead. See the readme for more details."
  gem.summary       = "The Google Chat API lets you build Chat apps to integrate your services with Google Chat and manage Chat resources such as spaces, members, and messages."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "gapic-common", ">= 0.21.1", "< 2.a"
  gem.add_dependency "google-apps-card-v1", "> 0.0", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
end
