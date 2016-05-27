# Copyright 2015 Google Inc. All rights reserved.
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


require "gcloud/errors"

module Gcloud
  module Pubsub
    ##
    # # Policy
    #
    # Represents a Cloud IAM Policy for the Pub/Sub service.
    #
    # A common pattern for updating a resource's metadata, such as its Policy,
    # is to read the current data from the service, update the data locally, and
    # then send the modified data for writing. This pattern may result in a
    # conflict if two or more processes attempt the sequence simultaneously. IAM
    # solves this problem with the {Gcloud::Pubsub::Policy#etag} property, which
    # is used to verify whether the policy has changed since the last request.
    # When you make a request to with an `etag` value, Cloud IAM compares the
    # `etag` value in the request with the existing `etag` value associated with
    # the policy. It writes the policy only if the `etag` values match.
    #
    # When you update a policy, first read the policy (and its current `etag`)
    # from the service, then modify the policy locally, and then write the
    # modified policy to the service. See {Gcloud::Pubsub::Topic#policy} and
    # {Gcloud::Pubsub::Topic#policy=}.
    #
    # @see https://cloud.google.com/iam/docs/managing-policies Managing policies
    # @see https://cloud.google.com/pubsub/reference/rpc/google.iam.v1#iampolicy
    #   google.iam.v1.IAMPolicy
    #
    # @attr [String] etag Used to verify whether the policy has changed since
    #   the last request. The policy will be written only if the `etag` values
    #   match.
    # @attr [Hash{String => Array<String>}] roles The bindings that associate
    #   roles with an array of members. See
    #   [Binding](https://cloud.google.com/pubsub/reference/rpc/google.iam.v1#binding)
    #   for a listing of values and patterns for members.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   pubsub = gcloud.pubsub
    #   topic = pubsub.topic "my-topic"
    #
    #   policy = topic.policy # API call
    #
    #   policy.roles["roles/owner"] << "user:owner@example.com" # Local mod
    #   policy.roles["roles/viewer"] = ["allUsers"] # Local mod
    #
    #   topic.policy = policy # API call
    #
    class Policy
      attr_reader :etag, :roles

      ##
      # @private Creates a Policy object.
      def initialize etag, roles
        @etag = etag
        @roles = roles
      end

      ##
      # @private Convert the Policy to a Google::Iam::V1::Policy object.
      def to_grpc
        Google::Iam::V1::Policy.new(
          etag: etag,
          bindings: roles.keys.map do |role|
            next if roles[role].empty?
            Google::Iam::V1::Binding.new(
              role: role,
              members: roles[role]
            )
          end
        )
      end

      ##
      # @private New Policy from a Google::Iam::V1::Policy object.
      def self.from_grpc grpc
        roles = grpc.bindings.each_with_object({}) do |binding, memo|
          memo[binding.role] = binding.members.to_a
        end
        new grpc.etag, roles
      end
    end
  end
end
