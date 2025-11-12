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
        @loggers ||= {}
        @loggers[name] ||= begin
          if is_logging_enabled
            logger = Logger.new $stdout
            prog_name = "pubsub"
            prog_name = "#{prog_name}:#{name}" unless name.nil? || name.empty?
            logger.progname = prog_name
            logger
          else
            Logger.new nil
          end
        end
      end

      def self.is_logging_enabled
        packages = ENV["GOOGLE_SDK_RUBY_LOGGING"]&.split(",") || []
        packages.include?("pubsub") || packages.include?("all")
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
        
      end
    end
  end
end
