# Copyright 2017 Google LLC
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


require "digest/sha1"
require "google/cloud/debugger/backoff"
require "google/cloud/debugger/debuggee/app_uniquifier_generator"
require "google/cloud/debugger/version"
require "google/cloud/env"
require "json"

module Google
  module Cloud
    module Debugger
      ##
      # # Debuggee
      #
      # Represent a debuggee application. Contains information that identifies
      # debuggee applications from each other. Maps to gRPC struct
      # Google::Cloud::Debugger::V2::Debuggee.
      #
      # It also automatically loads source context information generated from
      # Cloud SDK. See [Stackdriver Debugger
      # doc](https://cloud.google.com/debugger/docs/source-context#app_engine_standard_python)
      # for more information on how to generate this source context information
      # when used on Google Container Engine and Google Compute engine. This
      # step is taken care of if debuggee application is hosted on Google App
      # Engine Flexibile.
      #
      # To ensure the multiple instances of the application are indeed the same
      # application, the debuggee also compute a "uniquifier" generated from
      # source context or application source code.
      #
      class Debuggee
        ##
        # @private The gRPC Service object.
        attr_reader :service

        ##
        # Name for the debuggee application
        # @return [String]
        attr_reader :service_name

        ##
        # Version identifier for the debuggee application
        # @return [String]
        attr_reader :service_version

        ##
        # Registered Debuggee ID. Set by Stackdriver Debugger service when
        # a debuggee application is sucessfully registered.
        # @return [String]
        attr_reader :id

        ##
        # @private Construct a new instance of Debuggee
        def initialize service, service_name:, service_version:
          @service = service
          @service_name = service_name
          @service_version = service_version
          @env = Google::Cloud.env
          @computed_uniquifier = nil
          @id = nil
          @register_backoff = Google::Cloud::Debugger::Backoff.new
        end

        ##
        # Register the current application as a debuggee with Stackdriver
        # Debuggee service.
        # @return [Boolean] True if registered sucessfully; otherwise false.
        def register
          # Wait if backoff applies
          sleep @register_backoff.interval if @register_backoff.backing_off?

          begin
            response = service.register_debuggee to_grpc
            @id = response.debuggee.id
          rescue StandardError
            revoke_registration
          end

          registered = registered?
          registered ? @register_backoff.succeeded : @register_backoff.failed

          registered
        end

        ##
        # Check whether this debuggee is currently registered or not
        # @return [Boolean] True if debuggee is registered; otherwise false.
        def registered?
          !id.nil?
        end

        ##
        # Revoke the registration of this debuggee
        def revoke_registration
          @id = nil
        end

        ##
        # Convert this debuggee into a gRPC
        # Google::Cloud::Debugger::V2::Debuggee struct.
        def to_grpc
          source_context = source_context_from_json_file "source-context.json"
          Google::Cloud::Debugger::V2::Debuggee.new(
            id: id.to_s,
            project: project_id_for_request_arg.to_s,
            description: description.to_s,
            labels: labels,
            agent_version: agent_version.to_s
          ).tap do |d|
            if source_context
              d.source_contexts << source_context
              d.ext_source_contexts << ext_source_context_grpc(source_context)
            end
            d.uniquifier = compute_uniquifier d
          end
        end

        private

        def source_context_from_json_file file_path
          json = File.read file_path
          Devtools::Source::V1::SourceContext.decode_json json
        rescue StandardError
          nil
        end

        def ext_source_context_grpc source_context
          Devtools::Source::V1::SourceContext.new context: source_context
        end

        ##
        # @private Build labels hash for this debuggee
        def labels
          {
            "projectid" => String(project_id),
            "module" => String(service_name),
            "version" => String(service_version)
          }
        end

        ##
        # @private Build description string for this debuggee. In
        # "<module name> - <module version>" format. Or just the module
        # version if module name is missing.
        #
        # @return [String] A compact debuggee description.
        #
        def description
          if service_version.nil? || service_version.empty?
            service_name
          else
            "#{service_name} - #{service_version}"
          end
        end

        ##
        # @private Get debuggee project id
        def project_id
          service.project
        end

        ##
        # @private
        # Get project to send as a debuggee argument. This is the numeric
        # project ID if available (and if it matches the project set in the
        # configuration). Otherwise, use the configured project.
        def project_id_for_request_arg
          if project_id == @env.lookup_metadata("project", "project-id")
            numeric_id = @env.numeric_project_id
            return numeric_id.to_s if numeric_id
          end
          project_id
        end

        ##
        # @private Build debuggee agent version identifier
        def agent_version
          "google.com/ruby#{RUBY_VERSION}-#{Google::Cloud::Debugger::VERSION}"
        end

        ##
        # @private Generate a debuggee uniquifier from source context
        # information or application source code
        def compute_uniquifier partial_debuggee
          return @computed_uniquifier if @computed_uniquifier

          sha = Digest::SHA1.new
          sha << partial_debuggee.to_s

          if partial_debuggee.source_contexts.empty? &&
             partial_debuggee.ext_source_contexts.empty?
            AppUniquifierGenerator.generate_app_uniquifier sha
          end

          @computed_uniquifier = sha.hexdigest
        end

        ##
        # @private Helper method to parse json file
        def read_app_json_file file_path
          JSON.parse File.read(file_path), symbolize_names: true
        rescue StandardError
          nil
        end
      end
    end
  end
end
