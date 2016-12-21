# Copyright 2016 Google Inc. All rights reserved.
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

require "google/cloud/core/environment"
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
      # The following Rails configuration options are recognized.
      #
      # ```ruby
      # config.google_cloud.use_trace = true | false
      # ```
      #
      # Normally, tracing is activated when `RAILS_ENV` is set to `production`
      # and credentials are available. You can override this and enable tracing
      # in other environments by setting `use_trace` explicitly.
      #
      # ```ruby
      # config.google_cloud.keyfile = "path/to/file"
      # ```
      #
      # If your application is running on Google Cloud Platform, it will
      # automatically use credentials available to your project. However, if
      # you are running an application locally or on a different hosting
      # provider, you may provide a path to your credentials file using this
      # configuration.
      #
      # ```ruby
      # config.google_cloud.project_id = "my-project-id"
      # ```
      #
      # If your application is running on Google Cloud Platform, it will
      # automatically select the project under which it is running. However, if
      # you are running an application locally or on a different hosting
      # provider, or if you want to log traces to a different project than you
      # are using to host your application, you may provide the project ID.
      #
      # ```ruby
      # config.google_cloud.trace.notifications = ["event1", "event2"]
      # ```
      #
      # By default, this Railtie subscribes to ActiveSupport notifications
      # emitted by ActiveRecord queries, rendering, and emailing functions.
      # See {DEFAULT_NOTIFICATIONS}. If you want to customize the list of
      # notification types, edit the notifications configuration.
      #
      # ```ruby
      # config.google_cloud.trace.max_data_length = 1024
      # ```
      #
      # The maximum length of span properties recorded with ActiveSupport
      # notification events. Any property value larger than this length is
      # truncated.
      #
      # ```ruby
      # config.google_cloud.trace.capture_stack = true | false
      # ```
      #
      # Whether to capture the call stack with each trace span. Default is
      # false.
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
          if Google::Cloud::Trace::Railtie.use_trace? app.config
            Google::Cloud::Trace::Railtie.init_trace app
          end
        end

        ##
        # Determine whether to use Stackdriver Trace or not.
        #
        # Returns true if valid GCP project_id and keyfile are provided and
        # either Rails is in "production" environment or
        # config.google_cloud.use_trace is explicitly true. Otherwise false.
        #
        # @param [Rails::Railtie::Configuration] config The
        #     Rails.application.config
        #
        # @return [Boolean] Whether to use Stackdriver Trace
        #
        def self.use_trace? config
          gcp_config = config.google_cloud

          # Return false if config.google_cloud.use_trace is
          # explicitly false
          return false if gcp_config.key?(:use_trace) &&
                          !gcp_config.use_trace

          # Try authenticate authorize client API. Return false if unable to
          # authorize.
          keyfile = gcp_config.trace.keyfile || gcp_config.keyfile
          begin
            Google::Cloud::Trace::Credentials.credentials_with_scope keyfile
          rescue Exception => e
            warn "Unable to initialize Google::Cloud::Trace due " \
              "to authorization error: #{e.message}"
            return false
          end

          if project_id(config).to_s.empty?
            warn "Google::Cloud::Trace is not activated due to empty project_id"
            return false
          end

          # Otherwise return true if Rails is running in production or
          # config.google_cloud.use_trace is explicitly true
          Rails.env.production? ||
            (gcp_config.key?(:use_trace) && gcp_config.use_trace)
        end

        ##
        # Return the effective project ID for this app, given a Rails config.
        #
        # @param [Rails::Railtie::Configuration] config The
        #     Rails.application.config
        # @return [String] The project ID, or nil if not found.
        #
        def self.project_id config
          config.google_cloud.trace.project_id ||
            config.google_cloud.project_id ||
            ENV["TRACE_PROJECT"] ||
            ENV["GOOGLE_CLOUD_PROJECT"] ||
            Google::Cloud::Core::Environment.project_id
        end

        ##
        # Initialize trace integration for Rails. Sets up the configuration,
        # adds and configures middleware, and installs notifications.
        #
        # @private
        #
        def self.init_trace app
          gcp_config = app.config.google_cloud
          trace_config = gcp_config.trace
          project_id = trace_config.project_id || gcp_config.project_id
          keyfile = trace_config.keyfile || gcp_config.keyfile

          tracer = Google::Cloud::Trace.new project: project_id,
                                            keyfile: keyfile

          app.middleware.insert_before \
            Rack::Runtime,
            Google::Cloud::Trace::Middleware,
            service: tracer.service,
            capture_stack: trace_config.capture_stack

          trace_config.notifications.each do |type|
            Google::Cloud::Trace::Notifications.instrument \
              type,
              max_length: trace_config.max_data_length,
              capture_stack: trace_config.capture_stack
          end
        end
      end
    end
  end
end
