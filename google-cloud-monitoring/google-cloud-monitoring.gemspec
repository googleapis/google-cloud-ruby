# -*- ruby -*-
# encoding: utf-8

Gem::Specification.new do |s|
  s.name          = 'google-cloud-monitoring'
  s.version       = '0.21.0'

  s.authors       = ['Google Inc']
  s.description   = 'a grpc-based api'
  s.email         = 'googleapis-packages@google.com'
  s.files         = Dir.glob(File.join('lib', '**', '*.rb'))
  s.files        += Dir.glob(File.join('lib', '**', '*.json'))
  s.files        += %w(Rakefile README.md)
  s.homepage      = 'https://github.com/googleapis/googleapis'
  s.license       = 'Apache-2.0'
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.0.0'
  s.summary       = 'Google client library for the Stackdriver Monitoring service'

  s.add_dependency 'google-gax', '~> 0.6.0'
  s.add_dependency 'grpc', '~> 1.0'
  s.add_dependency 'googleauth', '~> 0.5.1'
  s.add_dependency 'googleapis-common-protos', '~> 1.3.1'

  s.add_development_dependency 'bundler', '~> 1.9'
end
