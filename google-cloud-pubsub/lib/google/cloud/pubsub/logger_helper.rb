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

module Google
  module Cloud
    module PubSub
      LOG_NAME = "pubsub".freeze
      private_constant :LOG_NAME

      def self.logger
        is_logging_enabled ? configure.logger : Logger.new(nil)
      end

      def self.is_logging_enabled
        begin
          env_var = ENV["GOOGLE_SDK_RUBY_LOGGING_GEMS"]
          return false if (configure.logger.nil? || env_var == "none")
          return true if env_var == "all"
          # parse env var by removing whitespace and splitting by comma
          packages = env_var&.gsub(/\s+/, "")&.split(",") || []
          packages.include?(LOG_NAME)
        rescue StandardError => e
          warn "Failed to determine logging configuration. Logging disabled. Error: #{e.class}: #{e.message}"
          false
        end
      end

      ##
      # @private
      module LoggerHelper
        VALID_LOG_LEVELS = [:debug, :info, :warn, :error, :fatal].freeze
        private_constant :VALID_LOG_LEVELS

        private

        # rubocop:disable Naming/BlockForwarding
        def log_safely level, subtag, &message_block
          return unless VALID_LOG_LEVELS.include?(level) && block_given?
          begin
            Google::Cloud::PubSub.logger.public_send(level, "#{LOG_NAME}:#{subtag}", &message_block)
          rescue StandardError
            # Ignore all logging errors.
          end
        end
        # rubocop:enable Naming/BlockForwarding

        def log_batch logger_name, reason, type, num_messages, total_bytes
          log_safely :info, logger_name do
            "#{reason} triggered #{type} batch of #{num_messages} messages, a total of #{total_bytes} bytes"
          end
        end

        def log_ack_nack ack_ids, type
          # exit early to avoid unnecessary loop
          return unless Google::Cloud::PubSub.is_logging_enabled
          ack_ids.each do |ack_id|
            log_safely :info, "ack-nack" do
              "message (ackID #{ack_id}) #{type}"
            end
          end
        end

        def log_expiry expired
          # exit early to avoid unnecessary loop
          return unless Google::Cloud::PubSub.is_logging_enabled
          expired.each do |ack_id, item|
            log_safely :info, "expiry" do
              "message (ID #{item.message_id}, ackID #{ack_id}) has been dropped from leasing due to a timeout"
            end
          end
        end
      end
    end
  end
end
