# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/trace/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-trace-v1"
  gem.version       = Google::Cloud::Trace::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Cloud Trace API lets you send and retrieve latency data to and from Cloud Trace. This API provides low-level interfaces for interacting directly with the feature. For some languages, you can use OpenTelemetry, a set of open source tracing and stats instrumentation libraries that work with multiple backends. Note that google-cloud-trace-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-trace instead. See the readme for more details."
  gem.summary       = "Sends application trace data to Stackdriver Trace for viewing. Trace data is collected for all App Engine applications by default. Trace data from other applications can be provided using this API. This library is used to interact with the Trace API directly. If you are looking to instrument your application for Stackdriver Trace, we recommend using OpenTelemetry."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.6"

  gem.add_dependency "gapic-common", ">= 0.21.1", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"

  gem.add_development_dependency "google-style", "~> 1.26.3"
  gem.add_development_dependency "minitest", "~> 5.16"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "rake", ">= 13.0"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.18"
  gem.add_development_dependency "yard", "~> 0.9"
end
