# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/media_translation/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-media_translation"
  gem.version       = Google::Cloud::MediaTranslation::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Media Translation API delivers real-time speech translation to your content and applications directly from your audio data. Leveraging Google’s machine learning technologies, the API offers enhanced accuracy and simplified integration while equipping you with a comprehensive set of features to further refine your translation results. Improve user experience with low-latency streaming translation and scale quickly with straightforward internationalization."
  gem.summary       = "API Client library for the Media Translation API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-media_translation-v1beta1", ">= 0.8", "< 2.a"
end
