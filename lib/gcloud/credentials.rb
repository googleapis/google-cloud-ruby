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
require "forwardable"

module Gcloud
  ##
  # Represents the Oauth2 signing logic.
  # This class is intended to be inherited by API-specific classes
  # which overrides the SCOPE constant.
  class Credentials #:nodoc:
    TOKEN_CREDENTIAL_URI = "https://accounts.google.com/o/oauth2/token"
    AUDIENCE = "https://accounts.google.com/o/oauth2/token"
    SCOPE = []

    attr_accessor :client

    ##
    # Delegate client methods to the client object.
    extend Forwardable
    def_delegators :@client,
                   :token_credential_uri, :audience,
                   :scope, :issuer, :signing_key

    def initialize keyfile, options = {}
      if keyfile.nil?
        fail "You must provide a keyfile to connect with."
      elsif !::File.exist?(keyfile)
        fail "The keyfile '#{keyfile}' is not a valid file."
      end

      # Turn keys to strings
      options = stringify_hash_keys options
      # Constructor options override default options
      options = default_options.merge options
      # Keyfile options override everything
      options = options.merge JSON.parse(::File.read(keyfile))
      init_signet_client! options
    end

    protected

    ##
    # returns a new Hash with string keys instead of symbol keys.
    def stringify_hash_keys hash
      Hash[hash.map { |(k, v)| [k.to_s, v] }]
    end

    ##
    # The default options using the values in the constants.
    def default_options
      { "token_credential_uri" => self.class::TOKEN_CREDENTIAL_URI,
        "audience"             => self.class::AUDIENCE,
        "scope"                => self.class::SCOPE }
    end

    ##
    # Initializes the Signet client.
    def init_signet_client! options
      client_opts = {
        token_credential_uri: options["token_credential_uri"],
        audience: options["audience"],
        scope: options["scope"],
        issuer: options["client_email"],
        signing_key: OpenSSL::PKey::RSA.new(options["private_key"])
      }

      @client = Signet::OAuth2::Client.new client_opts
      @client.fetch_access_token!
    end
  end
end
