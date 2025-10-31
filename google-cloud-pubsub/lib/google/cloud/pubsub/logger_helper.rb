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
      def self.logger name = ""
        unless name.nil? || name.empty?
          name = "pubsub:#{name}"
        end
        @loggers ||= {}
        @loggers[name] ||= begin
          logger = Logger.new $stdout
          logger.progname = name
          logger
        end
      end

      ##
      # @private
      module LoggerHelper
        private

        def log_batch logger_name, reason, type, num_messages, total_bytes
          Google::Cloud::PubSub.logger(logger_name).info(
            "#{reason} triggered #{type} batch of #{num_messages} messages, a total of #{total_bytes} bytes"
          )
        end

        def log_slow_ack subscriber, removed_items, type
          return if subscriber.histograms.nil? || subscriber.histograms[type].nil?
          time_now = Time.now
          histogram = subscriber.histograms[type]
          removed_items.each do |ack_id, item|
            duration_s = time_now - item.pulled_at
            percentile_s = histogram.percentile 99
            histogram.add duration_s
            next unless duration_s > percentile_s
            Google::Cloud::PubSub.logger("slow-ack").info(
              "message (ID #{item.message_id}, ackID #{ack_id}) #{type} took longer than the 99th percentile of " \
              "message processing time (#{type} duration: #{duration_s} s, 99th percentile: #{percentile_s} s)"
            )
          end
        end
      end
    end
  end
end
