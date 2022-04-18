require File.expand_path("lib/gcloud/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "gcloud"
  gem.version       = Gcloud::GCLOUD_VERSION

  gem.authors       = ["Mike Moore", "Chris Smith"]
  gem.email         = ["mike@blowmage.com", "quartzmo@gmail.com"]
  gem.description   = "gcloud is the legacy support library for the new google-cloud library."
  gem.summary       = "API Client library for Google Cloud"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby/tree/master/gcloud"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "CONTRIBUTING.md", "CODE_OF_CONDUCT.md", "LICENSE",
                       ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.4"

  gem.add_dependency "google-cloud", "~> 0.23"

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

  gem.post_install_message = "gcloud is now google-cloud, please change the gem name in your dependencies"
end
