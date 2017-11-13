# Copyright 2014 Google Inc. All rights reserved.
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


require "date"
require "google/devtools/cloudtrace/v1/trace_pb"
require "stackdriver/core/trace_context"

module Google
  module Cloud
    module Trace
      ##
      # Trace represents an entire trace record.
      #
      # A trace has an ID and contains a forest of spans. The trace object
      # methods may be used to walk or manipulate the set of spans.
      #
      # @example
      #   require "google/cloud/trace"
      #
      #   env = {}
      #   trace_context = Stackdriver::Core::TraceContext.parse_rack_env env
      #
      #   trace = Google::Cloud::Trace::TraceRecord.new "my-project",
      #                                                 trace_context
      #   span = trace.create_span "root_span"
      #   subspan = span.create_span "subspan"
      #
      #   trace_proto = trace.to_grpc
      #
      class TraceRecord
        ##
        # Create an empty Trace object. If a trace context is provided, it is
        # used to locate this trace within that context.
        #
        # @param [String] project The ID of the project containing this trace.
        # @param [Stackdriver::Core::TraceContext] trace_context The context
        #     within which to locate this trace (i.e. sets the trace ID and
        #     the context parent span, if present.) If no context is provided,
        #     a new trace with a new trace ID is created.
        #
        def initialize project, trace_context = nil, span_id_generator: nil
          @project = project
          @trace_context = trace_context || Stackdriver::Core::TraceContext.new
          @root_spans = []
          @spans_by_id = {}
          @span_id_generator =
            span_id_generator || ::Proc.new { rand(0xffffffffffffffff) + 1 }
        end

        ##
        # Standard value equality check for this object.
        #
        # @param [Object] other Object to compare with
        # @return [Boolean]
        #
        def eql? other
          other.is_a?(Google::Cloud::Trace::TraceRecord) &&
            trace_context == other.trace_context &&
            @spans_by_id == other.instance_variable_get(:@spans_by_id)
        end
        alias_method :==, :eql?

        ##
        # Create a new Trace object from a trace protobuf.
        #
        # @param [Google::Devtools::Cloudtrace::V1::Trace] trace_proto The
        #     trace protobuf from the V1 gRPC Trace API.
        # @return [Trace, nil] A corresponding Trace object, or `nil` if the
        #     proto does not represent an existing trace object.
        #
        def self.from_grpc trace_proto
          trace_id = trace_proto.trace_id.to_s
          return nil if trace_id.empty?

          span_protos = trace_proto.spans
          parent_span_ids = find_root_span_ids span_protos

          span_id = parent_span_ids.size == 1 ? parent_span_ids.first : 0
          span_id = nil if span_id == 0
          tc = Stackdriver::Core::TraceContext.new trace_id: trace_id,
                                                   span_id: span_id
          trace = new trace_proto.project_id, tc

          until parent_span_ids.empty?
            parent_span_ids = trace.add_span_protos span_protos, parent_span_ids
          end
          trace
        end

        ##
        # Convert this Trace object to an equivalent Trace protobuf suitable
        # for the V1 gRPC Trace API.
        #
        # @return [Google::Devtools::Cloudtrace::V1::Trace] The generated
        #     protobuf.
        #
        def to_grpc
          span_protos = @spans_by_id.values.map do |span|
            span.to_grpc trace_context.span_id.to_i
          end
          Google::Devtools::Cloudtrace::V1::Trace.new \
            project_id: project,
            trace_id: trace_id,
            spans: span_protos
        end

        ##
        # The project ID for this trace.
        #
        # @return [String]
        #
        attr_reader :project
        alias_method :project_id, :project

        ##
        # The context for this trace.
        #
        # @return [Stackdriver::Core::TraceContext]
        #
        attr_reader :trace_context

        ##
        # The ID string for the trace.
        #
        # @return [String]
        #
        def trace_id
          trace_context.trace_id
        end

        ##
        # Returns an array of all spans in this trace, not in any particular
        # order
        #
        # @return [Array{TraceSpan}]
        #
        def all_spans
          @spans_by_id.values
        end

        ##
        # Returns an array of all root spans in this trace, not in any
        # particular order
        #
        # @return [Array{TraceSpan}]
        #
        def root_spans
          @root_spans.dup
        end

        ##
        # Creates a new span in this trace.
        #
        # @param [String] name The name of the span.
        # @param [Integer] span_id The numeric ID of the span, or nil to
        #     generate a new random unique ID. Optional (defaults to nil).
        # @param [Integer] parent_span_id The span ID of the parent span, or 0
        #     if this should be a new root span within the context. Note that
        #     a root span would not necessarily end up with a parent ID of 0 if
        #     the trace context specifies a different context span ID. Optional
        #     (defaults to 0).
        # @param [SpanKind] kind The kind of span. Optional.
        # @param [Time] start_time The starting timestamp, or nil if not yet
        #     specified. Optional (defaults to nil).
        # @param [Time] end_time The ending timestamp, or nil if not yet
        #     specified. Optional (defaults to nil).
        # @param [Hash{String=>String}] labels The span properties. Optional
        #     (defaults to empty).
        # @return [TraceSpan] The created span.
        #
        # @example
        #   require "google/cloud/trace"
        #
        #   trace_record = Google::Cloud::Trace::TraceRecord.new "my-project"
        #   span = trace_record.create_span "root_span"
        #
        def create_span name, span_id: nil, parent_span_id: 0,
                        kind: SpanKind::UNSPECIFIED,
                        start_time: nil, end_time: nil,
                        labels: {}
          parent_span_id = parent_span_id.to_i
          parent_span_id = trace_context.span_id.to_i if parent_span_id == 0
          parent_span = @spans_by_id[parent_span_id]
          if parent_span
            parent_span.create_span name,
                                    span_id: span_id,
                                    kind: kind,
                                    start_time: start_time,
                                    end_time: end_time,
                                    labels: labels
          else
            internal_create_span nil, span_id, parent_span_id, name, kind,
                                 start_time, end_time, labels
          end
        end

        ##
        # Creates a root span around the given block. Automatically populates
        # the start and end timestamps. The span (with start time but not end
        # time populated) is yielded to the block.
        #
        # @param [String] name The name of the span.
        # @param [SpanKind] kind The kind of span. Optional.
        # @param [Hash{String=>String}] labels The span properties. Optional
        #     (defaults to empty).
        # @return [TraceSpan] The created span.
        #
        # @example
        #   require "google/cloud/trace"
        #
        #   trace_record = Google::Cloud::Trace::TraceRecord.new "my-project"
        #   trace_record.in_span "root_span" do |span|
        #     # Do stuff...
        #   end
        #
        def in_span name, kind: SpanKind::UNSPECIFIED, labels: {}
          span = create_span name, kind: kind, labels: labels
          span.start!
          yield span
        ensure
          span.finish!
        end

        ##
        # Internal implementation of span creation. Ensures that a span ID has
        # been allocated, and that the span appears in the internal indexes.
        #
        # @private
        #
        def internal_create_span parent, span_id, parent_span_id, name, kind,
                                 start_time, end_time, labels
          span_id = span_id.to_i
          parent_span_id = parent_span_id.to_i
          span_id = unique_span_id if span_id == 0
          span = Google::Cloud::Trace::Span.new \
            self, span_id, parent_span_id, parent, name, kind,
            start_time, end_time, labels
          @root_spans << span if parent.nil?
          @spans_by_id[span_id] = span
          span
        end

        ##
        # Generates and returns a span ID that is unique in this trace.
        #
        # @private
        #
        def unique_span_id
          loop do
            id = @span_id_generator.call
            return id if !@spans_by_id.include?(id) &&
                         id != trace_context.span_id.to_i
          end
        end

        ##
        # Add the given span to the list of root spans.
        #
        # @private
        #
        def add_root span
          @root_spans << span
        end

        ##
        # Remove the given span from the list of root spans.
        #
        # @private
        #
        def remove_root span
          @root_spans.delete span
        end

        ##
        # Remove the given span from the list of spans overall.
        #
        # @private
        #
        def remove_span span
          @root_spans.delete span
          @spans_by_id.delete span.span_id
        end

        ##
        # Given a list of span protobufs, find the "root" span IDs, i.e. all
        # parent span IDs that don't correspond to actual spans in the set.
        #
        # @private
        #
        def self.find_root_span_ids span_protos
          span_ids = ::Set.new span_protos.map(&:span_id)
          root_protos = span_protos.find_all do |sp|
            !span_ids.include? sp.parent_span_id
          end
          ::Set.new root_protos.map(&:parent_span_id)
        end

        ##
        # Given a list of span protobufs and a set of parent span IDs, add
        # for all spans whose parent is in the set, convert the span to a
        # `TraceSpan` object and add it into this trace. Returns the IDs of
        # the spans added, which may be used in a subsequent call to this
        # method. Effectively, repeated calls to this method perform a
        # breadth-first walk of the span protos and populate the TraceRecord
        # accordingly.
        #
        # @private
        #
        def add_span_protos span_protos, parent_span_ids
          new_span_ids = ::Set.new
          span_protos.each do |span_proto|
            if parent_span_ids.include? span_proto.parent_span_id
              Google::Cloud::Trace::Span.from_grpc span_proto, self
              new_span_ids.add span_proto.span_id
            end
          end
          new_span_ids
        end
      end
    end
  end
end
