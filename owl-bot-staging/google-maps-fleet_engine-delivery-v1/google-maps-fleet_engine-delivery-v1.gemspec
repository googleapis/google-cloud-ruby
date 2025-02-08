# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/maps/fleet_engine/delivery/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-maps-fleet_engine-delivery-v1"
  gem.version       = Google::Maps::FleetEngine::Delivery::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Enables Fleet Engine for access to the On Demand Rides and Deliveries and Last Mile Fleet Solution APIs. Customer's use of Google Maps Content in the Cloud Logging Services is subject to the Google Maps Platform Terms of Service located at https://cloud.google.com/maps-platform/terms. Note that google-maps-fleet_engine-delivery-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-maps-fleet_engine-delivery instead. See the readme for more details."
  gem.summary       = "Enables Fleet Engine for access to the On Demand Rides and Deliveries and Last Mile Fleet Solution APIs. Customer's use of Google Maps Content in the Cloud Logging Services is subject to the Google Maps Platform Terms of Service located at https://cloud.google.com/maps-platform/terms."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "gapic-common", ">= 0.25.0", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
  gem.add_dependency "google-geo-type", "> 0.0", "< 2.a"
end
