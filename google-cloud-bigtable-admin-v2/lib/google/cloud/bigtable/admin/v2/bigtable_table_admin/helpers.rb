# frozen_string_literal: true

# Copyright 2025 Google LLC
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
      module Admin
        module V2
          class GcRule # rubocop:disable Style/Documentation
            ##
            # Construct a GcRule for max_num_versions
            #
            # @param value [Integer] The max_num_versions
            # @return [Google::Cloud::Bigtable::Admin::V2::GcRule]
            #
            def self.max_num_versions value
              new max_num_versions: value
            end

            ##
            # Construct a GcRule for max_age
            #
            # @param value [Google::Protobuf::Duration] The max_age
            # @return [Google::Cloud::Bigtable::Admin::V2::GcRule]
            #
            def self.max_age value
              new max_age: value
            end

            ##
            # Construct a GcRule that is an intersection of rules
            #
            # @param rules [Array<Google::Cloud::Bigtable::Admin::V2::GcRule>] The component rules
            # @return [Google::Cloud::Bigtable::Admin::V2::GcRule]
            #
            def self.intersection *rules
              rules = Array(rules.first) if rules.size == 1
              intersection = Google::Cloud::Bigtable::Admin::V2::GcRule::Intersection.new rules: rules
              new intersection: intersection
            end

            ##
            # Construct a GcRule that is a union of rules
            #
            # @param rules [Array<Google::Cloud::Bigtable::Admin::V2::GcRule>] The component rules
            # @return [Google::Cloud::Bigtable::Admin::V2::GcRule]
            #
            def self.union *rules
              rules = Array(rules.first) if rules.size == 1
              union = Google::Cloud::Bigtable::Admin::V2::GcRule::Union.new rules: rules
              new union: union
            end

            # @private
            def []= key, value
              _oneof_warning key, rule if !value.nil? && !rule.nil? && key != rule.to_s
              super
            end

            # @private
            def max_num_versions= value
              _oneof_warning "max_num_versions", rule if !value.nil? && !rule.nil? && rule != :max_num_versions
              super
            end

            # @private
            def max_age= value
              _oneof_warning "max_age", rule if !value.nil? && !rule.nil? && rule != :max_age
              super
            end

            # @private
            def intersection= value
              _oneof_warning "intersection", rule if !value.nil? && !rule.nil? && rule != :intersection
              super
            end

            # @private
            def union= value
              _oneof_warning "union", rule if !value.nil? && !rule.nil? && rule != :union
              super
            end

            private

            def _oneof_warning cur, last
              warn "WARNING: #{caller(2).first}: At most one GcRule field can be set. " \
                   "Setting GcRule##{cur} automatically clears GcRule##{last}. " \
                   "To suppress this warning, explicitly clear GcRule##{last} to nil first."
            end
          end
        end
      end
    end
  end
end
