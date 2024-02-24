# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/translate/v3/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-translate-v3"
  gem.version       = Google::Cloud::Translate::V3::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud Translation can dynamically translate text between thousands of language pairs. Translation lets websites and programs programmatically integrate with the translation service. Note that google-cloud-translate-v3 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-translate instead. See the readme for more details."
  gem.summary       = "Integrates text translation into your website or application."
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
end
