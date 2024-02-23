# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/gke_backup/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-gke_backup"
  gem.version       = Google::Cloud::GkeBackup::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Backup for GKE lets you protect, manage, and restore your containerized applications and data for stateful workloads running on Google Kubernetes Engine clusters."
  gem.summary       = "API Client library for the Backup for GKE API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-gke_backup-v1", ">= 0.7", "< 2.a"
end
