# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/filestore/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-filestore"
  gem.version       = Google::Cloud::Filestore::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Filestore instances are fully managed NFS file servers on Google Cloud for use with applications running on Compute Engine virtual machines (VMs) instances or Google Kubernetes Engine clusters."
  gem.summary       = "API Client library for the Filestore API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-filestore-v1", ">= 0.8", "< 2.a"
end
