# -*- ruby -*-
# encoding: utf-8

Gem::Specification.new do |s|
  s.name          = "google-cloud-video_intelligence"
  s.version       = "0.6.8"

  s.authors       = ["Google Inc"]
  s.description   = "Google Cloud Video Intelligence API client for Ruby."
  s.email         = "googleapis-packages@google.com"
  s.files         = Dir.glob(File.join("lib", "**", "*.rb"))
  s.files        += Dir.glob(File.join('lib', '**', '*.json'))
  s.files        += %w(Rakefile README.md LICENSE)
  s.homepage      = "https://github.com/googleapis/googleapis"
  s.license       = "Apache-2.0"
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 2.0.0"
  s.requirements << "libgrpc ~> 1.0 needs to be installed"
  s.summary       = "GRPC library for Google Cloud Video Intelligence API"

  s.add_dependency "grpc", "~> 1.0"
  s.add_dependency "googleauth", "~> 0.5.1"
  s.add_dependency "google-gax", "~> 0.8.0"
  s.add_dependency "googleapis-common-protos", "~> 1.3.1"

  s.add_development_dependency "bundler", "~> 1.9"
  s.add_development_dependency "rake", "~> 10.4"
  s.add_development_dependency "rubocop", "<= 0.35.1"
  s.add_development_dependency "simplecov", "~> 0.9"
  s.add_development_dependency "minitest", "~> 5.10"
end
