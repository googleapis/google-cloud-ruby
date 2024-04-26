# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/cloud_quotas/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-cloud_quotas"
  gem.version       = Google::Cloud::CloudQuotas::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud Quotas API provides Google Cloud service consumers with management and observability for resource usage, quotas, and restrictions of the services they consume."
  gem.summary       = "Cloud Quotas API provides Google Cloud service consumers with management and observability for resource usage, quotas, and restrictions of the services they consume."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-cloud_quotas-v1", ">= 0.2", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
