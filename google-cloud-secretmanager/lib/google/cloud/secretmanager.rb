# Copyright 2019 Google LLC
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


require "google-cloud-secretmanager"

module Google
  module Cloud
    ##
    # TODO
    module SecretManager
      ##
      # TODO
      def self.new version: :v1beta1, service: :secret_manager_service, &block
        require "google/cloud/secretmanager/#{version.to_s.downcase}"

        package_name = Google::Cloud::SecretManager
                       .constants
                       .select { |sym| sym.to_s.downcase == version.to_s.downcase.tr("_", "") }
                       .first
        package_module = Google::Cloud::SecretManager.const_get package_name

        service_name = package_module
                       .constants
                       .select { |sym| sym.to_s.downcase == service.to_s.downcase.tr("_", "") }
                       .first
        service_module = package_module.const_get service_name

        service_module.const_get("Client").new(&block)
      end

      ##
      # Configure the Google Secret Manager library.
      #
      # The following Secret Manager configuration parameters are supported:
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
      # @return [Google::Cloud::Config] The configuration object the Google::Cloud::SecretManager library uses.
      #
      def self.configure
        yield Google::Cloud.configure.secretmanager if block_given?

        Google::Cloud.configure.secretmanager
      end
    end
  end
end
