# Copyright 2016 Google LLC
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
    module Bigquery
      ##
      # # Time
      #
      # A TIME data type represents a time, independent of a specific date.
      #
      # @attr_writer [String] value The BigQuery TIME.
      #
      # @example
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #
      #   fourpm = Google::Cloud::Bigquery::Time.new "16:00:00"
      #   data = bigquery.query "SELECT name " \
      #                         "FROM `my_project.my_dataset.my_table`" \
      #                         "WHERE time_of_date = @time",
      #                         params: { time: fourpm }
      #
      #   data.each do |row|
      #     puts row[:name]
      #   end
      #
      # @example Create Time with fractional seconds:
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #
      #   precise_time = Google::Cloud::Bigquery::Time.new "16:35:15.376541"
      #   data = bigquery.query "SELECT name " \
      #                         "FROM `my_project.my_dataset.my_table`" \
      #                         "WHERE time_of_date >= @time",
      #                         params: { time: precise_time }
      #
      #   data.each do |row|
      #     puts row[:name]
      #   end
      #
      Time = Struct.new :value
    end
  end
end
