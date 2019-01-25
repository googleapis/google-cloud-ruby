# Copyright 2019 Google LLC
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
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/cloud/talent/v4beta1/resume_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/cloud/talent/v4beta1/resume_service_pb"
require "google/cloud/talent/v4beta1/credentials"

module Google
  module Cloud
    module Talent
      module V4beta1
        # A service that handles resume parsing.
        #
        # @!attribute [r] resume_service_stub
        #   @return [Google::Cloud::Talent::V4beta1::ResumeService::Stub]
        class ResumeServiceClient
          # @private
          attr_reader :resume_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "jobs.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/jobs"
          ].freeze


          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
            )
          end

          # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
          #   Provides the means for authenticating requests made by the client. This parameter can
          #   be many types.
          #   A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
          #   authenticating requests made by this client.
          #   A `String` will be treated as the path to the keyfile to be used for the construction of
          #   credentials for this client.
          #   A `Hash` will be treated as the contents of a keyfile to be used for the construction of
          #   credentials for this client.
          #   A `GRPC::Core::Channel` will be used to make calls through.
          #   A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
          #   should already be composed with a `GRPC::Core::CallCredentials` object.
          #   A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
          #   metadata for requests, generally, to give OAuth credentials.
          # @param scopes [Array<String>]
          #   The OAuth scopes for this service. This parameter is ignored if
          #   an updater_proc is supplied.
          # @param client_config [Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          # @param metadata [Hash]
          #   Default metadata to be sent with each request. This can be overridden on a per call basis.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def initialize \
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              metadata: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/cloud/talent/v4beta1/resume_service_services_pb"

            credentials ||= Google::Cloud::Talent::V4beta1::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Talent::V4beta1::Credentials.new(credentials).updater_proc
            end
            if credentials.is_a?(GRPC::Core::Channel)
              channel = credentials
            end
            if credentials.is_a?(GRPC::Core::ChannelCredentials)
              chan_creds = credentials
            end
            if credentials.is_a?(Proc)
              updater_proc = credentials
            end
            if credentials.is_a?(Google::Auth::Credentials)
              updater_proc = credentials.updater_proc
            end

            package_version = Gem.loaded_specs['google-cloud-talent'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "resume_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.talent.v4beta1.ResumeService",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                errors: Google::Gax::Grpc::API_ERRORS,
                metadata: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = self.class::SERVICE_ADDRESS
            port = self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @resume_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Talent::V4beta1::ResumeService::Stub.method(:new)
            )

            @parse_resume = Google::Gax.create_api_call(
              @resume_service_stub.method(:parse_resume),
              defaults["parse_resume"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Parses a resume into a {Google::Cloud::Talent::V4beta1::Profile Profile}. The API attempts to fill out the
          # following profile fields if present within the resume:
          #
          # * personNames
          # * addresses
          # * emailAddress
          # * phoneNumbers
          # * personalUris
          # * employmentRecords
          # * educationRecords
          # * skills
          #
          # Note that some attributes in these fields may not be populated if they're
          # not present within the resume or unrecognizable by the resume parser.
          #
          # This API does not save the resume or profile. To create a profile from this
          # resume, clients need to call the CreateProfile method again with the
          # profile returned.
          #
          # This API supports the following list of formats:
          #
          # * PDF
          # * TXT
          # * DOC
          # * RTF
          # * DOCX
          #
          # An error is thrown if the input format is not supported.
          #
          # @param parent [String]
          #   Required.
          #
          #   The resource name of the project.
          #
          #   The format is "projects/{project_id}", for example,
          #   "projects/api-test-project".
          # @param resume [String]
          #   Required.
          #
          #   The bytes of the resume file in common format. Currently the API supports
          #   the following formats:
          #   PDF, TXT, DOC, RTF and DOCX.
          # @param region_code [String]
          #   Optional.
          #
          #   The region code indicating where the resume is from. Values
          #   are as per the ISO-3166-2 format. For example, US, FR, DE.
          #
          #   This value is optional, but providing this value improves the resume
          #   parsing quality and performance.
          #
          #   An error is thrown if the regionCode is invalid.
          # @param language_code [String]
          #   Optional.
          #
          #   The language code of contents in the resume.
          #
          #   Language codes must be in BCP-47 format, such as "en-US" or "sr-Latn".
          #   For more information, see
          #   [Tags for Identifying Languages](https://tools.ietf.org/html/bcp47){:
          #   class="external" target="_blank" }.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Talent::V4beta1::ParseResumeResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Talent::V4beta1::ParseResumeResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/talent"
          #
          #   resume_service_client = Google::Cloud::Talent::Resume.new(version: :v4beta1)
          #   formatted_parent = Google::Cloud::Talent::V4beta1::ResumeServiceClient.project_path("[PROJECT]")
          #
          #   # TODO: Initialize `resume`:
          #   resume = ''
          #   response = resume_service_client.parse_resume(formatted_parent, resume)

          def parse_resume \
              parent,
              resume,
              region_code: nil,
              language_code: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              resume: resume,
              region_code: region_code,
              language_code: language_code
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Talent::V4beta1::ParseResumeRequest)
            @parse_resume.call(req, options, &block)
          end
        end
      end
    end
  end
end
