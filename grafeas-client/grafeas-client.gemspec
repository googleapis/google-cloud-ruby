# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/grafeas/client/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "grafeas-client"
  gem.version       = Grafeas::Client::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "grafeas-client is the official library for the Grafeas API."
  gem.summary       = "API Client library for the Grafeas API"
  gem.homepage      = "https://github.com/googleapis/googleapis"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.4"

  gem.add_dependency "grafeas", "~> 1.0"

  gem.add_development_dependency "google-style", "~> 1.24.0"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"

  gem.post_install_message = "grafeas-client is now grafeas, please change the gem name in your dependencies"
end
