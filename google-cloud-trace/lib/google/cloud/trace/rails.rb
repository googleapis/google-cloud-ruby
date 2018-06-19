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

require "google/cloud/env"
require "google/cloud/trace"

module Google
  module Cloud
    module Trace
      ##
      # # Rails integration for Stackdriver Trace
      #
      # This Railtie is a drop-in Stackdriver Trace instrumentation plugin
      # for Ruby on Rails applications. If present, it automatically
      # instruments your Rails app to record performance traces and cause them
      # to appear on your Stackdriver console.
      #
      # ## Installation
      #
      # To install this plugin, the gem `google-cloud-trace` must be in your
      # Gemfile. You also must add the following line to your `application.rb`
      # file:
      #
      # ```ruby
      # require "google/cloud/trace/rails"
      # ```
      #
      # If you include the `stackdriver` gem in your Gemfile, the above is done
      # for you automatically, and you do not need to edit your
      # `application.rb`.
      #
      # ## Configuration
      #
      # See the [Configuration
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/stackdriver/guides/instrumentation_configuration)
      # on how to configure the Railtie and Middleware.
      #
      # ## Measuring custom functionality
      #
      # To add a custom measurement to a request trace, use the classes
      # provided in this library. Below is an example to get you started.
      #
      # ```ruby
      # class MyController < ApplicationController
      #   def index
      #     Google::Cloud::Trace.in_span "Sleeping on the job!" do
      #       sleep rand
      #     end
      #     render plain: "Hello World!"
      #   end
      # end
      # ```
      #
      class Railtie < ::Rails::Railtie
        ##
        # The default list of ActiveSupport notification types to include in
        # traces.
        #
        DEFAULT_NOTIFICATIONS = [
          "sql.active_record",
          "render_template.action_view",
          "send_file.action_controller",
          "send_data.action_controller",
          "deliver.action_mailer"
        ].freeze

        unless config.respond_to? :google_cloud
          config.google_cloud = ActiveSupport::OrderedOptions.new
        end
        config.google_cloud.trace = ActiveSupport::OrderedOptions.new
        config.google_cloud.trace.notifications = DEFAULT_NOTIFICATIONS.dup
        config.google_cloud.trace.max_data_length =
          Google::Cloud::Trace::Notifications::DEFAULT_MAX_DATA_LENGTH

        initializer "Google.Cloud.Trace" do |app|
          self.class.consolidate_rails_config app.config

          self.class.init_middleware app if Cloud.configure.use_trace
        end

        ##
        # Initialize trace integration for Rails. Sets up the configuration,
        # adds and configures middleware, and installs notifications.
        #
        # @private
        #
        def self.init_middleware app
          trace_config = Trace.configure

          app.middleware.insert_before Rack::Runtime,
                                       Google::Cloud::Trace::Middleware

          trace_config.notifications.each do |type|
            Google::Cloud::Trace::Notifications.instrument \
              type,
              max_length: trace_config.max_data_length,
              capture_stack: trace_config.capture_stack
          end
        end

        ##
        # @private Consolidate Rails configuration into Trace instrumentation
        # configuration. Also consolidate the `use_trace` setting by verifying
        # credentials and Rails environment. The `use_trace` setting will be
        # true if credentials are valid, and the setting is manually set to
        # true or Rails is in production environment.
        #
        # @param [Rails::Railtie::Configuration] config The
        #   Rails.application.config
        #
        def self.consolidate_rails_config config
          merge_rails_config config

          init_default_config

          # Done if Google::Cloud.configure.use_trace is explicitly false
          return if Google::Cloud.configure.use_trace == false

          # Verify credentials and set use_error_reporting to false if
          # credentials are invalid
          unless valid_credentials? Trace.configure.project_id,
                                    Trace.configure.credentials
            Cloud.configure.use_trace = false
            return
          end

          # Otherwise set use_trace to true if Rails is running in production
          Google::Cloud.configure.use_trace ||= Rails.env.production?
        end

        # rubocop:disable all

        ##
        # @private Merge Rails configuration into Trace instrumentation
        # configuration.
        def self.merge_rails_config rails_config
          gcp_config = rails_config.google_cloud
          trace_config = gcp_config.trace

          if Cloud.configure.use_trace.nil?
            Cloud.configure.use_trace = trace_config.use_trace
          end
          Trace.configure do |config|
            config.project_id ||= (config.project ||
              trace_config.project_id || trace_config.project ||
              gcp_config.project_id || gcp_config.project)
            config.credentials ||= (config.keyfile ||
              trace_config.credentials || trace_config.keyfile ||
              gcp_config.credentials || gcp_config.keyfile)
            config.notifications ||= trace_config.notifications
            config.max_data_length ||= trace_config.max_data_length
            if config.capture_stack.nil?
              config.capture_stack = trace_config.capture_stack
            end
            config.sampler ||= trace_config.sampler
            config.span_id_generator ||= trace_config.span_id_generator
          end
        end

        # rubocop:enable all

        ##
        # Fallback to default config values if config parameters not provided.
        def self.init_default_config
          Trace.configure.project_id ||= Trace.default_project_id
        end

        ##
        # @private Verify credentials
        def self.valid_credentials? project_id, credentials
          begin
            # if credentials is nil, get default
            credentials ||= Trace::Credentials.default
            # only create a new Credentials object if the val isn't one already
            unless credentials.is_a? Google::Auth::Credentials
              # if credentials is not a Credentials object, create one
              Trace::Credentials.new credentials
            end
          rescue Exception => e
            STDOUT.puts "Note: Google::Cloud::Trace is disabled because " \
              "it failed to authorize with the service. (#{e.message})"
            return false
          end

          if project_id.to_s.empty?
            STDOUT.puts "Note: Google::Cloud::Trace is disabled because " \
              "the project ID could not be determined."
            return false
          end

          true
        end

        private_class_method :merge_rails_config,
                             :init_default_config,
                             :valid_credentials?
      end
    end
  end
end
