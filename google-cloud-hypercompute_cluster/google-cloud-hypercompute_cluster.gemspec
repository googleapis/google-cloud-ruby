# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/hypercompute_cluster/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-hypercompute_cluster"
  gem.version       = Google::Cloud::HypercomputeCluster::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Cluster Director API lets you deploy, manage, and monitor clusters that run artificial intelligence (AI), machine learning (ML), or high performance computing (HPC) workloads."
  gem.summary       = "The Cluster Director API lets you deploy, manage, and monitor clusters that run artificial intelligence (AI), machine learning (ML), or high performance computing (HPC) workloads."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-hypercompute_cluster-v1beta", ">= 0.0", "< 2.a"
end
