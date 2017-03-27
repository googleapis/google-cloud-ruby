# Copyright 2017 Google Inc. All rights reserved.
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


require "google-cloud-debugger"
require "google/cloud/debugger/project"

module Google
  module Cloud
    ##
    # # Stackdriver Debugger
    #
    # Stackdriver Debugger is a feature of the Google Cloud Platform that lets
    # you inspect the state of an application at any code location without using
    # logging statements and without stopping or slowing down your applications.
    # Your users are not impacted during debugging. Using the production
    # debugger you can capture the local variables and call stack and link it
    # back to a specific line location in your source code. You can use this to
    # analyze the production state of your application and understand the
    # behavior of your code in production.
    #
    # For general information about Stackdriver Debugger, read [Stackdriver
    # Debugger Documentation](https://cloud.google.com/debugger/docs/).
    #
    # The Stackdriver Debugger Ruby library, `google-cloud-debugger`, provides:
    #
    # *   Easy-to-use debugger instrumentation that reports state data, such as
    #     value of program variables and the call stack, to Stackdriver Debugger
    #     when the code at a breakpoint location is executed in your Ruby
    #     application. See the [instrumenting your app](#instrumenting-your-app)
    #     section for how to debug your application, in both development and
    #     production.
    # *   An idiomatic Ruby API for registerying debuggee application, and
    #     querying or manipulating breakpoints in registered Ruby debuggee
    #     application. See [Debugger API](#stackdriver-debugger-api) section for
    #     an introduction to Stackdriver Debugger API.
    #
    # ## Instrumenting Your App
    #
    # This instrumentation library provides the following features to help you
    # debug your applications in production:
    #
    # *   Automatic application registration. It facilitates multiple running
    #     instances of same version of application when hosted in production.
    # *   A background debugger agent that runs side-by-side with your
    #     application that automatically collects state data when code is
    #     executed at breakpoint locations.
    # *   A Rack middleware and Railtie that automatically manages the debugger
    #     agent for Ruby on Rails and other Rack-based Ruby applications.
    #
    # Other Stackdriver Debugger service features not covered by this
    # application instrumentation:
    #
    # *   Source code management. The Stackdriver Debugger service console is
    #     able to display your application source code from a source of your
    #     choice as a more convenient way to manage breakpoints. See [Debugger
    #     Doc](https://cloud.google.com/debugger/docs/source-context) on how to
    #     select source code on Stackdriver Debugger UI.
    # *   Breakpoints creation and manipulation. See the [Debugger
    #     Doc](https://cloud.google.com/debugger/docs/debugging) on how to
    #     manage breakpoints on Cloud Console, or see the [#Debugger
    #     API](#stackdriver-debugger-api) section on how to manage breakpoints
    #     using the Ruby API client.
    #
    # When this library is installed and configured in your running application,
    # you can view your applications breakpoint snapshots in real time by
    # opening the Google Cloud Console in your web browser and navigating to the
    # "Debug" section. It also integrates with Google App Engine Flexible to
    # make application registration more seemless, and helps Stackdriver Debugger
    # Console to select correct version of source code from Cloud Source
    # Repository.
    #
    # Note that when no breakpoints are created, the debugger agent consumes
    # very little resource and has no interference with the running application.
    # Once breakpoints are created and depends on where the breakpoints are
    # located, the debugger agent may add a little time onto each request. The
    # application performance will be back to normal after all breakpoints are
    # finished evaluating. Be aware the more breakpoints are created, or the
    # more complicated the breakpoints are located, the more resource the
    # debugger agent would need to consume.
    #
    # ### Using instrumentation with Ruby on Rails
    #
    # To install application instrumentation in your Ruby on Rails app, add this
    # gem, `google-cloud-debugger`, to your Gemfile and update your bundle. Then
    # add the following line to your `config/application.rb` file:
    #
    # ```ruby
    # require "google/cloud/debugger/rails"
    # ```
    #
    # This will load a Railtie that automatically integrates with the Rails
    # framework by injecting a Rack middleware. The Railtie also takes in the
    # following Rails configuration as parameter of the debugger agent
    # initialization:
    #
    # ```ruby
    # # Explicitly enable or disable Stackdriver Debugger Agent
    # config.google_cloud.use_debugger = true
    # # Shared Google Cloud Platform project identifier
    # config.google_cloud.project_id = "gcloud-project"
    # # Google Cloud Platform project identifier for Stackdriver Debugger only
    # config.google_cloud.debugger.project_id = "debugger-project"
    # # Share Google Cloud authentication json file
    # config.google_cloud.keyfile = "/path/to/file.json"
    # # Google Cloud authentication json file for Stackdriver Debugger only
    # config.google_cloud.debugger.keyfile = "/path/to/debugger/file.json"
    # # Stackdriver Debugger Agent module name identifier
    # config.google_cloud.debugger.module_name = "my-ruby-app"
    # # Stackdriver Debugger Agent module version identifier
    # config.google_cloud.debugger.module_version = "v1"
    # ```
    #
    # See the {Google::Cloud::Debugger::Railtie} class for more information.
    #
    # ### Using instrumentation with Sinatra
    #
    # To install application instrumentation in your Sinatra app, add this gem,
    # `google-cloud-debugger`, to your Gemfile and update your bundle. Then add
    # the following lines to your main application Ruby file:
    #
    # ```ruby
    # require "google/cloud/debugger"
    # use Google::Cloud::Debugger::Middleware
    # ```
    #
    # This will install the debugger middleware in your application.
    #
    # ### Using instrumentation with other Rack-based frameworks
    #
    # To install application instrumentation in an app using another Rack-based
    # web framework, add this gem, `google-cloud-debugger`, to your Gemfile and
    # update your bundle. Then add install the debugger middleware in your
    # middleware stack. In most cases, this means adding these lines to your
    # `config.ru` Rack configuration file:
    #
    # ```ruby
    # require "google/cloud/trace"
    # use Google::Cloud::Trace::Middleware
    # ```
    #
    # Some web frameworks have an alternate mechanism for modifying the
    # middleware stack. Consult your web framework's documentation for more
    # information.
    #
    # ### The Stackdriver diagnostics suite
    #
    # The debugger library is part of the Stackdriver diagnostics suite, which
    # also includes error reporting, log analysis, and tracing analysis. If you
    # include the `stackdriver` gem in your Gemfile, this debugger library will
    # be included automatically. In addition, if you include the `stackdriver`
    # gem in an application using Ruby On Rails, the Railties will be installed
    # automatically. See the documentation for the "stackdriver" gem
    # for more details.
    #
    # ## Stackdriver Debugger API
    #
    #
    #
    # The goal of google-cloud is to provide an API and application
    # instrumentation that are comfortable to Rubyists. Authentication is
    # handled by {Google::Cloud#debugger}. You can provide the project and
    # credential information to connect to the Stackdriver Debugger service, or
    # if you are running on Google Cloud Platform this configuration is taken
    # care of for you. You can read more about the options for connecting in t
    # he [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # If you just want to write your application's logs to the Stackdriver
    # Logging service, you may find it easiest to use the [Stackdriver Debugger
    # Instrumentation](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/instrumentation)
    # provided by this library. Otherwise, read on to learn more about the
    # Debugger API.
    #
    # ## Listing log entries
    #
    # Stackdriver Logging gathers log entries from many services, including
    # Google App Engine and Google Compute Engine. (See the [List of Log
    # Types](https://cloud.google.com/logging/docs/view/logs_index).) In
    # addition, you can write your own log entries to the service.
    #
    # {Google::Cloud::Logging::Project#entries} returns the
    # {Google::Cloud::Logging::Entry} records belonging to your project:
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    # entries = logging.entries
    # entries.each do |e|
    #   puts "[#{e.timestamp}] #{e.log_name} #{e.payload.inspect}"
    # end
    # ```
    #
    # You can narrow the results to a single log using an [advanced logs
    # filter](https://cloud.google.com/logging/docs/view/advanced_filters). A
    # log is a named collection of entries. Logs can be produced by Google Cloud
    # Platform services, by third-party services, or by your applications. For
    # example, the log `compute.googleapis.com/activity_log` is produced by
    # Google Compute Engine. Logs are simply referenced by name in google-cloud.
    # There is no `Log` type in google-cloud or `Log` resource in the
    # Stackdriver Logging API.
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    # entries = logging.entries filter: "log:syslog"
    # entries.each do |e|
    #   puts "[#{e.timestamp}] #{e.payload.inspect}"
    # end
    # ```
    #
    # You can also order the log entries by `timestamp`.
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    # entries = logging.entries order: "timestamp desc"
    # entries.each do |e|
    #   puts "[#{e.timestamp}] #{e.log_name} #{e.payload.inspect}"
    # end
    # ```
    #
    # ## Exporting log entries
    #
    # Stackdriver Logging lets you export log entries to destinations including
    # Google Cloud Storage buckets (for long term log storage), Google BigQuery
    # datasets (for log analysis), and Google Pub/Sub (for streaming to other
    # applications).
    #
    # ### Creating sinks
    #
    # A {Google::Cloud::Logging::Sink} is an object that lets you to specify a
    # set of log entries to export.
    #
    # In addition to the name of the sink and the export destination,
    # {Google::Cloud::Logging::Project#create_sink} accepts an [advanced logs
    # filter](https://cloud.google.com/logging/docs/view/advanced_filters) to
    # narrow the collection.
    #
    # Before creating the sink, ensure that you have granted
    # `cloud-logs@google.com` permission to write logs to the destination. See
    # [Permissions for writing exported
    # logs](https://cloud.google.com/logging/docs/export/configure_export#setting_product_name_short_permissions_for_writing_exported_logs).
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.create_bucket "my-logs-bucket"
    #
    # # Grant owner permission to Stackdriver Logging service
    # email = "cloud-logs@google.com"
    # bucket.acl.add_owner "group-#{email}"
    #
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    #
    # sink = logging.create_sink "my-sink",
    #                            "storage.googleapis.com/#{bucket.id}"
    # ```
    #
    # When you create a sink, only new log entries are exported. Stackdriver
    # Logging does not send previously-ingested log entries to the sink's
    # destination.
    #
    # ### Listing sinks
    #
    # You can also list the sinks belonging to your project with
    # {Google::Cloud::Logging::Project#sinks}.
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    # sinks = logging.sinks
    # sinks.each do |s|
    #   puts "#{s.name}: #{s.filter} -> #{s.destination}"
    # end
    # ```
    #
    # ## Creating logs-based metrics
    #
    # You can use log entries in your project as the basis for [Google Cloud
    # Monitoring](https://cloud.google.com/monitoring/docs) metrics. These
    # metrics can then be used to produce Cloud Monitoring reports and alerts.
    #
    # ### Creating metrics
    #
    # A metric is a measured value that can be used to assess a system. Use
    # {Google::Cloud::Logging::Project#create_metric} to configure a
    # {Google::Cloud::Logging::Metric} based on a collection of log entries
    # matching an [advanced logs
    # filter](https://cloud.google.com/logging/docs/view/advanced_filters).
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    # metric = logging.create_metric "errors", "severity>=ERROR"
    # ```
    #
    # ### Listing metrics
    #
    # You can also list the metrics belonging to your project with
    # {Google::Cloud::Logging::Project#metrics}.
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    # metrics = logging.metrics
    # metrics.each do |m|
    #   puts "#{m.name}: #{m.filter}"
    # end
    # ```
    #
    # ## Writing log entries
    #
    # An {Google::Cloud::Logging::Entry} is composed of metadata and a payload.
    # The payload is traditionally a message string, but in Stackdriver Logging
    # it can also be a JSON or protocol buffer object. A single log can have
    # entries with different payload types. In addition to the payload, your
    # argument(s) to {Google::Cloud::Logging::Project#write_entries} must also
    # contain a log name and a resource.
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    #
    # entry = logging.entry
    # entry.payload = "Job started."
    # entry.log_name = "my_app_log"
    # entry.resource.type = "gae_app"
    # entry.resource.labels[:module_id] = "1"
    # entry.resource.labels[:version_id] = "20150925t173233"
    #
    # logging.write_entries entry
    # ```
    #
    # If you write a collection of log entries, you can provide the log name,
    # resource, and/or labels hash to be used for all of the entries, and omit
    # these values from the individual entries.
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    #
    # entry1 = logging.entry
    # entry1.payload = "Job started."
    # entry2 = logging.entry
    # entry2.payload = "Job completed."
    # labels = { job_size: "large", job_code: "red" }
    #
    # resource = logging.resource "gae_app",
    #                             "module_id" => "1",
    #                             "version_id" => "20150925t173233"
    #
    # logging.write_entries [entry1, entry2],
    #                       log_name: "my_app_log",
    #                       resource: resource,
    #                       labels: labels
    # ```
    #
    # Normally, writing log entries is done synchronously; the call to
    # {Google::Cloud::Logging::Project#write_entries} will block until it has
    # either completed transmitting the data or encountered an error. To "fire
    # and forget" without blocking, use {Google::Cloud::Logging::AsyncWriter};
    # it spins up a background thread that writes log entries in batches. Calls
    # to {Google::Cloud::Logging::AsyncWriter#write_entries} simply add entries
    # to its work queue and return immediately.
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    # async = logging.async_writer
    #
    # entry1 = logging.entry
    # entry1.payload = "Job started."
    # entry2 = logging.entry
    # entry2.payload = "Job completed."
    # labels = { job_size: "large", job_code: "red" }
    #
    # resource = logging.resource "gae_app",
    #                             "module_id" => "1",
    #                             "version_id" => "20150925t173233"
    #
    # async.write_entries [entry1, entry2],
    #                     log_name: "my_app_log",
    #                     resource: resource,
    #                     labels: labels
    # ```
    #
    # ### Creating a Ruby Logger implementation
    #
    # If your environment requires a logger instance that is API-compatible with
    # Ruby's standard library
    # [Logger](http://ruby-doc.org/stdlib/libdoc/logger/rdoc), you can use
    # {Google::Cloud::Logging::Project#logger} to create one.
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    #
    # resource = logging.resource "gae_app",
    #                             module_id: "1",
    #                             version_id: "20150925t173233"
    #
    # logger = logging.logger "my_app_log", resource, env: :production
    # logger.info "Job started."
    # ```
    #
    # By default, the logger instance writes log entries asynchronously in a
    # background thread using an {Google::Cloud::Logging::AsyncWriter}. If you
    # want to customize or disable asynchronous writing, you may call the
    # Logger constructor directly.
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    #
    # resource = logging.resource "gae_app",
    #                             module_id: "1",
    #                             version_id: "20150925t173233"
    #
    # logger = Google::Cloud::Logging::Logger.new logging,
    #                                             "my_app_log",
    #                                             resource,
    #                                             {env: :production}
    # logger.info "Log entry written synchronously."
    # ```
    #
    # ## Configuring timeout
    #
    # You can configure the request `timeout` value in seconds.
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new timeout: 120
    # ```
    #
    module Debugger
      def self.new project: nil, keyfile: nil, module_name: nil,
                   module_version: nil, scope: nil, timeout: nil,
                   client_config: nil
        project ||= Debugger::Project.default_project
        project = project.to_s # Always cast to a string
        module_name ||= Debugger::Project.default_module_name
        module_name = module_name.to_s
        module_version ||= Debugger::Project.default_module_version
        module_version = module_version.to_s

        fail ArgumentError, "project is missing" if project.empty?
        fail ArgumentError, "module_name is missing" if module_name.empty?
        fail ArgumentError, "module_version is missing" if module_version.nil?

        credentials = Credentials.credentials_with_scope keyfile, scope

        Google::Cloud::Debugger::Project.new(
          Google::Cloud::Debugger::Service.new(
            project, credentials, timeout: timeout,
                                  client_config: client_config),
          module_name: module_name,
          module_version: module_version
        )
      end
    end
  end
end
