# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/location_finder/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-location_finder"
  gem.version       = Google::Cloud::LocationFinder::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud Location Finder is a public API that offers a repository of all Google Cloud and Google Distributed Cloud locations, as well as cloud locations for other cloud providers."
  gem.summary       = "Cloud Location Finder is a public API that offers a repository of all Google Cloud and Google Distributed Cloud locations, as well as cloud locations for other cloud providers."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-location_finder-v1", ">= 0.0", "< 2.a"
end
