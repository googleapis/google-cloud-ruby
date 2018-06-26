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


require "google/cloud/config"
require "google/cloud/core/version"

##
# # Google Cloud
#
# The google-cloud library is the official library for interacting with Google
# Cloud Platform. Google Cloud Platform is a set of modular cloud-based services
# that allow you to create anything from simple websites to complex
# applications.
#
# The goal of google-cloud is to provide an API that is comfortable to
# Rubyists. Your authentication credentials are detected automatically in
# Google Cloud Platform environments such as Google Compute Engine, Google
# App Engine and Google Kubernetes Engine. In other environments you can
# configure authentication easily, either directly in your code or via
# environment variables. Read more about the options for connecting in the
# [Authentication
# Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
#
# You can learn more about various options for connection on the [Authentication
# Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
#
module Google
  module Cloud
    ##
    # Creates a new object for connecting to Google Cloud.
    #
    # For more information on connecting to Google Cloud see the [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # @param [String] project_id Project identifier for the service you are
    #   connecting to.
    # @param [String, Hash, Google::Auth::Credentials] credentials The path to
    #   the keyfile as a String, the contents of the keyfile as a Hash, or a
    #   Google::Auth::Credentials object.
    # @param [Integer] retries Number of times to retry requests on server
    #   error. The default value is `3`. Optional.
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    #
    # @return [Google::Cloud]
    #
    # @example
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   datastore = gcloud.datastore
    #   pubsub  = gcloud.pubsub
    #   storage = gcloud.storage
    #
    def self.new project_id = nil, credentials = nil, retries: nil, timeout: nil
      gcloud = Object.new
      gcloud.instance_variable_set :@project, project_id
      gcloud.instance_variable_set :@keyfile, credentials
      gcloud.instance_variable_set :@retries, retries
      gcloud.instance_variable_set :@timeout, timeout
      gcloud.extend Google::Cloud
      gcloud
    end

    ##
    # Configure the default parameter for Google::Cloud. The values defined on
    # this top level will be shared across all Google::Cloud libraries, which
    # may also add fields to this object or add sub configuration options under
    # this object.
    #
    # Possible configuration parameters:
    #
    # * `project_id`: The Google Cloud Project ID. Automatically discovered
    #                 when running from GCP environments.
    # * `credentials`: The service account JSON file path. Automatically
    #                  discovered when running from GCP environments.
    #
    # @return [Google::Cloud::Config] The top-level configuration object for
    #     Google::Cloud libraries.
    #
    def self.configure
      @config ||= Config.create

      yield @config if block_given?

      @config
    end

    ##
    # Initialize toplevel configuration
    # @private
    #
    def self.init_configuration
      configure do |config|
        default_project = Google::Cloud::Config.deferred do
          ENV["GOOGLE_CLOUD_PROJECT"] || ENV["GCLOUD_PROJECT"]
        end
        default_creds = Google::Cloud::Config.deferred do
          Google::Cloud::Config.credentials_from_env \
            "GOOGLE_CLOUD_CREDENTIALS", "GOOGLE_CLOUD_CREDENTIALS_JSON",
            "GOOGLE_CLOUD_KEYFILE", "GOOGLE_CLOUD_KEYFILE_JSON",
            "GCLOUD_KEYFILE", "GCLOUD_KEYFILE_JSON"
        end

        config.add_field! :project_id, default_project,
                          match: String, allow_nil: true
        config.add_alias! :project, :project_id
        config.add_field! :credentials, default_creds, match: Object
        config.add_alias! :keyfile, :credentials
      end
    end

    # In June, 2018, set supported version to 2.3 and recommended to 2.4.
    # Thereafter, follow the MRI support schedule: supported means non-EOL,
    # and recommended means in normal (rather than security) maintenance.
    # See https://www.ruby-lang.org/en/downloads/branches/

    ##
    # Minimum "supported" Ruby version (non-EOL)
    # @private
    #
    SUPPORTED_VERSION_THRESHOLD = "2.0".freeze

    ##
    # Minimum "recommended" Ruby version (normal maintenance)
    # @private
    #
    RECOMMENDED_VERSION_THRESHOLD = "2.3".freeze

    ##
    # Check Ruby version and emit a warning if it is old
    # @private
    #
    def self.warn_on_old_ruby_version \
        supported_version: SUPPORTED_VERSION_THRESHOLD,
        recommended_version: RECOMMENDED_VERSION_THRESHOLD
      return if ENV["GOOGLE_CLOUD_SUPPRESS_RUBY_WARNINGS"]
      cur_version = Gem::Version.new RUBY_VERSION
      if cur_version < Gem::Version.new(supported_version)
        warn_unsupported_ruby cur_version, recommended_version
      elsif cur_version < Gem::Version.new(recommended_version)
        warn_nonrecommended_ruby cur_version, recommended_version
      end
    rescue ArgumentError
      warn "Unable to determine current Ruby version."
    end

    ##
    # Print a warning for an EOL version of Ruby
    # @private
    #
    def self.warn_unsupported_ruby cur_version, recommended_version
      warn "WARNING: You are running Ruby #{cur_version}, which has reached" \
        " end-of-life and is no longer supported by Ruby Core."
      warn "The Google Cloud API clients work best on supported versions of" \
        " Ruby. It is strongly recommended that you upgrade to Ruby" \
        " #{recommended_version} or later."
      warn "See https://www.ruby-lang.org/en/downloads/branches/ for more" \
        " info on the Ruby maintenance schedule."
      warn "To suppress this message, set the" \
        " GOOGLE_CLOUD_SUPPRESS_RUBY_WARNINGS environment variable."
    end

    ##
    # Print a warning for a supported but nearing EOL version of Ruby
    # @private
    #
    def self.warn_nonrecommended_ruby cur_version, recommended_version
      warn "WARNING: You are running Ruby #{cur_version}, which is nearing" \
        " end-of-life."
      warn "The Google Cloud API clients work best on supported versions of" \
        " Ruby. Consider upgrading to Ruby #{recommended_version} or later."
      warn "See https://www.ruby-lang.org/en/downloads/branches/ for more" \
        " info on the Ruby maintenance schedule."
      warn "To suppress this message, set the" \
        " GOOGLE_CLOUD_SUPPRESS_RUBY_WARNINGS environment variable."
    end
  end
end

# Set the default top-level configuration
Google::Cloud.init_configuration

# Emit a warning if current Ruby is at or nearing end-of-life
Google::Cloud.warn_on_old_ruby_version

# Auto-load all Google Cloud service gems.
auto_load_files = if Gem.respond_to? :find_latest_files
                    Gem.find_latest_files "google-cloud-*.rb"
                  else
                    # Ruby 2.0 does not have Gem.find_latest_files
                    Gem.find_files "google-cloud-*.rb"
                  end
auto_load_files.each do |google_cloud_service|
  require google_cloud_service
end
