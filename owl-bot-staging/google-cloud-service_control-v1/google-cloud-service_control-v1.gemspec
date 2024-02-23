# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/service_control/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-service_control-v1"
  gem.version       = Google::Cloud::ServiceControl::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Service Control API provides control plane functionality to managed services, such as logging, monitoring, and status checks. Note that google-cloud-service_control-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-service_control instead. See the readme for more details."
  gem.summary       = "Provides admission control and telemetry reporting for services integrated with Service Infrastructure."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "gapic-common", ">= 0.21.1", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
end
