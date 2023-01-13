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


class AggregateQueryResults

  attr_reader :read_time

  def self.from_grpc aggregate_query_results
    aggregate_fields = aggregate_query_results
                        .batch
                        .aggregation_results[0]
                        .aggregate_properties
                        .to_h
                        .transform_values { |v| v[:integer_value] }
    new.tap do |s|
      s.instance_variable_set :@aggregate_fields, aggregate_fields
      s.instance_variable_set :@read_time, aggregate_query_results.batch.read_time
    end
  end

  def get aggregate_alias
    @aggregate_fields[aggregate_alias]
  end
end