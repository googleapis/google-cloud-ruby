# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/os_login/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-os_login"
  gem.version       = Google::Cloud::OsLogin::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "You can use OS Login to manage access to your VM instances using IAM roles."
  gem.summary       = "You can use OS Login to manage access to your VM instances using IAM roles."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-os_login-v1", "~> 1.2"
end
