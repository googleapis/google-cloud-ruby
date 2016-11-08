# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gcloud/jsondoc/version'

Gem::Specification.new do |s|
  s.name          = "gcloud-jsondoc"
  s.version       = Gcloud::Jsondoc::VERSION

  s.authors       = ["Chris Smith"]
  s.email         = ["quartzmo@gmail.com"]
  s.description   = "Gcloud is the official library for interacting with Google Cloud."
  s.summary       = "API Client library for Google Cloud"
  s.homepage      = "http://googlecloudplatform.github.io/gcloud-ruby/"
  s.license       = "Apache-2.0"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if s.respond_to?(:metadata)
    s.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test)/}) }
  s.require_paths = ["lib"]

  s.add_dependency 'yard', "~> 0.8"
  s.add_dependency 'kramdown', "~> 1.9"
  s.add_dependency 'jbuilder', "~> 2.5.0"

  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-autotest", "~> 1.0"
  s.add_development_dependency "activesupport", "~> 4.0"
end
