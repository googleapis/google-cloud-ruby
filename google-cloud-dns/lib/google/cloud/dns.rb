# Copyright 2015 Google LLC
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


require "google-cloud-dns"
require "google/cloud/dns/project"
require "google/cloud/config"
require "google/cloud/env"

module Google
  module Cloud
    ##
    # # Google Cloud DNS
    #
    # Google Cloud DNS is a high-performance, resilient, global DNS service that
    # provides a cost-effective way to make your applications and services
    # available to your users. This programmable, authoritative DNS service can
    # be used to easily publish and manage DNS records using the same
    # infrastructure relied upon by Google. To learn more, read [What is Google
    # Cloud DNS?](https://cloud.google.com/dns/what-is-cloud-dns).
    #
    # See {file:OVERVIEW.md Google Cloud DNS Overview}.
    #
    module Dns
      ##
      # Creates a new `Project` instance connected to the DNS service.
      # Each call creates a new connection.
      #
      # For more information on connecting to Google Cloud see the
      # [Authentication
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
      #
      # @param [String] project_id Identifier for a DNS project. If not present,
      #   the default project for the credentials is used.
      # @param [String, Hash, Google::Auth::Credentials] credentials The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Dns::Credentials})
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #
      #   The default scope is:
      #
      #   * `https://www.googleapis.com/auth/ndev.clouddns.readwrite`
      # @param [Integer] retries Number of times to retry requests on server
      #   error. The default value is `3`. Optional.
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      # @param [String] project Alias for the `project_id` argument. Deprecated.
      # @param [String] keyfile Alias for the `credentials` argument.
      #   Deprecated.
      #
      # @return [Google::Cloud::Dns::Project]
      #
      # @example
      #   require "google/cloud/dns"
      #
      #   dns = Google::Cloud::Dns.new(
      #           project_id: "my-dns-project",
      #           credentials: "/path/to/keyfile.json"
      #         )
      #
      #   zone = dns.zone "example-com"
      #
      def self.new project_id: nil, credentials: nil, scope: nil, retries: nil,
                   timeout: nil, project: nil, keyfile: nil
        project_id ||= (project || default_project_id)
        project_id = project_id.to_s # Always cast to a string
        raise ArgumentError, "project_id is missing" if project_id.empty?

        scope ||= configure.scope
        retries ||= configure.retries
        timeout ||= configure.timeout

        credentials ||= (keyfile || default_credentials(scope: scope))
        unless credentials.is_a? Google::Auth::Credentials
          credentials = Dns::Credentials.new credentials, scope: scope
        end

        Dns::Project.new(
          Dns::Service.new(
            project_id, credentials, retries: retries, timeout: timeout
          )
        )
      end

      ##
      # Configure the Google Cloud DNS library.
      #
      # The following DNS configuration parameters are supported:
      #
      # * `project_id` - (String) Identifier for a DNS project. (The
      #   parameter `project` is considered deprecated, but may also be used.)
      # * `credentials` - (String, Hash, Google::Auth::Credentials) The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Dns::Credentials}) (The
      #   parameter `keyfile` is considered deprecated, but may also be used.)
      # * `scope` - (String, Array<String>) The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      # * `retries` - (Integer) Number of times to retry requests on server
      #   error.
      # * `timeout` - (Integer) Default timeout to use in requests.
      #
      # @return [Google::Cloud::Config] The configuration object the
      #   Google::Cloud::Dns library uses.
      #
      def self.configure
        yield Google::Cloud.configure.dns if block_given?

        Google::Cloud.configure.dns
      end

      ##
      # @private Default project.
      def self.default_project_id
        Google::Cloud.configure.dns.project_id ||
          Google::Cloud.configure.project_id ||
          Google::Cloud.env.project_id
      end

      ##
      # @private Default credentials.
      def self.default_credentials scope: nil
        Google::Cloud.configure.dns.credentials ||
          Google::Cloud.configure.credentials ||
          Dns::Credentials.default(scope: scope)
      end
    end
  end
end
