# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/redis/cluster/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-redis-cluster"
  gem.version       = Google::Cloud::Redis::Cluster::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Creates and manages Redis instances on the Google Cloud Platform."
  gem.summary       = "Creates and manages Redis instances on the Google Cloud Platform."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-redis-cluster-v1", ">= 0.2", "< 2.a"
end
