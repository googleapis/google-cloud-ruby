# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/media_translation/v1beta1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-media_translation-v1beta1"
  gem.version       = Google::Cloud::MediaTranslation::V1beta1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Media Translation API delivers real-time speech translation to your content and applications directly from your audio data. Leveraging Google’s machine learning technologies, the API offers enhanced accuracy and simplified integration while equipping you with a comprehensive set of features to further refine your translation results. Improve user experience with low-latency streaming translation and scale quickly with straightforward internationalization. Note that google-cloud-media_translation-v1beta1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-media_translation instead. See the readme for more details."
  gem.summary       = "API Client library for the Media Translation V1beta1 API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.1"

  gem.add_dependency "gapic-common", "~> 1.0"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
end
