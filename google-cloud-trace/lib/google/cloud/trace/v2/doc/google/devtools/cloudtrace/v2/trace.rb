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

module Google
  module Devtools
    module Cloudtrace
      module V2
        # A span represents a single operation within a trace. Spans can be
        # nested to form a trace tree. Often, a trace contains a root span
        # that describes the end-to-end latency, and one or more subspans for
        # its sub-operations. A trace can also contain multiple root spans,
        # or none at all. Spans do not need to be contiguous&mdash;there may be
        # gaps or overlaps between spans in a trace.
        # @!attribute [rw] name
        #   @return [String]
        #     The resource name of the span in the following format:
        #
        #         projects/[PROJECT_ID]/traces/[TRACE_ID]/spans/[SPAN_ID]
        #
        #     [TRACE_ID] is a unique identifier for a trace within a project;
        #     it is a 32-character hexadecimal encoding of a 16-byte array.
        #
        #     [SPAN_ID] is a unique identifier for a span within a trace; it
        #     is a 16-character hexadecimal encoding of an 8-byte array.
        # @!attribute [rw] span_id
        #   @return [String]
        #     The [SPAN_ID] portion of the span's resource name.
        # @!attribute [rw] parent_span_id
        #   @return [String]
        #     The [SPAN_ID] of this span's parent span. If this is a root span,
        #     then this field must be empty.
        # @!attribute [rw] display_name
        #   @return [Google::Devtools::Cloudtrace::V2::TruncatableString]
        #     A description of the span's operation (up to 128 bytes).
        #     Stackdriver Trace displays the description in the
        #     {% dynamic print site_values.console_name %}.
        #     For example, the display name can be a qualified method name or a file name
        #     and a line number where the operation is called. A best practice is to use
        #     the same display name within an application and at the same call point.
        #     This makes it easier to correlate spans in different traces.
        # @!attribute [rw] start_time
        #   @return [Google::Protobuf::Timestamp]
        #     The start time of the span. On the client side, this is the time kept by
        #     the local machine where the span execution starts. On the server side, this
        #     is the time when the server's application handler starts running.
        # @!attribute [rw] end_time
        #   @return [Google::Protobuf::Timestamp]
        #     The end time of the span. On the client side, this is the time kept by
        #     the local machine where the span execution ends. On the server side, this
        #     is the time when the server application handler stops running.
        # @!attribute [rw] attributes
        #   @return [Google::Devtools::Cloudtrace::V2::Span::Attributes]
        #     A set of attributes on the span. You can have up to 32 attributes per
        #     span.
        # @!attribute [rw] stack_trace
        #   @return [Google::Devtools::Cloudtrace::V2::StackTrace]
        #     Stack trace captured at the start of the span.
        # @!attribute [rw] time_events
        #   @return [Google::Devtools::Cloudtrace::V2::Span::TimeEvents]
        #     A set of time events. You can have up to 32 annotations and 128 message
        #     events per span.
        # @!attribute [rw] links
        #   @return [Google::Devtools::Cloudtrace::V2::Span::Links]
        #     Links associated with the span. You can have up to 128 links per Span.
        # @!attribute [rw] status
        #   @return [Google::Rpc::Status]
        #     An optional final status for this span.
        # @!attribute [rw] same_process_as_parent_span
        #   @return [Google::Protobuf::BoolValue]
        #     (Optional) Set this parameter to indicate whether this span is in
        #     the same process as its parent. If you do not set this parameter,
        #     Stackdriver Trace is unable to take advantage of this helpful
        #     information.
        # @!attribute [rw] child_span_count
        #   @return [Google::Protobuf::Int32Value]
        #     An optional number of child spans that were generated while this span
        #     was active. If set, allows implementation to detect missing child spans.
        class Span
          # A set of attributes, each in the format +[KEY]:[VALUE]+.
          # @!attribute [rw] attribute_map
          #   @return [Hash{String => Google::Devtools::Cloudtrace::V2::AttributeValue}]
          #     The set of attributes. Each attribute's key can be up to 128 bytes
          #     long. The value can be a string up to 256 bytes, an integer, or the
          #     Boolean values +true+ and +false+. For example:
          #
          #         "/instance_id": "my-instance"
          #         "/http/user_agent": ""
          #         "/http/request_bytes": 300
          #         "abc.com/myattribute": true
          # @!attribute [rw] dropped_attributes_count
          #   @return [Integer]
          #     The number of attributes that were discarded. Attributes can be discarded
          #     because their keys are too long or because there are too many attributes.
          #     If this value is 0 then all attributes are valid.
          class Attributes; end

          # A time-stamped annotation or message event in the Span.
          # @!attribute [rw] time
          #   @return [Google::Protobuf::Timestamp]
          #     The timestamp indicating the time the event occurred.
          # @!attribute [rw] annotation
          #   @return [Google::Devtools::Cloudtrace::V2::Span::TimeEvent::Annotation]
          #     Text annotation with a set of attributes.
          # @!attribute [rw] message_event
          #   @return [Google::Devtools::Cloudtrace::V2::Span::TimeEvent::MessageEvent]
          #     An event describing a message sent/received between Spans.
          class TimeEvent
            # Text annotation with a set of attributes.
            # @!attribute [rw] description
            #   @return [Google::Devtools::Cloudtrace::V2::TruncatableString]
            #     A user-supplied message describing the event. The maximum length for
            #     the description is 256 bytes.
            # @!attribute [rw] attributes
            #   @return [Google::Devtools::Cloudtrace::V2::Span::Attributes]
            #     A set of attributes on the annotation. You can have up to 4 attributes
            #     per Annotation.
            class Annotation; end

            # An event describing a message sent/received between Spans.
            # @!attribute [rw] type
            #   @return [Google::Devtools::Cloudtrace::V2::Span::TimeEvent::MessageEvent::Type]
            #     Type of MessageEvent. Indicates whether the message was sent or
            #     received.
            # @!attribute [rw] id
            #   @return [Integer]
            #     An identifier for the MessageEvent's message that can be used to match
            #     SENT and RECEIVED MessageEvents. It is recommended to be unique within
            #     a Span.
            # @!attribute [rw] uncompressed_size_bytes
            #   @return [Integer]
            #     The number of uncompressed bytes sent or received.
            # @!attribute [rw] compressed_size_bytes
            #   @return [Integer]
            #     The number of compressed bytes sent or received. If missing assumed to
            #     be the same size as uncompressed.
            class MessageEvent
              # Indicates whether the message was sent or received.
              module Type
                # Unknown event type.
                TYPE_UNSPECIFIED = 0

                # Indicates a sent message.
                SENT = 1

                # Indicates a received message.
                RECEIVED = 2
              end
            end
          end

          # A collection of +TimeEvent+s. A +TimeEvent+ is a time-stamped annotation
          # on the span, consisting of either user-supplied key:value pairs, or
          # details of a message sent/received between Spans.
          # @!attribute [rw] time_event
          #   @return [Array<Google::Devtools::Cloudtrace::V2::Span::TimeEvent>]
          #     A collection of +TimeEvent+s.
          # @!attribute [rw] dropped_annotations_count
          #   @return [Integer]
          #     The number of dropped annotations in all the included time events.
          #     If the value is 0, then no annotations were dropped.
          # @!attribute [rw] dropped_message_events_count
          #   @return [Integer]
          #     The number of dropped message events in all the included time events.
          #     If the value is 0, then no message events were dropped.
          class TimeEvents; end

          # A pointer from the current span to another span in the same trace or in a
          # different trace. For example, this can be used in batching operations,
          # where a single batch handler processes multiple requests from different
          # traces or when the handler receives a request from a different project.
          # @!attribute [rw] trace_id
          #   @return [String]
          #     The [TRACE_ID] for a trace within a project.
          # @!attribute [rw] span_id
          #   @return [String]
          #     The [SPAN_ID] for a span within a trace.
          # @!attribute [rw] type
          #   @return [Google::Devtools::Cloudtrace::V2::Span::Link::Type]
          #     The relationship of the current span relative to the linked span.
          # @!attribute [rw] attributes
          #   @return [Google::Devtools::Cloudtrace::V2::Span::Attributes]
          #     A set of attributes on the link. You have have up to  32 attributes per
          #     link.
          class Link
            # The relationship of the current span relative to the linked span: child,
            # parent, or unspecified.
            module Type
              # The relationship of the two spans is unknown.
              TYPE_UNSPECIFIED = 0

              # The linked span is a child of the current span.
              CHILD_LINKED_SPAN = 1

              # The linked span is a parent of the current span.
              PARENT_LINKED_SPAN = 2
            end
          end

          # A collection of links, which are references from this span to a span
          # in the same or different trace.
          # @!attribute [rw] link
          #   @return [Array<Google::Devtools::Cloudtrace::V2::Span::Link>]
          #     A collection of links.
          # @!attribute [rw] dropped_links_count
          #   @return [Integer]
          #     The number of dropped links after the maximum size was enforced. If
          #     this value is 0, then no links were dropped.
          class Links; end
        end

        # The allowed types for [VALUE] in a +[KEY]:[VALUE]+ attribute.
        # @!attribute [rw] string_value
        #   @return [Google::Devtools::Cloudtrace::V2::TruncatableString]
        #     A string up to 256 bytes long.
        # @!attribute [rw] int_value
        #   @return [Integer]
        #     A 64-bit signed integer.
        # @!attribute [rw] bool_value
        #   @return [true, false]
        #     A Boolean value represented by +true+ or +false+.
        class AttributeValue; end

        # A call stack appearing in a trace.
        # @!attribute [rw] stack_frames
        #   @return [Google::Devtools::Cloudtrace::V2::StackTrace::StackFrames]
        #     Stack frames in this stack trace. A maximum of 128 frames are allowed.
        # @!attribute [rw] stack_trace_hash_id
        #   @return [Integer]
        #     The hash ID is used to conserve network bandwidth for duplicate
        #     stack traces within a single trace.
        #
        #     Often multiple spans will have identical stack traces.
        #     The first occurrence of a stack trace should contain both the
        #     +stackFrame+ content and a value in +stackTraceHashId+.
        #
        #     Subsequent spans within the same request can refer
        #     to that stack trace by only setting +stackTraceHashId+.
        class StackTrace
          # Represents a single stack frame in a stack trace.
          # @!attribute [rw] function_name
          #   @return [Google::Devtools::Cloudtrace::V2::TruncatableString]
          #     The fully-qualified name that uniquely identifies the function or
          #     method that is active in this frame (up to 1024 bytes).
          # @!attribute [rw] original_function_name
          #   @return [Google::Devtools::Cloudtrace::V2::TruncatableString]
          #     An un-mangled function name, if +function_name+ is
          #     [mangled](http://www.avabodh.com/cxxin/namemangling.html). The name can
          #     be fully-qualified (up to 1024 bytes).
          # @!attribute [rw] file_name
          #   @return [Google::Devtools::Cloudtrace::V2::TruncatableString]
          #     The name of the source file where the function call appears (up to 256
          #     bytes).
          # @!attribute [rw] line_number
          #   @return [Integer]
          #     The line number in +file_name+ where the function call appears.
          # @!attribute [rw] column_number
          #   @return [Integer]
          #     The column number where the function call appears, if available.
          #     This is important in JavaScript because of its anonymous functions.
          # @!attribute [rw] load_module
          #   @return [Google::Devtools::Cloudtrace::V2::Module]
          #     The binary module from where the code was loaded.
          # @!attribute [rw] source_version
          #   @return [Google::Devtools::Cloudtrace::V2::TruncatableString]
          #     The version of the deployed source code (up to 128 bytes).
          class StackFrame; end

          # A collection of stack frames, which can be truncated.
          # @!attribute [rw] frame
          #   @return [Array<Google::Devtools::Cloudtrace::V2::StackTrace::StackFrame>]
          #     Stack frames in this call stack.
          # @!attribute [rw] dropped_frames_count
          #   @return [Integer]
          #     The number of stack frames that were dropped because there
          #     were too many stack frames.
          #     If this value is 0, then no stack frames were dropped.
          class StackFrames; end
        end

        # Binary module.
        # @!attribute [rw] module
        #   @return [Google::Devtools::Cloudtrace::V2::TruncatableString]
        #     For example: main binary, kernel modules, and dynamic libraries
        #     such as libc.so, sharedlib.so (up to 256 bytes).
        # @!attribute [rw] build_id
        #   @return [Google::Devtools::Cloudtrace::V2::TruncatableString]
        #     A unique identifier for the module, usually a hash of its
        #     contents (up to 128 bytes).
        class Module; end

        # Represents a string that might be shortened to a specified length.
        # @!attribute [rw] value
        #   @return [String]
        #     The shortened string. For example, if the original string is 500
        #     bytes long and the limit of the string is 128 bytes, then
        #     +value+ contains the first 128 bytes of the 500-byte string.
        #
        #     Truncation always happens on a UTF8 character boundary. If there
        #     are multi-byte characters in the string, then the length of the
        #     shortened string might be less than the size limit.
        # @!attribute [rw] truncated_byte_count
        #   @return [Integer]
        #     The number of bytes removed from the original string. If this
        #     value is 0, then the string was not shortened.
        class TruncatableString; end
      end
    end
  end
end