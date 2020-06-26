# -*- ruby -*-
# encoding: utf-8
require File.expand_path("../lib/google/cloud/webrisk/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-webrisk"
  gem.version       = Google::Cloud::Webrisk::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "This library is deprecated, and will no longer receive updates. Please use google-cloud-web_risk instead."
  gem.summary       = "Obsolete API Client library for Web Risk API"
  gem.homepage      = "https://github.com/googleapis/googleapis"
  gem.license       = "Apache-2.0"

  gem.post_install_message =
    "The google-cloud-webrisk library is deprecated. Please use google-cloud-web_risk instead." \
    " See https://googleapis.dev/ruby/google-cloud-web_risk/latest/file.MIGRATING.html for" \
    " detailed information on the differences."

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.4"

  gem.add_dependency "google-gax", "~> 1.8"
  gem.add_dependency "googleapis-common-protos", ">= 1.3.9", "< 2.0"
  gem.add_dependency "googleapis-common-protos-types", ">= 1.0.4", "< 2.0"

  gem.add_development_dependency "minitest", "~> 5.10"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "google-style", "~> 1.24.0"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
end
