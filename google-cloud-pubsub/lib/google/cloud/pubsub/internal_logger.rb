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
require "logger"

require "google/cloud/config"

module Google
  module Cloud
    module PubSub
      ##
      # @private
      class InternalLogger
        LOG_NAME = "pubsub".freeze
        VALID_LOG_LEVELS = [:debug, :info, :warn, :error, :fatal].freeze
        private_constant :VALID_LOG_LEVELS, :LOG_NAME

        ##
        # @private
        # rubocop:disable Naming/BlockForwarding
        def log level, subtag, &message_block
          return unless VALID_LOG_LEVELS.include?(level) && block_given?
          # Only log if the logger is explicitly tagged for 'pubsub'.
          return unless @logger && @logger.progname == LOG_NAME

          @logger.public_send(level, "#{LOG_NAME}:#{subtag}", &message_block)
        end
        # rubocop:enable Naming/BlockForwarding

        ##
        # @private
        def log_batch logger_name, reason, type, num_messages, total_bytes
          log :info, logger_name do
            "#{reason} triggered #{type} batch of #{num_messages} messages, a total of #{total_bytes} bytes"
          end
        end

        ##
        # @private
        def log_ack_nack ack_ids, type
          ack_ids.each do |ack_id|
            log :info, "ack-nack" do
              "message (ackID #{ack_id}) #{type}"
            end
          end
        end

        ##
        # @private
        def log_expiry expired
          expired.each do |ack_id, item|
            log :info, "expiry" do
              "message (ID #{item.message_id}, ackID #{ack_id}) has been dropped from leasing due to a timeout"
            end
          end
        end

        private

        def initialize logger
          @logger = logger || Logger.new(nil)
        end
      end
    end
  end
end
