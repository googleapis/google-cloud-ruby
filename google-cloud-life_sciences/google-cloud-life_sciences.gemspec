# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/life_sciences/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-life_sciences"
  gem.version       = Google::Cloud::LifeSciences::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud Life Sciences is a suite of services and tools for managing, processing, and transforming life sciences data. It also enables advanced insights and operational workflows using highly scalable and compliant infrastructure."
  gem.summary       = "API Client library for the Cloud Life Sciences API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-life_sciences-v2beta", ">= 0.7", "< 2.a"
end
