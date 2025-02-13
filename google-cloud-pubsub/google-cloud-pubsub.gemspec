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

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "concurrent-ruby", "~> 1.1"
  gem.add_dependency "google-cloud-core", "~> 1.5"
  gem.add_dependency "google-cloud-pubsub-v1", "~> 1.7"
  gem.add_dependency "retriable", "~> 3.1"
end
