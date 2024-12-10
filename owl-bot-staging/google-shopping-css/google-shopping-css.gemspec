# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/shopping/css/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-shopping-css"
  gem.version       = Google::Shopping::Css::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Programmatically manage your Comparison Shopping Service (CSS) account data at scale."
  gem.summary       = "Programmatically manage your Comparison Shopping Service (CSS) account data at scale."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-shopping-css-v1", ">= 0.0", "< 2.a"
end
