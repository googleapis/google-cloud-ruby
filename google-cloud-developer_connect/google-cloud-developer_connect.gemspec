# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/developer_connect/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-developer_connect"
  gem.version       = Google::Cloud::DeveloperConnect::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Developer Connect streamlines integration with third-party source code management platforms by simplifying authentication, authorization, and networking configuration."
  gem.summary       = "Connect third-party source code management to Google."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-developer_connect-v1", ">= 0.0", "< 2.a"
end
