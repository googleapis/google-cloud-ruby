# Copyright 2015 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "google/cloud/dns"

if ENV["GCLOUD_TEST_DNS_DOMAIN"]
  # Create prefix for zone names
  require "securerandom"
  $dns_nonce = SecureRandom.hex 4
  $dns_prefix = "gcloud-#{$dns_nonce}".downcase.gsub "_", "-"

  # Create shared dns object so we don't create new for each test
  $dns = Google::Cloud.new.dns retries: 10
  # Create random subdomain to use in tests
  # We do this so we can run multiple build concurrently
  $dns_domain = "#{$dns_nonce}.#{ENV["GCLOUD_TEST_DNS_DOMAIN"]}"

  module Acceptance
    ##
    # Test class for running against a DNS instance.
    # Ensures that there is an active connection for the tests to use.
    #
    # This class can be used with the spec DSL.
    # To do so, add :dns to describe:
    #
    #   describe "My DNS Test", :dns do
    #     it "does a thing" do
    #       your.code.must_be :thing?
    #     end
    #   end
    class DnsTest < Minitest::Test
      attr_accessor :dns
      attr_accessor :prefix

      ##
      # Setup project based on available ENV variables
      def setup
        @dns = $dns
        @prefix = $dns_prefix

        refute_nil @dns, "You do not have an active dns to run the tests."
        refute_nil @prefix, "You do not have an dns prefix to name the datasets and tables with."

        super
      end

      # Add spec DSL
      extend Minitest::Spec::DSL

      # Register this spec type for when :dns is used.
      register_spec_type(self) do |desc, *addl|
        addl.include? :dns
      end

      def self.run_one_method klass, method_name, reporter
        result = nil
        reporter.prerecord klass, method_name
        (1..3).each do |try|
          result = Minitest.run_one_method(klass, method_name)
          break if (result.passed? || result.skipped?)
          puts "Retrying #{klass}##{method_name} (#{try})"
        end
        reporter.record result
      end
    end
  end

  def clean_up_dns_zones
    puts "Cleaning up dns zones after tests."
    $dns.zones.all do |zone|
      if zone.name.start_with? $dns_prefix
        zone.delete force: true
      end
    end
  rescue => e
    puts "Error while cleaning up dns zones after tests.\n\n#{e}"
  end

  Minitest.after_run do
    clean_up_dns_zones
  end
else
  puts "No domain name found for the DNS acceptance tests."
end
