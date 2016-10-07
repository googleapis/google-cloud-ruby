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


require "google/cloud/error_reporting/error_event/http_request_context"
require "google/cloud/error_reporting/error_event/source_location"

module Google
  module Cloud
    module ErrorReporting
      class ErrorEvent
        ##
        # ErrorContext
        #
        # Rrepresent Google::Devtools::Clouderrorreporting::V1beta1::ErrorContext
        # class. A description of the context in which an error occurred. This
        # data should be provided by the application when reporting an error,
        # unless the error report has been generated automatically from Google App
        # Engine logs.
        #
        class ErrorContext
          ##
          # The user who caused or was affected by the crash. This can be a user
          # ID, an email address, or an arbitrary token that uniquely identifies
          # the user. When sending an error report, leave this field empty if the
          # user was not logged in. In this case the Error Reporting system will
          # use other data, such as remote IP address, to distinguish affected
          # users.
          attr_accessor :user

          ##
          # A HttpRequestContext object. The HTTP request which was processed
          # when the error was triggered.
          attr_reader :http_request_context

          ##
          # A SourceLocation object. The location in the source code where the
          # decision was made to report the error, usually the place where it was
          # logged. For a logged exception this would be the source line where the
          # exception is logged, usually close to the place where it was caught.
          # This value is in contrast to Exception.cause_location, which describes
          # the source line where the exception was thrown.
          attr_reader :source_location

          ##
          # Build a new
          # Google::Cloud::ErrorReporting::ErrorEvent::HttpRequestContext
          # object
          def initialize
            @http_request_context = HttpRequestContext.new
            @source_location = SourceLocation.new
          end

          ##
          # Determines if the ErrorContext has any data
          def empty?
            user.nil? &&
              http_request_context.empty? &&
              source_location.empty?
          end

          ##
          # Exports the ErrorContext to a
          # Google::Devtools::Clouderrorreporting::V1beta1::ErrorContext object.
          def to_grpc
            return nil if empty?
            Google::Devtools::Clouderrorreporting::V1beta1::ErrorContext.new(
              user: user.to_s,
              http_request: http_request_context.to_grpc,
              report_location: source_location.to_grpc
            )
          end

          ##
          # New ErrorContext from a
          # Google::Devtools::Clouderrorreporting::V1beta1::ErrorContext object.
          def self.from_grpc grpc
            return new if grpc.nil?
            new.tap do |e|
              e.user = grpc.user
              e.instance_variable_set "@http_request_context",
                                      HttpRequestContext.from_grpc(grpc.http_request)
              e.instance_variable_set "@source_location",
                                      SourceLocation.from_grpc(grpc.report_location)
            end
          end
        end
      end
    end
  end
end
