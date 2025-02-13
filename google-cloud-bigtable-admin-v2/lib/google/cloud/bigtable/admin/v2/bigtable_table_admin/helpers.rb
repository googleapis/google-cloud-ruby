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

require "gapic/common/polling_harness"

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

          module BigtableTableAdmin
            class Client # rubocop:disable Style/Documentation
              ##
              # Wait until the given table consistently reflects mutations up
              # to this point.
              #
              # @param name [String] The table name, in the form
              #     `projects/{project}/instances/{instance}/tables/{table}`.
              # @param consistency_token [String] A consistency token
              #     identifying the mutations to be checked. If not provided,
              #     one is generated automatically.
              # @param retry_policy [Gapic::Common::RetryPolicy] A retry policy.
              #     If not provided, uses the given initial_delay, max_delay,
              #     multipler, timeout, and retry_codes.
              # @param initial_delay [Numeric] Initial delay in seconds.
              #     Defaults to 1.
              # @param max_delay [Numeric] Maximum delay in seconds.
              #     Defaults to 15.
              # @param multiplier [Numeric] The delay scaling factor for each
              #     subsequent retry attempt. Defaults to 1.3.
              # @param retry_codes [Array<String|Integer>] List of retry codes.
              # @param timeout [Numeric] Timeout threshold value in seconds.
              #     Defaults to 3600 (1 hour).
              #
              # @return [nil] If the table is now consistent.
              # @return [String] The consistency token if the wait timed out.
              #     The returned token can be passed into another call to wait
              #     again for the same mutation set.
              #
              def wait_for_replication name, consistency_token: nil,
                                       retry_policy: nil,
                                       initial_delay: nil,
                                       max_delay: nil,
                                       multiplier: nil,
                                       retry_codes: nil,
                                       timeout: nil,
                                       mock_delay: false
                consistency_token ||= generate_consistency_token(name: name).consistency_token
                poller = Gapic::Common::PollingHarness.new retry_policy: retry_policy,
                                                           initial_delay: initial_delay, max_delay: max_delay,
                                                           multiplier: multiplier, retry_codes: retry_codes,
                                                           timeout: timeout
                poller.wait timeout_result: consistency_token, wait_sentinel: :wait, mock_delay: mock_delay do
                  response = check_consistency name: name, consistency_token: consistency_token
                  response.consistent ? nil : :wait
                end
              end
            end
          end
        end
      end
    end
  end
end
