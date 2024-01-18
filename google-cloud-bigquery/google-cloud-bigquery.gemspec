require File.expand_path("lib/google/cloud/bigquery/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-bigquery"
  gem.version       = Google::Cloud::Bigquery::VERSION

  gem.authors       = ["Mike Moore", "Chris Smith"]
  gem.email         = ["mike@blowmage.com", "quartzmo@gmail.com"]
  gem.description   = "google-cloud-bigquery is the official library for Google BigQuery."
  gem.summary       = "API Client library for Google BigQuery"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-bigquery"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["OVERVIEW.md", "AUTHENTICATION.md", "LOGGING.md", "CONTRIBUTING.md", "TROUBLESHOOTING.md",
                       "CHANGELOG.md", "CODE_OF_CONDUCT.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.6"

  gem.add_dependency "concurrent-ruby", "~> 1.0"
  gem.add_dependency "google-apis-bigquery_v2", "~> 0.62"
  gem.add_dependency "googleauth", "~> 1.9"
  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "mini_mime", "~> 1.0"

  gem.add_development_dependency "autotest-suffix", "~> 1.1"
  gem.add_development_dependency "google-cloud-data_catalog", "~> 1.2"
  gem.add_development_dependency "google-style", "~> 1.26.1"
  gem.add_development_dependency "minitest", "~> 5.16"
  gem.add_development_dependency "minitest-autotest", "~> 1.0"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.18"
  gem.add_development_dependency "yard", "~> 0.9"
  gem.add_development_dependency "yard-doctest", "~> 0.1.13"
end
