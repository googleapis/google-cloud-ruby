# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/saas_platform/saas_service_mgmt/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-saas_platform-saas_service_mgmt"
  gem.version       = Google::Cloud::SaasPlatform::SaasServiceMgmt::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "SaaS Runtime lets you store, host, manage, and monitor software as a service (SaaS) applications on Google Cloud."
  gem.summary       = "Model, deploy, and operate your SaaS at scale."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-saas_platform-saas_service_mgmt-v1beta1", ">= 0.0", "< 2.a"
end
