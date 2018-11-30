# -*- ruby -*-
# encoding: utf-8

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-vision"
  gem.version       = "0.32.1"

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "google-cloud-vision is the official library for Cloud Vision API."
  gem.summary       = "API Client library for Cloud Vision API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-vision"
  gem.license       = "Apache-2.0"

  gem.post_install_message =
    "The 0.32.0 release introduced breaking changes relative to the "\
    "previous release, 0.31.0. For more details and instructions to migrate "\
    "your code, please visit the migration guide: "\
    "https://cloud.google.com/vision/docs/ruby-client-migration."

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.0.0"

  gem.add_dependency "google-gax", "~> 1.3"

  gem.add_development_dependency "minitest", "~> 5.10"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "rubocop", "~> 0.59.2"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
end
