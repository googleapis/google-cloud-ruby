# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/shopping/css/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-shopping-css-v1"
  gem.version       = Google::Shopping::Css::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Programmatically manage your Comparison Shopping Service (CSS) account data at scale. Note that google-shopping-css-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-shopping-css instead. See the readme for more details."
  gem.summary       = "Programmatically manage your Comparison Shopping Service (CSS) account data at scale."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "gapic-common", ">= 0.25.0", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
  gem.add_dependency "google-shopping-type", "> 0.0", "< 2.a"
end
