# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/gdc_hardware_management/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-gdc_hardware_management"
  gem.version       = Google::Cloud::GDCHardwareManagement::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "GDC is a fully managed software and hardware solution for data centers and edge locations to address regulatory, local data processing, survivability, and low-latency needs."
  gem.summary       = "GDC is a fully managed software and hardware solution for data centers and edge locations to address regulatory, local data processing, survivability, and low-latency needs."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-gdc_hardware_management-v1alpha", ">= 0.0", "< 2.a"
end
