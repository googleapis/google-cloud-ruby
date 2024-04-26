# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/config_service/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-config_service"
  gem.version       = Google::Cloud::ConfigService::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Creates and manages Google Cloud Platform resources and infrastructure."
  gem.summary       = "Creates and manages Google Cloud Platform resources and infrastructure."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-config_service-v1", ">= 0.2", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
