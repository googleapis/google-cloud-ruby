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


require "google/cloud/firestore/v1"
require "google/cloud/firestore/convert"
require "google/cloud/firestore/document_reference"
require "google/cloud/firestore/document_snapshot"
require "google/cloud/firestore/document_change"
require "google/cloud/firestore/query_snapshot"
require "rbtree"

module Google
  module Cloud
    module Firestore
      ##
      # @private
      module Watch
        # @private
        module Order
          module ClassMethods
            def compare_field_values a_value, b_value
              field_comparison(a_value) <=> field_comparison(b_value)
            end

            def field_comparison value
              [field_type(value), field_value(value)]
            end

            def field_type value
              return 0 if value.nil?
              return 1 if value == false
              return 1 if value == true
              # The backend ordering semantics treats NaN and Numbers as the
              # same type, and then internally orders NaNs before Numbers.
              # Ruby's Float::NAN cannot be compared, similar to nil, so we need
              # to use a stand in value instead. Therefore the desired sorting
              # is achieved by separating NaN and Number types. This is an
              # intentional divergence from type order that is used in the
              # backend and in the other SDKs.
              # (And because Ruby has to be special.)
              return 2 if value.respond_to?(:nan?) && value.nan?
              return 3 if value.is_a? Numeric
              return 4 if value.is_a? Time
              return 5 if value.is_a? String
              return 6 if value.is_a? StringIO
              return 7 if value.is_a? DocumentReference
              return 9 if value.is_a? Array
              if value.is_a? Hash
                return 8 if Convert.hash_is_geo_point? value
                return 10
              end

              raise "Can't determine field type for #{value.class}"
            end

            def field_value value
              # nil can't be compared, so use 0 as a stand in.
              return 0 if value.nil?
              return 0 if value == false
              return 1 if value == true
              # NaN can't be compared, so use 0 as a stand in.
              return 0 if value.respond_to?(:nan?) && value.nan?
              return value if value.is_a? Numeric
              return value if value.is_a? Time
              return value if value.is_a? String
              return value.string if value.is_a? StringIO
              if value.is_a? DocumentReference
                return value.path.split "/"
              end
              return value.map { |v| field_comparison v } if value.is_a? Array
              if value.is_a? Hash
                geo_pairs = Convert.hash_is_geo_point? value
                return geo_pairs.map(&:last) if geo_pairs
                return value.sort.map { |k, v| [k, field_comparison(v)] }
              end

              raise "Can't determine field value for #{value}"
            end
          end

          extend ClassMethods
        end
      end
    end
  end
end
