# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/tpu/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-tpu"
  gem.version       = Google::Cloud::Tpu::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Tensor Processing Units (TPUs) are Google's custom-developed application-specific integrated circuits (ASICs) used to accelerate machine learning workloads. Cloud TPUs allow you to access TPUs from Compute Engine, Google Kubernetes Engine and AI Platform."
  gem.summary       = "API Client library for the Cloud TPU API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-tpu-v1", ">= 0.6", "< 2.a"
end
