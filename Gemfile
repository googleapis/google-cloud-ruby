source "https://rubygems.org"

gem "rake", "~> 11.0"
gem "minitest", "~> 5.10"
gem "minitest-autotest", "~> 1.0"
gem "minitest-focus", "~> 1.1"
gem "minitest-rg", "~> 5.2"
gem "autotest-suffix", "~> 1.1"
gem "rubocop", "~> 0.50.0"
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
gem "google-cloud-bigquery-data_transfer", path: "google-cloud-bigquery-data_transfer"
gem "google-cloud-bigtable", path: "google-cloud-bigtable"
gem "google-cloud-dataproc", path: "google-cloud-dataproc"
gem "google-cloud-container", path: "google-cloud-container"
gem "google-cloud-datastore", path: "google-cloud-datastore"
gem "google-cloud-dialogflow", path: "google-cloud-dialogflow"
gem "google-cloud-dlp", path: "google-cloud-dlp"
gem "google-cloud-dns", path: "google-cloud-dns"
gem "google-cloud-error_reporting", path: "google-cloud-error_reporting"
gem "google-cloud-firestore", path: "google-cloud-firestore"
gem "google-cloud-language", path: "google-cloud-language"
gem "google-cloud-logging", path: "google-cloud-logging"
gem "google-cloud-monitoring", path: "google-cloud-monitoring"
gem "google-cloud-os_login", path: "google-cloud-os_login"
gem "google-cloud-pubsub", path: "google-cloud-pubsub"
gem "google-cloud-resource_manager", path: "google-cloud-resource_manager"
gem "google-cloud-spanner", path: "google-cloud-spanner"
gem "google-cloud-speech", path: "google-cloud-speech"
gem "google-cloud-storage", path: "google-cloud-storage"
gem "google-cloud-tasks", path: "google-cloud-tasks"
gem "google-cloud-trace", path: "google-cloud-trace"
gem "google-cloud-translate", path: "google-cloud-translate"
gem "google-cloud-vision", path: "google-cloud-vision"
gem "google-cloud-video_intelligence", path: "google-cloud-video_intelligence"
gem "google-cloud", path: "google-cloud"
gem "gcloud", path: "gcloud"
gem "stackdriver-core", path: "stackdriver-core"
gem "google-cloud-redis", path: "google-cloud-redis"

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.2.0")
  gem "stackdriver", path: "stackdriver"
  gem "google-cloud-debugger", path: "google-cloud-debugger"
end

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.1")
  # WORKAROUND: builds are failing on Ruby 2.0.
  # We think this is because of a bug in Bundler 1.6.
  # Specify a viable version to allow the build to succeed.
  gem "jwt", "~> 1.5"
  gem "kramdown", "< 1.17.0" # Error in yard with 1.17.0
end

# WORKAROUND: builds are having problems since the release of 3.0.0
# pin to the last known good version
gem "public_suffix", "~> 2.0"

# TEMP: nokogiri (a dependency of rails) 1.7 requires Ruby 2.1 or later.
# Since we're still testing on Ruby 2.0, pin nokogiri to 1.6 for now.
gem "nokogiri", "~> 1.6.8"
