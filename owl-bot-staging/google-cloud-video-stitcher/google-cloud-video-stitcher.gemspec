# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/video/stitcher/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-video-stitcher"
  gem.version       = Google::Cloud::Video::Stitcher::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Video Stitcher API allows you to manipulate video content to dynamically insert ads prior to delivery to client devices. Using the Video Stitcher API, you can monetize your video-on-demand (VOD) and livestreaming videos by inserting ads as described by metadata stored on ad servers."
  gem.summary       = "API Client library for the Video Stitcher API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.6"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-video-stitcher-v1", ">= 0.8", "< 2.a"

  gem.add_development_dependency "google-style", "~> 1.26.1"
  gem.add_development_dependency "minitest", "~> 5.16"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "rake", ">= 13.0"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
end
