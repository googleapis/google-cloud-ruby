# frozen_string_literal: true

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
  module Cloud
    module Bigtable
      class AppProfile
        # AppProfile::List is a special case Array with additional
        # values.
        class List < DelegateClass(::Array)
          # @private
          # The gRPC Service object.
          attr_accessor :service

          # @private
          # The gRPC page enumbrable object.
          attr_accessor :grpc

          # @private
          # Create a new AppProfile::List with an array of Snapshot instances.
          def initialize arr = []
            super(arr)
          end

          # Whether there is a next page of instances.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   instance = bigtable.instance("my-instance")
          #   app_profiles = instance.app_profiles
          #
          #   if app_profiles.next?
          #     next_app_profiles = app_profiles.next
          #   end
          def next?
            grpc.next_page?
          end

          # Retrieve the next page of app_profiles.
          #
          # @return [AppProfile::List] The list of instances.
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   instance = bigtable.instance("my-instance")
          #   app_profiles = instance.app_profiles
          #
          #   if app_profiles.next?
          #     next_app_profiles = app_profiles.next
          #   end
          def next
            ensure_grpc!

            return nil unless next?
            grpc.next_page
            self.class.from_grpc(grpc, service)
          end

          # Retrieves remaining results by repeatedly invoking {#next} until
          # {#next?} returns `false`. Calls the given block once for each
          # result, which is passed as the argument to the block.
          #
          # An Enumerator is returned if no block is given.
          #
          # This method will make repeated API calls until all remaining results
          # are retrieved. (Unlike `#each`, for example, which merely iterates
          # over the results returned by a single API call.) Use with caution.
          #
          # @yield [app_profile] The block for accessing each instance.
          # @yieldparam [AppProfile] instance The instance object.
          #
          # @return [Enumerator]
          #
          # @example Iterating each instance by passing a block:
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   instance = bigtable.instance("my-instance")
          #   app_profiles = instance.app_profiles
          #
          #   instance.app_profiles.all do |app_profile|
          #     puts app_profile.name
          #   end
          #
          # @example Using the enumerator by not passing a block:
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   instance = bigtable.instance("my-instance")
          #
          #   all_snapshot_ids = instance.app_profiles.all.map do |app_profile|
          #     app_profile.name
          #   end
          #
          def all
            return enum_for(:all) unless block_given?

            results = self
            loop do
              results.each { |r| yield r }
              break unless next?
              grpc.next_page
              results = self.class.from_grpc(grpc, service)
            end
          end

          # @private
          # New Snapshot::List from a Google::Gax::PagedEnumerable<Google::Bigtable::Admin::V2::AppProfile> object.
          # @param grpc [Google::Gax::PagedEnumerable<Google::Bigtable::Admin::V2::AppProfile> ]
          # @param service [Google::Cloud::Bigtable::Service]
          # @return [Array<Google::Cloud::Bigtable::AppProfile>]
          def self.from_grpc grpc, service
            app_profiles = List.new(
              Array(grpc.response.app_profiles).map do |app_profile|
                AppProfile.from_grpc(app_profile, service)
              end
            )
            app_profiles.grpc = grpc
            app_profiles.service = service
            app_profiles
          end

          protected

          # @private
          #
          # Raise an error if active grpc call is not available.
          def ensure_grpc!
            raise "Must have active grpc call" unless grpc
          end
        end
      end
    end
  end
end
