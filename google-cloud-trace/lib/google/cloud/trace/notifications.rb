# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


module Google
  module Cloud
    module Trace
      ##
      # Utility methods for configuring ActiveSupport notifications to generate
      # spans in the current trace.
      #
      module Notifications
        ##
        # The default max length for label data.
        DEFAULT_MAX_DATA_LENGTH = 1024

        ##
        # The default prefix for label keys
        DEFAULT_LABEL_NAMESPACE = "/ruby/"

        ##
        # Stack truncation method that removes the ActiveSupport::Notifications
        # calls from the top.
        REMOVE_NOTIFICATION_FRAMEWORK =
          lambda do |frame|
            frame.absolute_path !~ %r{/lib/active_support/notifications}
          end

        ##
        # Subscribes to the given event type or any type matching the given
        # pattern. When an event is raised, a span is generated in the current
        # thread's trace. The event payload is exposed as labels on the span.
        # If there is no active trace for the current thread, then no span is
        # generated.
        #
        # @param [String, Regex] type A specific type or pattern to select
        #     notifications to listen for.
        # @param [Integer] max_length The maximum length for label values.
        #     If a label value exceeds this length, it is truncated.
        #     If the length is nil, no truncation takes place.
        # @param [String] label_namespace A string to prepend to all label
        #     keys.
        # @param [Boolean] capture_stack Whether traces should include the
        #     call stack.
        #
        # @example
        #
        #   require "google/cloud/trace"
        #   require "active_record"
        #
        #   Google::Cloud::Trace::Notifications.instrument "sql.activerecord"
        #
        #   trace_record = Google::Cloud::Trace::TraceRecord.new "my-project-id"
        #   Google::Cloud::Trace.set trace_record
        #
        #   ActiveRecord::Base.connection.execute "SHOW TABLES"
        #
        def self.instrument type,
                            max_length: DEFAULT_MAX_DATA_LENGTH,
                            label_namespace: DEFAULT_LABEL_NAMESPACE,
                            capture_stack: false
          require "active_support/notifications"
          ActiveSupport::Notifications.subscribe(type) do |*args|
            event = ActiveSupport::Notifications::Event.new(*args)
            handle_notification_event event, max_length, label_namespace,
                                      capture_stack
          end
        end

        ##
        # @private
        def self.handle_notification_event event, maxlen, label_namespace,
                                           capture_stack
          cur_span = Google::Cloud::Trace.get
          if cur_span && event.time && event.end
            labels = payload_to_labels event, maxlen, label_namespace
            if capture_stack
              Google::Cloud::Trace::LabelKey.set_stack_trace \
                labels,
                skip_frames: 2,
                truncate_stack: REMOVE_NOTIFICATION_FRAMEWORK
            end
            cur_span.create_span event.name,
                                 start_time: event.time,
                                 end_time: event.end,
                                 labels: labels
          end
        end

        ##
        # @private
        def self.payload_to_labels event, maxlen, label_namespace
          labels = {}
          event.payload.each do |k, v|
            if v.is_a? ::String
              v = v[0, maxlen-3] + "..." if maxlen && v.size > maxlen
              labels["#{label_namespace}#{k}"] = v
            end
          end
          labels
        end
      end
    end
  end
end
