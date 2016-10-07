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


module Google
  module Cloud
    module ErrorReporting
      class ErrorEvent
        ##
        # ServiceContext
        #
        # Rrepresent
        # Google::Devtools::Clouderrorreporting::V1beta1::ServiceContext class.
        # Describes a running service that sends errors. Its version changes
        # over time and multiple versions can run in parallel.
        #
        class ServiceContext
          ##
          # An identifier of the service, such as the name of the executable,
          # job, or Google App Engine service name. This field is expected to
          # have a low number of values that are relatively stable over time, as
          # opposed to version, which can be changed whenever new code is
          # deployed. Contains the service name for error reports extracted from
          # Google App Engine logs or default if the App Engine default service
          # is used.
          attr_accessor :service

          ##
          # Represents the source code version that the developer provided,
          # which could represent a version label or a Git SHA-1 hash, for
          # example.
          attr_accessor :version

          ##
          # Build a new
          # Google::Cloud::ErrorReporting::ErrorEvent::ServiceContext object
          def initialize
          end

          ##
          # Determines if the ServiceContext has any data
          def empty?
            service.nil? &&
              version.nil?
          end

          ##
          # Exports the ServiceContext to a
          # Google::Devtools::Clouderrorreporting::V1beta1::ServiceContext
          # object.
          def to_grpc
            return nil if empty?
            Google::Devtools::Clouderrorreporting::V1beta1::ServiceContext.new(
              service: service.to_s,
              version: version.to_s
            )
          end

          ##
          # New ServiceContext from a
          # Google::Devtools::Clouderrorreporting::V1beta1::ServiceContext
          # object.
          def self.from_grpc grpc
            return new if grpc.nil?
            new.tap do |s|
              s.service = grpc.service
              s.version = grpc.version
            end
          end
        end
      end
    end
  end
end
