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


require "gcloud/logging/sink/list"

module Gcloud
  module Logging
    ##
    # # Sink
    #
    # Used to export log entries outside Cloud Logging.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   logging = gcloud.logging
    #   sink = logging.sink "severe_errors"
    #
    class Sink
      ##
      # @private
      VERSIONS = { unspecified: "VERSION_FORMAT_UNSPECIFIED",
                   v2: "V2", v1: "V1" }

      ##
      # @private The Connection object.
      attr_accessor :connection

      ##
      # @private The Google API Client object.
      attr_accessor :gapi

      ##
      # @private Create an empty Sink object.
      def initialize
        @connection = nil
        @gapi = {}
      end

      ##
      # The client-assigned sink identifier. Sink identifiers are limited to
      # 1000 characters and can include only the following characters: `A-Z`,
      # `a-z`, `0-9`, and the special characters `_-.`.
      def name
        @gapi["name"]
      end

      ##
      # The export destination. See [Exporting Logs With
      # Sinks](https://cloud.google.com/logging/docs/api/tasks/exporting-logs).
      def destination
        @gapi["destination"]
      end

      ##
      # Updates the export destination. See [Exporting Logs With
      # Sinks](https://cloud.google.com/logging/docs/api/tasks/exporting-logs).
      def destination= destination
        @gapi["destination"] = destination
      end

      ##
      # An [advanced logs
      # filter](https://cloud.google.com/logging/docs/view/advanced_filters)
      # that defines the log entries to be exported. The filter must be
      # consistent with the log entry format designed by the `version`
      # parameter, regardless of the format of the log entry that was originally
      # written to Cloud Logging.
      def filter
        @gapi["filter"]
      end

      ##
      # Updates the [advanced logs
      # filter](https://cloud.google.com/logging/docs/view/advanced_filters)
      # that defines the log entries to be exported. The filter must be
      # consistent with the log entry format designed by the `version`
      # parameter, regardless of the format of the log entry that was originally
      # written to Cloud Logging.
      def filter= filter
        @gapi["filter"] = filter
      end

      ##
      # The log entry version used when exporting log entries from this sink.
      # This version does not have to correspond to the version of the log entry
      # when it was written to Cloud Logging.
      def version
        @gapi["outputVersionFormat"]
      end

      ##
      # Updates the log entry version used when exporting log entries from this
      # sink. This version does not have to correspond to the version of the log
      # entry when it was written to Cloud Logging. Accepted values are
      # `:unspecified`, `:v2`, and `:v1`.
      def version= version
        version = VERSIONS[version] if VERSIONS[version]
        @gapi["outputVersionFormat"] = version
      end

      ##
      # Helper to determine if the sink's version is
      # `VERSION_FORMAT_UNSPECIFIED`.
      def unspecified?
        version == VERSIONS[:unspecified]
      end

      ##
      # Helper to determine if the sink's version is `V2`.
      def v2?
        version == VERSIONS[:v2]
      end

      ##
      # Helper to determine if the sink's version is `V1`.
      def v1?
        version == VERSIONS[:v1]
      end

      ##
      # Updates the logs-based sink.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   sink = logging.sink "severe_errors"
      #   sink.filter = "logName:syslog AND severity>=ERROR"
      #   sink.save
      #
      def save
        ensure_connection!
        resp = connection.update_sink name, destination, filter, version
        if resp.success?
          @gapi = resp.data
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Reloads the logs-based sink with current data from the Logging
      # service.
      def reload!
        ensure_connection!
        resp = connection.get_sink name
        if resp.success?
          @gapi = resp.data
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :refresh!, :reload!

      ##
      # Permanently deletes the logs-based sink.
      #
      # @return [Boolean] Returns `true` if the sink was deleted.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   sink = logging.sink "severe_errors"
      #   sink.delete
      #
      def delete
        ensure_connection!
        resp = connection.delete_sink name
        if resp.success?
          true
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # @private New Metric from a Google API Client object.
      def self.from_gapi gapi, conn
        new.tap do |f|
          f.gapi = gapi
          f.connection = conn
        end
      end

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end
    end
  end
end
