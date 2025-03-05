# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/maps/fleet_engine/delivery/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-maps-fleet_engine-delivery"
  gem.version       = Google::Maps::FleetEngine::Delivery::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Enables Fleet Engine for access to the On Demand Rides and Deliveries and Last Mile Fleet Solution APIs. Customer's use of Google Maps Content in the Cloud Logging Services is subject to the Google Maps Platform Terms of Service located at https://cloud.google.com/maps-platform/terms."
  gem.summary       = "Enables Fleet Engine for access to the On Demand Rides and Deliveries and Last Mile Fleet Solution APIs. Customer's use of Google Maps Content in the Cloud Logging Services is subject to the Google Maps Platform Terms of Service located at https://cloud.google.com/maps-platform/terms."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-maps-fleet_engine-delivery-v1", ">= 0.0", "< 2.a"
end
