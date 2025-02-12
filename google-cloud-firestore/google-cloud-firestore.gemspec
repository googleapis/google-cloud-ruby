require File.expand_path("../lib/google/cloud/firestore/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-firestore"
  gem.version       = Google::Cloud::Firestore::VERSION

  gem.authors       = ["Google Inc"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "google-cloud-firestore is the official library for Google Cloud Firestore API."
  gem.summary       = "API Client library for Google Cloud Firestore API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-firestore"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["OVERVIEW.md", "AUTHENTICATION.md", "EMULATOR.md", "LOGGING.md", "CONTRIBUTING.md", "TROUBLESHOOTING.md", "CHANGELOG.md", "CODE_OF_CONDUCT.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "bigdecimal", "~> 3.0"
  gem.add_dependency "concurrent-ruby", "~> 1.0"
  gem.add_dependency "google-cloud-core", "~> 1.7"
  gem.add_dependency "google-cloud-firestore-v1", "~> 2.0"
  gem.add_dependency "rbtree", "~> 0.4.2"
end
