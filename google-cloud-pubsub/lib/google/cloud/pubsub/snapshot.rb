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


require "google/cloud/errors"
require "google/cloud/pubsub/snapshot/list"

module Google
  module Cloud
    module Pubsub
      ##
      # # Snapshot
      #
      # A named resource created from a subscription to retain a stream of
      # messages from a topic. A snapshot is guaranteed to retain:
      #
      # * The existing backlog on the subscription. More precisely, this is
      #   defined as the messages in the subscription's backlog that are
      #   unacknowledged upon the successful completion of the
      #   `create_snapshot` operation; as well as:
      # * Any messages published to the subscription's topic following the
      #   successful completion of the `create_snapshot` operation.
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud::Pubsub.new
      #   sub = pubsub.subscription "my-sub"
      #
      #   snapshot = sub.create_snapshot "my-snapshot"
      #   snapshot.name #=> "projects/my-project/snapshots/my-snapshot"
      #
      class Snapshot
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private The gRPC Google::Pubsub::V1::Snapshot object.
        attr_accessor :grpc

        ##
        # @private Create an empty {Snapshot} object.
        def initialize
          @service = nil
          @grpc = Google::Pubsub::V1::Snapshot.new
        end

        ##
        # The name of the snapshot. Format is
        # `projects/{project}/snapshots/{snap}`.
        def name
          @grpc.name
        end

        ##
        # The {Topic} from which this snapshot is retaining messages.
        #
        # @return [Topic]
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   sub = pubsub.subscription "my-sub"
        #
        #   snapshot = sub.create_snapshot "my-snapshot"
        #   snapshot.topic.name #=> "projects/my-project/topics/my-topic"
        #
        def topic
          Topic.from_name @grpc.topic, service
        end

        ##
        # The snapshot is guaranteed to exist up until this time.
        # A newly-created snapshot expires no later than 7 days from the time of
        # its creation. Its exact lifetime is determined at creation by the
        # existing backlog in the source subscription. Specifically, the
        # lifetime of the snapshot is 7 days - (age of oldest unacked message in
        # the subscription). For example, consider a subscription whose oldest
        # unacked message is 3 days old. If a snapshot is created from this
        # subscription, the snapshot -- which will always capture this 3-day-old
        # backlog as long as the snapshot exists -- will expire in 4 days.
        #
        # @return [Time] The time until which the snapshot is guaranteed to
        #   exist.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #   sub = pubsub.subscription "my-sub"
        #
        #   snapshot = sub.create_snapshot "my-snapshot"
        #   snapshot.topic.name #=> "projects/my-project/topics/my-topic"
        #   snapshot.expiration_time
        #
        def expiration_time
          self.class.timestamp_from_grpc @grpc.expire_time
        end

        ##
        # A hash of user-provided labels associated with this snapshot.
        # Labels can be used to organize and group snapshots.See [Creating and
        # Managing Labels](https://cloud.google.com/pubsub/docs/labels).
        #
        # The returned hash is frozen and changes are not allowed. Use
        # {#labels=} to update the labels for this snapshot.
        #
        # @return [Hash] The frozen labels hash.
        #
        def labels
          @grpc.labels.to_h.freeze
        end

        ##
        # Sets the hash of user-provided labels associated with this
        # snapshot. Labels can be used to organize and group snapshots.
        # Label keys and values can be no longer than 63 characters, can only
        # contain lowercase letters, numeric characters, underscores and dashes.
        # International characters are allowed. Label values are optional. Label
        # keys must start with a letter and each label in the list must have a
        # different key. See [Creating and Managing
        # Labels](https://cloud.google.com/pubsub/docs/labels).
        #
        # @param [Hash] new_labels The new labels hash.
        #
        def labels= new_labels
          raise ArgumentError, "Value must be a Hash" if new_labels.nil?
          labels_map = Google::Protobuf::Map.new(:string, :string)
          Hash(new_labels).each { |k, v| labels_map[String(k)] = String(v) }
          update_grpc = @grpc.dup
          update_grpc.labels = labels_map
          @grpc = service.update_snapshot update_grpc, :labels
        end

        ##
        # Removes an existing snapshot. All messages retained in the snapshot
        # are immediately dropped. After a snapshot is deleted, a new one may be
        # created with the same name, but the new one has no association with
        # the old snapshot or its subscription, unless the same subscription is
        # specified.
        #
        # @return [Boolean] Returns `true` if the snapshot was deleted.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::Pubsub.new
        #
        #   pubsub.snapshots.each do |snapshot|
        #     snapshot.delete
        #   end
        #
        def delete
          ensure_service!
          service.delete_snapshot name
          true
        end

        ##
        # @private New Snapshot from a Google::Pubsub::V1::Snapshot
        # object.
        def self.from_grpc grpc, service
          new.tap do |f|
            f.grpc = grpc
            f.service = service
          end
        end

        ##
        # @private Get a Time object from a Google::Protobuf::Timestamp object.
        def self.timestamp_from_grpc grpc_timestamp
          return nil if grpc_timestamp.nil?
          Time.at grpc_timestamp.seconds, Rational(grpc_timestamp.nanos, 1000)
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end
      end
    end
  end
end
