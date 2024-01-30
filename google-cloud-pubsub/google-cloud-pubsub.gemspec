require File.expand_path("lib/google/cloud/pubsub/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-pubsub"
  gem.version       = Google::Cloud::PubSub::VERSION

  gem.authors       = ["Mike Moore", "Chris Smith"]
  gem.email         = ["mike@blowmage.com", "quartzmo@gmail.com"]
  gem.description   = "google-cloud-pubsub is the official library for Google Cloud Pub/Sub."
  gem.summary       = "API Client library for Google Cloud Pub/Sub"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-pubsub"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["OVERVIEW.md", "AUTHENTICATION.md", "EMULATOR.md", "LOGGING.md", "CONTRIBUTING.md",
                       "TROUBLESHOOTING.md", "CHANGELOG.md", "CODE_OF_CONDUCT.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.5"

  gem.add_dependency "concurrent-ruby", "~> 1.1"
  gem.add_dependency "google-cloud-core", "~> 1.5"
  gem.add_dependency "google-cloud-pubsub-v1", "~> 0.20"
  gem.add_dependency "retriable", "~> 3.1"

  gem.add_development_dependency "autotest-suffix", "~> 1.1"
  gem.add_development_dependency "avro", "~> 1.10"
  gem.add_development_dependency "google-style", "~> 1.25.1"
  gem.add_development_dependency "minitest", "~> 5.16"
  gem.add_development_dependency "minitest-autotest", "~> 1.0"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
  gem.add_development_dependency "yard-doctest", "~> 0.1.13"
end
