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
require "googleauth"

module Gcloud
  ##
  # Represents the Oauth2 signing logic.
  # This class is intended to be inherited by API-specific classes
  # which overrides the SCOPE constant.
  class Credentials #:nodoc:
    TOKEN_CREDENTIAL_URI = "https://accounts.google.com/o/oauth2/token"
    AUDIENCE = "https://accounts.google.com/o/oauth2/token"
    SCOPE = []
    PATH_ENV_VARS = ["GOOGLE_CLOUD_KEYFILE"]
    JSON_ENV_VARS = ["GOOGLE_CLOUD_KEYFILE_JSON"]
    DEFAULT_PATHS = ["~/.config/gcloud/application_default_credentials.json"]

    attr_accessor :client

    ##
    # Delegate client methods to the client object.
    extend Forwardable
    def_delegators :@client,
                   :token_credential_uri, :audience,
                   :scope, :issuer, :signing_key

    def initialize keyfile, options = {}
      verify_keyfile_provided! keyfile
      if keyfile.is_a? Signet::OAuth2::Client
        @client = keyfile
      elsif keyfile.is_a? Hash
        @client = init_client keyfile, options
      else
        verify_keyfile_exists! keyfile
        @client = init_client JSON.parse(::File.read(keyfile)), options
      end
      @client.fetch_access_token!
    end

    # rubocop:disable all
    # Disabled rubocop because this is intentionally complex.

    ##
    # Returns the default credentials.
    #
    def self.default
      env  = ->(v) { ENV[v] }
      json = ->(v) { JSON.parse ENV[v] rescue nil unless ENV[v].nil? }
      path = ->(p) { ::File.file? p }

      # First try to find keyfile file from environment variables.
      self::PATH_ENV_VARS.map(&env).reject(&:nil?).select(&path).each do |file|
        return new file
      end
      # Second try to find keyfile json from environment variables.
      self::JSON_ENV_VARS.map(&json).reject(&:nil?).each do |hash|
        return new hash
      end
      # Third try to find keyfile file from known file paths.
      self::DEFAULT_PATHS.select(&path).each do |file|
        return new file
      end
      # Finally get instantiated client from Google::Auth.
      client = Google::Auth.get_application_default self::SCOPE
      new client
    end

    # rubocop:enable all

    protected

    ##
    # Verify that the keyfile argument is provided.
    def verify_keyfile_provided! keyfile
      fail "You must provide a keyfile to connect with." if keyfile.nil?
    end

    ##
    # Verify that the keyfile argument is a file.
    def verify_keyfile_exists! keyfile
      exists = ::File.file? keyfile
      fail "The keyfile '#{keyfile}' is not a valid file." unless exists
    end

    ##
    # Initializes the Signet client.
    def init_client keyfile, options
      client_opts = client_options keyfile, options
      Signet::OAuth2::Client.new client_opts
    end

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

    def client_options keyfile, options
      # Turn keys to strings
      options = stringify_hash_keys options
      # Constructor options override default options
      options = default_options.merge options
      # Keyfile options override everything
      options = options.merge keyfile

      # client options for initializing signet client
      { token_credential_uri: options["token_credential_uri"],
        audience: options["audience"],
        scope: options["scope"],
        issuer: options["client_email"],
        signing_key: OpenSSL::PKey::RSA.new(options["private_key"]) }
    end
  end
end
