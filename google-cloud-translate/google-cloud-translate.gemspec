require File.expand_path("lib/google/cloud/translate/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-translate"
  gem.version       = Google::Cloud::Translate::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "google-cloud-translate is the official library for Cloud Translation API."
  gem.summary       = "API Client library for Cloud Translation API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-translate"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["OVERVIEW.md", "AUTHENTICATION.md", "CONTRIBUTING.md", "TROUBLESHOOTING.md", "CHANGELOG.md",
                       "CODE_OF_CONDUCT.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.4"

  gem.post_install_message = <<~POSTINSTALL
    The 2.0 release introduces breaking changes by defaulting to a
    new generated v3 API client. This gem continues to contain the
    legacy hand-written v2 client for backward compatibility aside
    from the default client constructor.

    For more details please visit the 2.0.0 CHANGELOG:
    https://googleapis.dev/ruby/google-cloud-translate/v2.0.0/file.CHANGELOG.html#2_0_0___2019-10-28
  POSTINSTALL

  gem.add_dependency "faraday", ">= 0.17.3", "< 2.0"
  gem.add_dependency "google-cloud-core", "~> 1.2"
  gem.add_dependency "google-gax", "~> 1.8"
  gem.add_dependency "googleapis-common-protos", ">= 1.3.9", "< 2.0"
  gem.add_dependency "googleapis-common-protos-types", ">= 1.0.4", "< 2.0"

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
end
