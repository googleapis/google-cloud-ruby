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


require "gcloud"
require "gcloud/logging/project"

module Gcloud
  ##
  # Creates a new object for connecting to the Logging service.
  # Each call creates a new connection.
  #
  # For more information on connecting to Google Cloud see the [Authentication
  # Guide](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/guides/authentication).
  #
  # @param [String] project Project identifier for the Logging service you are
  #   connecting to.
  # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud. If file
  #   path the file must be readable.
  # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
  #   set of resources and operations that the connection can access. See [Using
  #   OAuth 2.0 to Access Google
  #   APIs](https://developers.google.com/identity/protocols/OAuth2).
  #
  #   The default scope is:
  #
  #   * `https://www.googleapis.com/auth/logging.admin`
  #
  # @return [Gcloud::Logging::Project]
  #
  # @example
  #   require "gcloud/logging"
  #
  #   gcloud = Gcloud.new
  #   logging = gcloud.logging
  #   # ...
  #
  def self.logging project = nil, keyfile = nil, scope: nil
    project ||= Gcloud::Logging::Project.default_project
    if keyfile.nil?
      credentials = Gcloud::Logging::Credentials.default scope: scope
    else
      credentials = Gcloud::Logging::Credentials.new keyfile, scope: scope
    end
    Gcloud::Logging::Project.new project, credentials
  end

  ##
  # # Google Cloud Logging
  #
  # The Google Cloud Logging service collects and stores logs from applications
  # and services on the Google Cloud Platform, giving you fine-grained,
  # programmatic control over your projects' logs. You can use the Cloud Logging
  # API to:
  #
  # * [Read and filter log entries](#listing-log-entries)
  # * [Export your log entries](#exporting-log-entries) to Cloud Storage,
  #   BigQuery, or Cloud Pub/Sub
  # * [Create logs-based metrics](#creating-logs-based-metrics) for use in Cloud
  #   Monitoring
  # * [Write log entries](#writing-log-entries)
  #
  # For general information about Cloud Logging, read [What is Google Cloud
  # Logging?](https://cloud.google.com/logging/docs/).
  #
  # Gcloud's goal is to provide an API that is familiar and comfortable to
  # Rubyists. Authentication is handled by {Gcloud#logging}. You can provide the
  # project and credential information to connect to the Cloud Logging service,
  # or if you are running on Google Compute Engine this configuration is taken
  # care of for you. You can read more about the options for connecting in the
  # [Authentication
  # Guide](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/guides/authentication).
  #
  # ## Listing log entries
  #
  # Cloud Logging gathers log entries from many services, including Google App
  # Engine and Google Compute Engine. (See the [List of Log
  # Types](https://cloud.google.com/logging/docs/view/logs_index).) In addition,
  # you can write your own log entries to the service.
  #
  # {Gcloud::Logging::Project#entries} returns the {Gcloud::Logging::Entry}
  # records belonging to your project:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # logging = gcloud.logging
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
  # example, the log `compute.googleapis.com/activity_log` is produced by Google
  # Compute Engine. Logs are simply referenced by name in Gcloud. There is no
  # `Log` type in Gcloud or `Log` resource in the Cloud Logging API.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # logging = gcloud.logging
  # entries = logging.entries filter: "log:syslog"
  # entries.each do |e|
  #   puts "[#{e.timestamp}] #{e.payload.inspect}"
  # end
  # ```
  #
  # You can also order the log entries by `timestamp`.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # logging = gcloud.logging
  # entries = logging.entries order: "timestamp desc"
  # entries.each do |e|
  #   puts "[#{e.timestamp}] #{e.log_name} #{e.payload.inspect}"
  # end
  # ```
  #
  # ## Exporting log entries
  #
  # Cloud Logging lets you export log entries to destinations including Google
  # Cloud Storage buckets (for long term log storage), Google BigQuery datasets
  # (for log analysis), and Google Pub/Sub (for streaming to other
  # applications).
  #
  # ### Creating sinks
  #
  # A {Gcloud::Logging::Sink} is an object that lets you to specify a set of log
  # entries to export.
  #
  # In addition to the name of the sink and the export destination,
  # {Gcloud::Logging::Project#create_sink} accepts an [advanced
  # logs filter](https://cloud.google.com/logging/docs/view/advanced_filters) to
  # narrow the collection.
  #
  # Before creating the sink, ensure that you have granted
  # `cloud-logs@google.com` permission to write logs to the destination. See
  # [Permissions for writing exported
  # logs](https://cloud.google.com/logging/docs/export/configure_export#setting_product_name_short_permissions_for_writing_exported_logs).
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # logging = gcloud.logging
  # storage = gcloud.storage
  #
  # bucket = storage.create_bucket "my-logs-bucket"
  #
  # # Grant owner permission to Cloud Logging service
  # email = "cloud-logs@google.com"
  # bucket.acl.add_owner "group-#{email}"
  #
  # sink = logging.create_sink "my-sink", "storage.googleapis.com/#{bucket.id}"
  # ```
  #
  # When you create a sink, only new log entries are exported. Cloud Logging
  # does not send previously-ingested log entries to the sink's destination.
  #
  # ### Listing sinks
  #
  # You can also list the sinks belonging to your project with
  # {Gcloud::Logging::Project#sinks}.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # logging = gcloud.logging
  # sinks = logging.sinks
  # sinks.each do |s|
  #   puts "#{s.name}: #{s.filter} -> #{s.destination}"
  # end
  # ```
  #
  # ## Creating logs-based metrics
  #
  # You can use log entries in your project as the basis for [Google Cloud
  # Monitoring](https://cloud.google.com/monitoring/docs) metrics. These metrics
  # can then be used to produce Cloud Monitoring reports and alerts.
  #
  # ### Creating metrics
  #
  # A metric is a measured value that can be used to assess a system. Use
  # {Gcloud::Logging::Project#create_metric} to configure a
  # {Gcloud::Logging::Metric} based on a collection of log entries matching an
  # [advanced
  # logs filter](https://cloud.google.com/logging/docs/view/advanced_filters).
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # logging = gcloud.logging
  # metric = logging.create_metric "errors", "severity>=ERROR"
  # ```
  #
  # ### Listing metrics
  #
  # You can also list the metrics belonging to your project with
  # {Gcloud::Logging::Project#metrics}.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # logging = gcloud.logging
  # metrics = logging.metrics
  # metrics.each do |m|
  #   puts "#{m.name}: #{m.filter}"
  # end
  # ```
  #
  # ## Writing log entries
  #
  # An {Gcloud::Logging::Entry} is composed of metadata and a payload. The
  # payload is traditionally a message string, but in Cloud Logging it can
  # also be a JSON or protocol buffer object. A single log can have entries with
  # different payload types. In addition to the payload, your argument(s) to
  # {Gcloud::Logging::Project#write_entries} must also contain a log name and a
  # resource.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # logging = gcloud.logging
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
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # logging = gcloud.logging
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
  # ### Creating a Ruby Logger implementation
  #
  # If your environment requires a logger instance that is API-compatible with
  # Ruby's standard library
  # [Logger](http://ruby-doc.org/stdlib/libdoc/logger/rdoc), you can use
  # {Gcloud::Logging::Project#logger} to create one.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # logging = gcloud.logging
  #
  # resource = logging.resource "gae_app",
  #                             module_id: "1",
  #                             version_id: "20150925t173233"
  #
  # logger = logging.logger "my_app_log", resource, env: :production
  # logger.info "Job started."
  # ```
  #
  # ## Configuring Backoff
  #
  # The {Gcloud::Backoff} class allows users to globally configure how Cloud API
  # requests are automatically retried in the case of some errors, such as a
  # `500` or `503` status code, or a specific internal error code such as
  # `rateLimitExceeded`.
  #
  # If an API call fails, the response will be inspected to see if the call
  # should be retried. If the response matches the criteria, then the request
  # will be retried after a delay. If another error occurs, the delay will be
  # increased incrementally before a subsequent attempt. The first retry will be
  # delayed one second, the second retry two seconds, and so on.
  #
  # ```ruby
  # require "gcloud"
  # require "gcloud/backoff"
  #
  # Gcloud::Backoff.retries = 5 # Raise the maximum number of retries from 3
  # ```
  #
  module Logging
  end
end
