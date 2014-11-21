# Copyright 2014 Google Inc. All rights reserved.
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

require "json"
require "signet/oauth_2/client"

module Gcloud
  module Datastore
    ##
    # Authentication credentials to Google Cloud.
    # The most common way to create this object is to provide the path
    # to the JSON keyfile downloaded from Google Cloud.
    #
    # https://developers.google.com/accounts/docs/application-default-credentials
    class Credentials #:nodoc:
      TOKEN_CREDENTIAL_URI = "https://accounts.google.com/o/oauth2/token"
      AUDIENCE = "https://accounts.google.com/o/oauth2/token"
      SCOPE = ["https://www.googleapis.com/auth/datastore",
               "https://www.googleapis.com/auth/userinfo.email"]

      ##
      # The Signet client used to sign HTTP Requests.
      attr_accessor :client #:nodoc:

      # Create a new Credential object.
      # This will raise if the JSON keyfile is incorrect.
      def initialize keyfile
        if keyfile.nil?
          fail KeyfileError, "You must provide a keyfile to connect with."
        elsif !File.exist?(keyfile)
          fail KeyfileError, "The keyfile '#{keyfile}' is not a valid file."
        end

        options = JSON.parse(File.read(keyfile))
        init_signet_client! options
      end

      ##
      # Sign Oauth2 API calls.
      def sign_http_request request #:nodoc:
        if @client
          @client.fetch_access_token! if @client.expired?
          @client.generate_authenticated_request request: request
        end
        request
      end

      protected

      ##
      # Initialize the Signet client.
      # Will raise if cannot acquire an access token.
      def init_signet_client! options
        client_opts = {
          token_credential_uri: TOKEN_CREDENTIAL_URI,
          audience: AUDIENCE,
          scope: SCOPE,
          issuer: options["client_email"],
          signing_key: OpenSSL::PKey::RSA.new(options["private_key"])
        }

        @client = Signet::OAuth2::Client.new client_opts
        @client.fetch_access_token!
      end
    end

    class Credentials
      ##
      # Represent the empty credentials, useful for connecting
      # to a local devserver.
      class Empty #:nodoc:
        def sign_http_request request
          request
        end
      end
    end
  end
end
