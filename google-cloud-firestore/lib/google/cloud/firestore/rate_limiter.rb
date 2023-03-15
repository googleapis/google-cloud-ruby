# Copyright 2023 Google LLC
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


require "google/cloud/firestore/v1"
require "google/cloud/firestore/service"
require "google/cloud/firestore/field_path"
require "google/cloud/firestore/field_value"
require "google/cloud/firestore/collection_reference"
require "google/cloud/firestore/document_reference"
require "google/cloud/firestore/document_snapshot"
require "google/cloud/firestore/collection_group"
require "google/cloud/firestore/batch"
require "google/cloud/firestore/transaction"

module Google
  module Cloud
    module Firestore
##
# @private
class RateLimiter

  DEFAULT_STARTING_MAXIMUM_OPS_PER_SECOND = 500

  ##
  # Initialize the object
  def initialize
    @start_time = Time.now
    @last_fetched = Time.now
    @bandwidth = 500
  end

  ##
  # Increase the bandwidth as per 555 rule
  # Updates the @bandwidth attribute.
  #
  # @return [nil]
  def increase_bandwidth
    intervals = (Time.now - @start_time) / 5
    @bandwidth *= (1.5**intervals.floor)
  end

  ##
  # Wait till the number of tokens is available
  # Assumes that the bandwidth is distributed evenly across the entire second.
  #
  # Example - If the limit is 500 qps, then it has been further broken down to 2e+6 nsec
  # per query
  #
  # @return [nil]
  def get_tokens size
    available_time = @last_fetched + (size / @bandwidth)
    waiting_time = max 0, available_time - Time.now
    sleep waiting_time
    @last_fetched = Time.now
    increase_bandwidth
  end
end
    end
  end
end

