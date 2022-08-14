# frozen_string_literal: true

# Copyright 2020 Google LLC
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

module Google
  module Cloud
    module Kms
      # This method used to be generated, but is no longer because iam_policy
      # is expected to be a mixin. We'll preserve it for backward compatibility.
      # Note: When KMS is transitioned to true mixins, this will need to be
      # updated.
      unless respond_to? :iam_policy
        ##
        # Create a new client object for IAMPolicy.
        #
        # By default, this returns an instance of
        # [Google::Cloud::Kms::V1::IAMPolicy::Client](https://googleapis.dev/ruby/google-cloud-kms-v1/latest/Google/Cloud/Kms/V1/IAMPolicy/Client.html)
        # for version V1 of the API.
        # However, you can specify specify a different API version by passing it in the
        # `version` parameter. If the IAMPolicy service is
        # supported by that API version, and the corresponding gem is available, the
        # appropriate versioned client will be returned.
        #
        # ## About IAMPolicy
        #
        # API Overview
        #
        #
        # Manages Identity and Access Management (IAM) policies.
        #
        # Any implementation of an API that offers access control features
        # implements the google.iam.v1.IAMPolicy interface.
        #
        # ## Data model
        #
        # Access control is applied when a principal (user or service account), takes
        # some action on a resource exposed by a service. Resources, identified by
        # URI-like names, are the unit of access control specification. Service
        # implementations can choose the granularity of access control and the
        # supported permissions for their resources.
        # For example one database service may allow access control to be
        # specified only at the Table level, whereas another might allow access control
        # to also be specified at the Column level.
        #
        # ## Policy Structure
        #
        # See google.iam.v1.Policy
        #
        # This is intentionally not a CRUD style API because access control policies
        # are created and deleted implicitly with the resources to which they are
        # attached.
        #
        # @param version [::String, ::Symbol] The API version to connect to. Optional.
        #   Defaults to `:v1`.
        # @return [IAMPolicy::Client] A client object for the specified version.
        #
        def self.iam_policy version: :v1, &block
          require "google/cloud/kms/#{version.to_s.downcase}"

          package_name = Google::Cloud::Kms
                         .constants
                         .select { |sym| sym.to_s.downcase == version.to_s.downcase.tr("_", "") }
                         .first
          package_module = Google::Cloud::Kms.const_get package_name
          package_module.const_get(:IAMPolicy).const_get(:Client).new(&block)
        end
      end
    end
  end
end
