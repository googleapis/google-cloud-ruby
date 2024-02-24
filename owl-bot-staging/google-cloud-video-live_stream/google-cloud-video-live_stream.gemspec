# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/video/live_stream/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-video-live_stream"
  gem.version       = Google::Cloud::Video::LiveStream::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Live Stream API transcodes mezzanine live signals into direct-to-consumer streaming formats, including Dynamic Adaptive Streaming over HTTP (DASH/MPEG-DASH), and HTTP Live Streaming (HLS), for multiple device platforms."
  gem.summary       = "API Client library for the Live Stream API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-video-live_stream-v1", ">= 0.8", "< 2.a"
end
