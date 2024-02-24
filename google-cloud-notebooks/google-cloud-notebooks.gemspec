# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/notebooks/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-notebooks"
  gem.version       = Google::Cloud::Notebooks::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "AI Platform Notebooks makes it easy to manage JupyterLab instances through a protected, publicly available notebook instance URL. A JupyterLab instance is a Deep Learning virtual machine instance with the latest machine learning and data science libraries pre-installed."
  gem.summary       = "API Client library for the AI Platform Notebooks API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-notebooks-v1", ">= 0.8", "< 2.a"
  gem.add_dependency "google-cloud-notebooks-v1beta1", ">= 0.9", "< 2.a"
end
