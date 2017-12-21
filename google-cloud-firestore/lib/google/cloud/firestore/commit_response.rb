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


require "google/cloud/firestore/v1beta1"
require "google/cloud/firestore/convert"

module Google
  module Cloud
    module Firestore
      ##
      # # CommitResponse
      #
      # The response for a commit.
      #
      # @example
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      #   commit_response = firestore.batch do |b|
      #     # Set the data for NYC
      #     b.set("cities/NYC", { name: "New York City" })
      #
      #     # Update the population for SF
      #     b.update("cities/SF", { population: 1000000 })
      #
      #     # Delete LA
      #     b.delete("cities/LA")
      #   end
      #
      #   puts commit_response.commit_time
      #   commit_response.write_results.each do |write_result|
      #     puts write_result.update_time
      #   end
      #
      class CommitResponse
        ##
        # @private
        def initialize
          @commit_time = nil
          @write_results = []
        end

        ##
        # The time at which the commit occurred.
        #
        # @return [Time] The commit time.
        attr_accessor :commit_time

        ##
        # The result of applying the writes.
        #
        # This i-th write result corresponds to the i-th write in the request.
        #
        # @return [Array<CommitResponse::WriteResult>] The write results.
        attr_accessor :write_results

        ##
        # @private
        def self.from_grpc grpc, writes
          return new if grpc.nil?

          commit_time = Convert.timestamp_to_time grpc.commit_time

          all_write_results = Array(grpc.write_results)

          write_results = writes.map do |write|
            update_time = nil
            Array(write).count.times do
              write_grpc = all_write_results.shift
              if write_grpc
                update_time ||= Convert.timestamp_to_time write_grpc.update_time
              end
            end
            update_time ||= commit_time
            WriteResult.new.tap do |write_result|
              write_result.instance_variable_set :@update_time, update_time
            end
          end

          new.tap do |resp|
            resp.instance_variable_set :@commit_time,   commit_time
            resp.instance_variable_set :@write_results, write_results
          end
        end

        ##
        # # WriteResult
        #
        # Represents the result of applying a write.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   commit_response = firestore.batch do |b|
        #     # Set the data for NYC
        #     b.set("cities/NYC", { name: "New York City" })
        #
        #     # Update the population for SF
        #     b.update("cities/SF", { population: 1000000 })
        #
        #     # Delete LA
        #     b.delete("cities/LA")
        #   end
        #
        #   puts commit_response.commit_time
        #   commit_response.write_results.each do |write_result|
        #     puts write_result.update_time
        #   end
        #
        class WriteResult
          ##
          # @private
          def initialize
            @update_time = nil
          end

          ##
          # The last update time of the document after applying the write. Not
          # set after a +delete+.
          #
          # If the write did not actually change the document, this will be
          # the previous update_time.
          #
          # @return [Time] The last update time.
          attr_accessor :update_time
        end
      end
    end
  end
end
