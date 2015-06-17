# -*- encoding: utf-8 -*-
require File.expand_path("../lib/gcloud/rdoc/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "gcloud-rdoc"
  gem.version       = Gcloud::RDoc::VERSION

  gem.authors       = ["Silvano Luciani", "Mike Moore"]
  gem.email         = ["silvano@google.com", "mike@blowmage.com"]
  gem.description   = "Gcloud is the official library for interacting with Google Cloud."
  gem.summary       = "RDoc template for Google Cloud"
  gem.homepage      = "http://googlecloudplatform.github.io/gcloud-ruby/"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files -- lib/*`.split("\n")
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 1.9.3"

  gem.extra_rdoc_files = ["README.md"]
  gem.rdoc_options     = ["--main", "README.md"]

  gem.add_dependency             "rdoc", "~> 4.0"

  gem.add_development_dependency "minitest", "~> 5.7"
end
