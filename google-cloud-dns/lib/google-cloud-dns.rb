# Copyright 2016 Google LLC
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

##
# This file is here to be autorequired by bundler, so that the Google::Cloud.dns
# and Google::Cloud#dns methods can be available, but the library and all
# dependencies won't be loaded until required and used.


gem "google-cloud-core"
require "google/cloud"
require "google/cloud/config"
require "googleauth"

module Google
  module Cloud
    ##
    # Creates a new object for connecting to the DNS service.
    # Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the
    # {file:AUTHENTICATION.md Authentication Guide}.
    #
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `https://www.googleapis.com/auth/ndev.clouddns.readwrite`
    # @param [Integer] retries Number of times to retry requests on server
    #   error. The default value is `3`. Optional.
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    #
    # @return [Google::Cloud::Dns::Project]
    #
    # @example
    #   require "google/cloud"
    #
    #   gcloud = Google::Cloud.new
    #   dns = gcloud.dns
    #   zone = dns.zone "example-com"
    #   zone.records.each do |record|
    #     puts record.name
    #   end
    #
    # @example The default scope can be overridden with the `scope` option:
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   dns_readonly = "https://www.googleapis.com/auth/ndev.clouddns.readonly"
    #   dns = gcloud.dns scope: dns_readonly
    #
    def dns scope: nil, retries: nil, timeout: nil
      Google::Cloud.dns @project, @keyfile, scope: scope,
                                            retries: (retries || @retries),
                                            timeout: (timeout || @timeout)
    end

    ##
    # Creates a new `Project` instance connected to the DNS service.
    # Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the
    # {file:AUTHENTICATION.md Authentication Guide}.
    #
    # @param [String] project_id Identifier for a DNS project. If not present,
    #   the default project for the credentials is used.
    # @param [String, Hash, Google::Auth::Credentials] credentials The path to
    #   the keyfile as a String, the contents of the keyfile as a Hash, or a
    #   Google::Auth::Credentials object. (See {Dns::Credentials})
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `https://www.googleapis.com/auth/ndev.clouddns.readwrite`
    # @param [Integer] retries Number of times to retry requests on server
    #   error. The default value is `3`. Optional.
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    #
    # @return [Google::Cloud::Dns::Project]
    #
    # @example
    #   require "google/cloud"
    #
    #   dns = Google::Cloud.dns "my-project", "/path/to/keyfile.json"
    #
    #   zone = dns.zone "example-com"
    #
    def self.dns project_id = nil, credentials = nil, scope: nil, retries: nil,
                 timeout: nil
      require "google/cloud/dns"
      Google::Cloud::Dns.new project_id: project_id, credentials: credentials,
                             scope: scope, retries: retries, timeout: timeout
    end
  end
end

# Set the default dns configuration
Google::Cloud.configure.add_config! :dns do |config|
  default_project = Google::Cloud::Config.deferred do
    ENV["DNS_PROJECT"]
  end
  default_creds = Google::Cloud::Config.deferred do
    Google::Cloud::Config.credentials_from_env(
      "DNS_CREDENTIALS", "DNS_CREDENTIALS_JSON",
      "DNS_KEYFILE", "DNS_KEYFILE_JSON"
    )
  end

  config.add_field! :project_id, default_project, match: String, allow_nil: true
  config.add_alias! :project, :project_id
  config.add_field! :credentials, default_creds,
                    match: [String, Hash, Google::Auth::Credentials],
                    allow_nil: true
  config.add_alias! :keyfile, :credentials
  config.add_field! :scope, nil, match: [String, Array]
  config.add_field! :retries, nil, match: Integer
  config.add_field! :timeout, nil, match: Integer
end
