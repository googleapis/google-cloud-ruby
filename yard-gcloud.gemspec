# -*- encoding: utf-8 -*-
require File.expand_path("../lib/yard/gcloud/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "yard-gcloud"
  gem.version       = YARD::Gcloud::VERSION

  gem.authors       = ["Mike Moore", "Chris Smith"]
  gem.email         = ["mike@blowmage.com", "quartzmo@gmail.com"]
  gem.description   = "Gcloud is the official library for interacting with Google Cloud."
  gem.summary       = "YARD template for Google Cloud"
  gem.homepage      = "http://googlecloudplatform.github.io/gcloud-ruby/"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files -- lib/* templates/*`.split("\n")
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.0.0"

  gem.add_dependency             "yard", "~> 0.8"
  gem.add_dependency             "redcarpet", "~> 3.3"
  gem.add_dependency             "kramdown", "~> 1.9"
  gem.add_dependency             "rouge", "~> 1.10"

  gem.add_development_dependency "minitest", "~> 5.7"
end
