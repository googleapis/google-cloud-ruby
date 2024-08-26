# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/analytics/data/v1beta/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-analytics-data-v1beta"
  gem.version       = Google::Analytics::Data::V1beta::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Google Analytics Data API provides programmatic methods to access report data in Google Analytics 4 (GA4) properties. Google Analytics 4 helps you understand how people use your web, iOS, or Android app. Note that google-analytics-data-v1beta is a version-specific client library. For most uses, we recommend installing the main client library google-analytics-data instead. See the readme for more details."
  gem.summary       = "Accesses report data in Google Analytics. Warning: Creating multiple Customer Applications, Accounts, or Projects to simulate or act as a single Customer Application, Account, or Project (respectively) or to circumvent Service-specific usage limits or quotas is a direct violation of Google Cloud Platform Terms of Service as well as Google APIs Terms of Service. These actions can result in immediate termination of your GCP project(s) without any warning."
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
