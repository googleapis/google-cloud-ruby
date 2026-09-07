# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/org_policy/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-org_policy"
  gem.version       = Google::Cloud::OrgPolicy::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Organization Policy API allows users to configure governance rules on their Google Cloud resources across the resource hierarchy."
  gem.summary       = "The Organization Policy API allows users to configure governance rules on their Google Cloud resources across the resource hierarchy."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-org_policy-v2", ">= 0.9", "< 2.a"
end
