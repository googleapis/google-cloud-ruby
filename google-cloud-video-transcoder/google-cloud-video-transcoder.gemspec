# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/video/transcoder/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-video-transcoder"
  gem.version       = Google::Cloud::Video::Transcoder::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "This API converts video files into formats suitable for consumer distribution. For more information, see the <a href=\"https://cloud.google.com/transcoder/docs/concepts/overview\">Transcoder API overview</a>."
  gem.summary       = "This API converts video files into formats suitable for consumer distribution. For more information, see the <a href=\"https://cloud.google.com/transcoder/docs/concepts/overview\">Transcoder API overview</a>."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-video-transcoder-v1", "~> 2.0"
end
