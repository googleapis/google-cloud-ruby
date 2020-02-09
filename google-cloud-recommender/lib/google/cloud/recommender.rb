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


require "google-cloud-recommender"

module Google
  module Cloud
    ##
    # Deliver highly personalized product recommendations at scale.
    module Recommender
      ##
      # Create a new `Recommender::Client` object.
      #
      # @param version [String, Symbol] The API version to create the client instance. Optional. If not provided
      #   defaults to `:v1`, which will return an instance of
      #   [Google::Cloud::Recommender::V1::Recommender::Client](https://googleapis.dev/ruby/google-cloud-recommender-v1/latest/Google/Cloud/Recommender/V1/Recommender/Client.html).
      #
      # @return [Recommender::Client] A client object for the specified version.
      #
      def self.recommender_service version: :v1, &block
        require "google/cloud/recommender/#{version.to_s.downcase}"

        package_name = Google::Cloud::Recommender
                       .constants
                       .select { |sym| sym.to_s.downcase == version.to_s.downcase.tr("_", "") }
                       .first
        package_module = Google::Cloud::Recommender.const_get package_name
        package_module.const_get(:Recommender).const_get(:Client).new(&block)
      end

      ##
      # Configure the recommender library.
      #
      # The following recommender configuration parameters are supported:
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
      # @return [Google::Cloud::Config] The configuration object the Google::Cloud::Recommender library uses.
      #
      def self.configure
        yield Google::Cloud.configure.recommender if block_given?

        Google::Cloud.configure.recommender
      end
    end
  end
end
