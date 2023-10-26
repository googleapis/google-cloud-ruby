require File.expand_path("lib/google/cloud/gaming/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name = "google-cloud-gaming-v1"
  gem.version = Google::Cloud::Gaming::V1::VERSION
  gem.authors = ["Google LLC"]
  gem.email = "googleapis-packages@google.com"
  gem.description =
    "This gem is obsolete because the related Google backend is turned down. " \
    "For more information, see https://cloud.google.com/terms/deprecation."
  gem.summary = "This gem is obsolete because the related backend is turned down."
  gem.post_install_message = <<~MESSAGE

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    The google-cloud-gaming-v1 gem is OBSOLETE.
    For more information, see:
    https://cloud.google.com/terms/deprecation
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  MESSAGE
  gem.homepage = "https://github.com/googleapis/google-cloud-ruby"
  gem.license = "Apache-2.0"
  gem.platform = Gem::Platform::RUBY
  gem.files = ["README.md", "LICENSE.md", "lib/google/cloud/gaming/v1/version.rb"]
  gem.require_paths = ["lib"]
  gem.required_ruby_version = ">= 2.0"
end
