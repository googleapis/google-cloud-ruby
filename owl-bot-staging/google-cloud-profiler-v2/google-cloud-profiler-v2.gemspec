# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/profiler/v2/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-profiler-v2"
  gem.version       = Google::Cloud::Profiler::V2::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud Profiler is a statistical, low-overhead profiler that continuously gathers CPU usage and memory-allocation information from your production applications. It attributes that information to the application's source code, helping you identify the parts of the application consuming the most resources, and otherwise illuminating the performance characteristics of the code. Note that google-cloud-profiler-v2 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-profiler instead. See the readme for more details."
  gem.summary       = "Manages continuous profiling information."
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
