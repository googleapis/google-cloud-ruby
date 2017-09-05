source "https://rubygems.org"

gem "rake", "~> 11.0"
gem "minitest", "~> 5.10"
gem "minitest-autotest", "~> 1.0"
gem "minitest-focus", "~> 1.1"
gem "minitest-rg", "~> 5.2"
gem "autotest-suffix", "~> 1.1"
gem "rubocop", "<= 0.35.1"
gem "simplecov", "~> 0.9"
gem "coveralls", "~> 0.7"
gem "yard", "~> 0.9"
gem "yard-doctest", "<= 0.1.8"
gem "gems", "~> 0.8"
gem "actionpack", "~> 4.0"
gem "railties", "~> 4.0"
gem "rack", ">= 0.1"

gem "google-cloud-core", path: "google-cloud-core"
gem "google-cloud-env", path: "google-cloud-env"
gem "google-cloud-bigquery", path: "google-cloud-bigquery"
gem "google-cloud-datastore", path: "google-cloud-datastore"
gem "google-cloud-dns", path: "google-cloud-dns"
gem "google-cloud-error_reporting", path: "google-cloud-error_reporting"
gem "google-cloud-language", path: "google-cloud-language"
gem "google-cloud-logging", path: "google-cloud-logging"
gem "google-cloud-monitoring", path: "google-cloud-monitoring"
gem "google-cloud-pubsub", path: "google-cloud-pubsub"
gem "google-cloud-resource_manager", path: "google-cloud-resource_manager"
gem "google-cloud-spanner", path: "google-cloud-spanner"
gem "google-cloud-speech", path: "google-cloud-speech"
gem "google-cloud-storage", path: "google-cloud-storage"
gem "google-cloud-trace", path: "google-cloud-trace"
gem "google-cloud-translate", path: "google-cloud-translate"
gem "google-cloud-vision", path: "google-cloud-vision"
gem "google-cloud-video_intelligence", path: "google-cloud-video_intelligence"
gem "google-cloud", path: "google-cloud"
gem "gcloud", path: "gcloud"
gem "stackdriver-core", path: "stackdriver-core"

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.2.0")
  gem "stackdriver", path: "stackdriver"
  gem "google-cloud-debugger", path: "google-cloud-debugger"
end

# WORKAROUND: builds are having problems since the release of 3.0.0
# pin to the last known good version
gem "public_suffix", "~> 2.0"

# TEMP: rainbow (a dependency of rubocop) version 2.2 seems to have a problem,
# so pinning to 2.1 for now.
gem "rainbow", "~> 2.1.0"

# TEMP: nokogiri (a dependency of rails) 1.7 requires Ruby 2.1 or later.
# Since we're still testing on Ruby 2.0, pin nokogiri to 1.6 for now.
gem "nokogiri", "~> 1.6.8"
