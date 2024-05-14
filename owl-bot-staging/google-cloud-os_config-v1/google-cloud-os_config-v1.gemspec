# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/os_config/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-os_config-v1"
  gem.version       = Google::Cloud::OsConfig::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud OS Config provides OS management tools that can be used for patch management, patch compliance, and configuration management on VM instances. Note that google-cloud-os_config-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-os_config instead. See the readme for more details."
  gem.summary       = "OS management tools that can be used for patch management, patch compliance, and configuration management on VM instances."
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
