require File.expand_path("lib/google/cloud/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud"
  gem.version       = Google::Cloud::VERSION

  gem.authors       = ["Mike Moore", "Chris Smith"]
  gem.email         = ["mike@blowmage.com", "quartzmo@gmail.com"]
  gem.description   = "google-cloud is the official library for Google Cloud Platform APIs."
  gem.summary       = "API Client library for Google Cloud"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "CONTRIBUTING.md", "CODE_OF_CONDUCT.md", "LICENSE",
                       ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.4"


  gem.add_dependency "google-cloud-asset", "~> 0.1"
  gem.add_dependency "google-cloud-bigquery", "~> 1.1"
  gem.add_dependency "google-cloud-bigquery-data_transfer", "~> 0.1"
  gem.add_dependency "google-cloud-bigtable", "~> 1.0"
  gem.add_dependency "google-cloud-container", "~> 0.1"
  gem.add_dependency "google-cloud-dataproc", "~> 0.1"
  gem.add_dependency "google-cloud-datastore", "~> 1.4"
  gem.add_dependency "google-cloud-dialogflow", "~> 0.1"
  gem.add_dependency "google-cloud-dlp", "~> 0.4"
  gem.add_dependency "google-cloud-dns", "~> 0.28"
  gem.add_dependency "google-cloud-error_reporting", "~> 0.30"
  gem.add_dependency "google-cloud-firestore", "~> 1.0"
  gem.add_dependency "google-cloud-kms", "~> 1.0"
  gem.add_dependency "google-cloud-language", "~> 0.30"
  gem.add_dependency "google-cloud-logging", "~> 1.5"
  gem.add_dependency "google-cloud-monitoring", "~> 0.28"
  gem.add_dependency "google-cloud-os_login", "~> 0.1"
  gem.add_dependency "google-cloud-phishing_protection", "~> 0.1"
  gem.add_dependency "google-cloud-pubsub", "~> 1.0"
  gem.add_dependency "google-cloud-recaptcha_enterprise", "~> 0.1"
  gem.add_dependency "google-cloud-redis", "~> 0.2"
  gem.add_dependency "google-cloud-resource_manager", "~> 0.29"
  gem.add_dependency "google-cloud-scheduler", "~> 1.0"
  gem.add_dependency "google-cloud-security_center", "~> 0.1"
  gem.add_dependency "google-cloud-spanner", "~> 1.3"
  gem.add_dependency "google-cloud-speech", "~> 0.29"
  gem.add_dependency "google-cloud-storage", "~> 1.10"
  gem.add_dependency "google-cloud-talent", "~> 0.1"
  gem.add_dependency "google-cloud-tasks", "~> 1.0"
  gem.add_dependency "google-cloud-text_to_speech", "~> 0.1"
  gem.add_dependency "google-cloud-trace", "~> 0.31"
  gem.add_dependency "google-cloud-translate", "~> 2.0"
  gem.add_dependency "google-cloud-video_intelligence", "~> 2.0"
  gem.add_dependency "google-cloud-vision", "~> 0.28"

  gem.add_development_dependency "autotest-suffix", "~> 1.1"
  gem.add_development_dependency "google-style", "~> 1.24.0"
  gem.add_development_dependency "minitest", "~> 5.10"
  gem.add_development_dependency "minitest-autotest", "~> 1.0"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
  gem.add_development_dependency "yard-doctest", "~> 0.1.13"

  gem.post_install_message = <<~POSTINSTALL
    ------------------------------
    Thank you for installing Google Cloud!

    IMPORTANT NOTICE:
    The google-cloud gem contains all the google-cloud-* gems.
    Instead of depending on this gem, we encourage you to install just
    the individual gems needed for your project.
    ------------------------------
  POSTINSTALL
end
