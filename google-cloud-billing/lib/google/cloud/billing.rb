# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google-cloud-billing"

module Google
  module Cloud
    ##
    # Allows developers to manage billing for their Google Cloud Platform projects programmatically.
    module Billing
      ##
      # Create a new `CloudBilling::Client` object.
      #
      # @param version [String, Symbol] The API version to create the client instance. Optional. If not provided
      #   defaults to `:v1`, which will return an instance of
      #   [Google::Cloud::Billing::V1::CloudBilling::Client](https://googleapis.dev/ruby/google-cloud-billing-v1/latest/Google/Cloud/Billing/V1/CloudBilling/Client.html).
      #
      # @return [CloudBilling::Client] A client object for the specified version.
      #
      def self.cloud_billing_service version: :v1beta1, &block
        require "google/cloud/billing/#{version.to_s.downcase}"

        package_name = Google::Cloud::Billing
                       .constants
                       .select { |sym| sym.to_s.downcase == version.to_s.downcase.tr("_", "") }
                       .first
        package_module = Google::Cloud::Billing.const_get package_name
        package_module.const_get(:CloudBilling).const_get(:Client).new(&block)
      end

      ##
      # Create a new `CloudCatalog::Client` object.
      #
      # @param version [String, Symbol] The API version to create the client instance. Optional. If not provided
      #   defaults to `:v1`, which will return an instance of
      #   [Google::Cloud::Billing::V1::CloudCatalog::Client](https://googleapis.dev/ruby/google-cloud-billing-v1/latest/Google/Cloud/Billing/V1/CloudCatalog/Client.html).
      #
      # @return [CloudCatalog::Client] A client object for the specified version.
      #
      def self.cloud_catalog_service version: :v1beta1, &block
        require "google/cloud/billing/#{version.to_s.downcase}"

        package_name = Google::Cloud::Billing
                       .constants
                       .select { |sym| sym.to_s.downcase == version.to_s.downcase.tr("_", "") }
                       .first
        package_module = Google::Cloud::Billing.const_get package_name
        package_module.const_get(:CloudCatalog).const_get(:Client).new(&block)
      end

      ##
      # Configure the billing library.
      #
      # The following billing configuration parameters are supported:
      #
      # * `credentials` - (String, Hash, Google::Auth::Credentials) The path to the keyfile as a String, the contents of
      #   the keyfile as a Hash, or a Google::Auth::Credentials object.
      # * `lib_name` (String)
      # * `lib_version` (String)
      # * `interceptors` (Array)
      # * `timeout` - (Integer) Default timeout to use in requests.
      # * `metadata` (Hash)
      # * `retry_policy` (Hash, Proc)
      #
      # @return [Google::Cloud::Config] The configuration object the Google::Cloud::Billing library uses.
      #
      def self.configure
        yield Google::Cloud.configure.billing if block_given?

        Google::Cloud.configure.billing
      end
    end
  end
end
