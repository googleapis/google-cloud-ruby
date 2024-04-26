# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/video_intelligence/v1p2beta1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-video_intelligence-v1p2beta1"
  gem.version       = Google::Cloud::VideoIntelligence::V1p2beta1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Detects objects, explicit content, and scene changes in videos. It also specifies the region for annotation and transcribes speech to text. Supports both asynchronous API and streaming API. Note that google-cloud-video_intelligence-v1p2beta1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-video_intelligence instead. See the readme for more details."
  gem.summary       = "Detects objects, explicit content, and scene changes in videos. It also specifies the region for annotation and transcribes speech to text. Supports both asynchronous API and streaming API."
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
