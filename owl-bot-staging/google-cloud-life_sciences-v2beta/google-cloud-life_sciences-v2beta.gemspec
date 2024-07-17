# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/life_sciences/v2beta/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-life_sciences-v2beta"
  gem.version       = Google::Cloud::LifeSciences::V2beta::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud Life Sciences is a suite of services and tools for managing, processing, and transforming life sciences data. It also enables advanced insights and operational workflows using highly scalable and compliant infrastructure. Note that google-cloud-life_sciences-v2beta is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-life_sciences instead. See the readme for more details."
  gem.summary       = "Cloud Life Sciences is a suite of services and tools for managing, processing, and transforming life sciences data."
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
