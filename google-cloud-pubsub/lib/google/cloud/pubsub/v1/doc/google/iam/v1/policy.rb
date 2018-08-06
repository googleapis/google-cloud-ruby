# Copyright 2018 Google LLC
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
  module Iam
    module V1
      # Defines an Identity and Access Management (IAM) policy. It is used to
      # specify access control policies for Cloud Platform resources.
      #
      #
      # A +Policy+ consists of a list of +bindings+. A +Binding+ binds a list of
      # +members+ to a +role+, where the members can be user accounts, Google groups,
      # Google domains, and service accounts. A +role+ is a named list of permissions
      # defined by IAM.
      #
      # **Example**
      #
      #     {
      #       "bindings": [
      #         {
      #           "role": "roles/owner",
      #           "members": [
      #             "user:mike@example.com",
      #             "group:admins@example.com",
      #             "domain:google.com",
      #             "serviceAccount:my-other-app@appspot.gserviceaccount.com",
      #           ]
      #         },
      #         {
      #           "role": "roles/viewer",
      #           "members": ["user:sean@example.com"]
      #         }
      #       ]
      #     }
      #
      # For a description of IAM and its features, see the
      # [IAM developer's guide](https://cloud.google.com/iam).
      # @!attribute [rw] version
      #   @return [Integer]
      #     Version of the +Policy+. The default version is 0.
      # @!attribute [rw] bindings
      #   @return [Array<Google::Iam::V1::Binding>]
      #     Associates a list of +members+ to a +role+.
      #     Multiple +bindings+ must not be specified for the same +role+.
      #     +bindings+ with no members will result in an error.
      # @!attribute [rw] etag
      #   @return [String]
      #     +etag+ is used for optimistic concurrency control as a way to help
      #     prevent simultaneous updates of a policy from overwriting each other.
      #     It is strongly suggested that systems make use of the +etag+ in the
      #     read-modify-write cycle to perform policy updates in order to avoid race
      #     conditions: An +etag+ is returned in the response to +getIamPolicy+, and
      #     systems are expected to put that etag in the request to +setIamPolicy+ to
      #     ensure that their change will be applied to the same version of the policy.
      #
      #     If no +etag+ is provided in the call to +setIamPolicy+, then the existing
      #     policy is overwritten blindly.
      class Policy; end

      # Associates +members+ with a +role+.
      # @!attribute [rw] role
      #   @return [String]
      #     Role that is assigned to +members+.
      #     For example, +roles/viewer+, +roles/editor+, or +roles/owner+.
      #     Required
      # @!attribute [rw] members
      #   @return [Array<String>]
      #     Specifies the identities requesting access for a Cloud Platform resource.
      #     +members+ can have the following values:
      #
      #     * +allUsers+: A special identifier that represents anyone who is
      #       on the internet; with or without a Google account.
      #
      #     * +allAuthenticatedUsers+: A special identifier that represents anyone
      #       who is authenticated with a Google account or a service account.
      #
      #     * +user:{emailid}+: An email address that represents a specific Google
      #       account. For example, +alice@gmail.com+ or +joe@example.com+.
      #
      #
      #     * +serviceAccount:{emailid}+: An email address that represents a service
      #       account. For example, +my-other-app@appspot.gserviceaccount.com+.
      #
      #     * +group:{emailid}+: An email address that represents a Google group.
      #       For example, +admins@example.com+.
      #
      #     * +domain:{domain}+: A Google Apps domain name that represents all the
      #       users of that domain. For example, +google.com+ or +example.com+.
      class Binding; end

      # The difference delta between two policies.
      # @!attribute [rw] binding_deltas
      #   @return [Array<Google::Iam::V1::BindingDelta>]
      #     The delta for Bindings between two policies.
      class PolicyDelta; end

      # One delta entry for Binding. Each individual change (only one member in each
      # entry) to a binding will be a separate entry.
      # @!attribute [rw] action
      #   @return [Google::Iam::V1::BindingDelta::Action]
      #     The action that was performed on a Binding.
      #     Required
      # @!attribute [rw] role
      #   @return [String]
      #     Role that is assigned to +members+.
      #     For example, +roles/viewer+, +roles/editor+, or +roles/owner+.
      #     Required
      # @!attribute [rw] member
      #   @return [String]
      #     A single identity requesting access for a Cloud Platform resource.
      #     Follows the same format of Binding.members.
      #     Required
      class BindingDelta; end
    end
  end
end