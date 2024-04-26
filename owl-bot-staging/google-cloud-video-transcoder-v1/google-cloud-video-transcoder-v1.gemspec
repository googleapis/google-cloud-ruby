# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/video/transcoder/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-video-transcoder-v1"
  gem.version       = Google::Cloud::Video::Transcoder::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Transcoder API allows you to convert video files and package them for optimized delivery to web, mobile and connected TVs. Note that google-cloud-video-transcoder-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-video-transcoder instead. See the readme for more details."
  gem.summary       = "This API converts video files into formats suitable for consumer distribution. For more information, see the Transcoder API overview."
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
