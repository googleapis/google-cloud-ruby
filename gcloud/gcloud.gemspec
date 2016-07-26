# -*- encoding: utf-8 -*-
require File.expand_path("../lib/gcloud/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "gcloud"
  gem.version       = Gcloud::GCLOUD_VERSION

  gem.authors       = ["Mike Moore", "Chris Smith"]
  gem.email         = ["mike@blowmage.com", "quartzmo@gmail.com"]
  gem.description   = "Gcloud is the official library for interacting with Google Cloud."
  gem.summary       = "API Client library for Google Cloud"
  gem.homepage      = "http://googlecloudplatform.github.io/gcloud-ruby/"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- docs/*`.split("\n")
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.0.0"

  gem.add_dependency "google-cloud"
end
