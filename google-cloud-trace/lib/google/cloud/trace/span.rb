# Copyright 2014 Google LLC
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


require "set"
require "google/devtools/cloudtrace/v1/trace_pb"

module Google
  module Cloud
    module Trace
      ##
      # Span represents a span in a trace record. Spans are contained in
      # a trace and arranged in a forest. That is, each span may be a root span
      # or have a parent span, and may have zero or more children.
      #
      class Span
        ##
        # The Trace object containing this span.
        #
        # @return [Google::Cloud::Trace::TraceRecord]
        #
        attr_reader :trace

        ##
        # The TraceSpan object representing this span's parent, or `nil` if
        # this span is a root span.
        #
        # @return [Google::Cloud::Trace::Span, nil]
        #
        attr_reader :parent

        ##
        # The numeric ID of this span.
        #
        # @return [Integer]
        #
        attr_reader :span_id

        ##
        # The ID of the parent span, as an integer that may be zero if this
        # is a true root span.
        #
        # Note that it is possible for a span to be "orphaned", that is, to be
        # a root span with a nonzero parent ID, indicating that parent has not
        # (yet) been written. In that case, `parent` will return nil, but
        # `parent_span_id` will have a value.
        #
        # @return [Integer]
        #
        attr_reader :parent_span_id

        ##
        # The kind of this span.
        #
        # @return [Google::Cloud::Trace::SpanKind]
        #
        attr_accessor :kind

        ##
        # The name of this span.
        #
        # @return [String]
        #
        attr_accessor :name

        ##
        # The starting timestamp of this span in UTC, or `nil` if the
        # starting timestamp has not yet been populated.
        #
        # @return [Time, nil]
        #
        attr_accessor :start_time

        ##
        # The ending timestamp of this span in UTC, or `nil` if the
        # ending timestamp has not yet been populated.
        #
        # @return [Time, nil]
        #
        attr_accessor :end_time

        ##
        # The properties of this span.
        #
        # @return [Hash{String => String}]
        #
        attr_reader :labels

        ##
        # Create an empty Span object.
        #
        # @private
        #
        def initialize trace, id, parent_span_id, parent, name, kind,
                       start_time, end_time, labels
          @trace = trace
          @span_id = id
          @parent_span_id = parent_span_id
          @parent = parent
          @children = []
          @name = name
          @kind = kind
          @start_time = start_time
          @end_time = end_time
          @labels = labels
        end

        ##
        # Standard value equality check for this object.
        #
        # @param [Object] other
        # @return [Boolean]
        #
        # rubocop:disable Metrics/AbcSize
        def eql? other
          other.is_a?(Google::Cloud::Trace::Span) &&
            trace.trace_context == other.trace.trace_context &&
            span_id == other.span_id &&
            parent_span_id == other.parent_span_id &&
            same_children?(other) &&
            kind == other.kind &&
            name == other.name &&
            start_time == other.start_time &&
            end_time == other.end_time &&
            labels == other.labels
        end
        alias_method :==, :eql?

        ##
        # Create a new Span object from a TraceSpan protobuf and insert it
        # into the given trace.
        #
        # @param [Google::Devtools::Cloudtrace::V1::TraceSpan] span_proto The
        #     span protobuf from the V1 gRPC Trace API.
        # @param [Google::Cloud::Trace::TraceRecord] trace The trace object
        #     to contain the span.
        # @return [Google::Cloud::Trace::Span] A corresponding Span object.
        #
        def self.from_grpc span_proto, trace
          labels = {}
          span_proto.labels.each { |k, v| labels[k] = v }
          span_kind = SpanKind.get span_proto.kind
          start_time =
            Google::Cloud::Trace::Utils.grpc_to_time span_proto.start_time
          end_time =
            Google::Cloud::Trace::Utils.grpc_to_time span_proto.end_time
          trace.create_span span_proto.name,
                            parent_span_id: span_proto.parent_span_id.to_i,
                            span_id: span_proto.span_id.to_i,
                            kind: span_kind,
                            start_time: start_time,
                            end_time: end_time,
                            labels: labels
        end

        ##
        # Convert this Span object to an equivalent TraceSpan protobuf suitable
        # for the V1 gRPC Trace API.
        #
        # @param [Integer] default_parent_id The parent span ID to use if the
        #     span has no parent in the trace tree. Optional; defaults to 0.
        # @return [Google::Devtools::Cloudtrace::V1::TraceSpan] The generated
        #     protobuf.
        #
        def to_grpc default_parent_id = 0
          start_proto = Google::Cloud::Trace::Utils.time_to_grpc start_time
          end_proto = Google::Cloud::Trace::Utils.time_to_grpc end_time
          Google::Devtools::Cloudtrace::V1::TraceSpan.new \
            span_id: span_id.to_i,
            kind: kind.to_sym,
            name: name,
            start_time: start_proto,
            end_time: end_proto,
            parent_span_id: parent_span_id || default_parent_id,
            labels: labels
        end

        ##
        # Returns true if this span exists. A span exists until it has been
        # removed from its trace.
        #
        # @return [Boolean]
        #
        def exists?
          !@trace.nil?
        end

        ##
        # Returns the trace context in effect within this span.
        #
        # @return [Stackdriver::Core::TraceContext]
        #
        def trace_context
          ensure_exists!
          trace.trace_context.with span_id: span_id
        end

        ##
        # Returns the trace ID for this span.
        #
        # @return [String] The trace ID string.
        #
        def trace_id
          ensure_exists!
          trace.trace_id
        end

        ##
        # Returns a list of children of this span.
        #
        # @return [Array{TraceSpan}] The children.
        #
        def children
          ensure_exists!
          @children.dup
        end

        ##
        # Creates a new child span under this span.
        #
        # @param [String] name The name of the span.
        # @param [Integer] span_id The numeric ID of the span, or nil to
        #     generate a new random unique ID. Optional (defaults to nil).
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
        #   subspan = span.create_span "subspan"
        #
        def create_span name, span_id: nil, kind: SpanKind::UNSPECIFIED,
                        start_time: nil, end_time: nil,
                        labels: {}
          ensure_exists!
          span = trace.internal_create_span self, span_id, self.span_id, name,
                                            kind, start_time, end_time, labels
          @children << span
          span
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
        #     span.in_span "subspan" do |subspan|
        #       # Do subspan stuff...
        #     end
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
        # Sets the starting timestamp for this span to the current time.
        # Asserts that the timestamp has not yet been set, and throws a
        # RuntimeError if that is not the case.
        # Also ensures that all ancestor spans have already started, and
        # starts them if not.
        #
        def start!
          fail "Span already started" if start_time
          ensure_started
        end

        ##
        # Sets the ending timestamp for this span to the current time.
        # Asserts that the timestamp has not yet been set, and throws a
        # RuntimeError if that is not the case.
        # Also ensures that all descendant spans have also finished, and
        # finishes them if not.
        #
        def finish!
          fail "Span not yet started" unless start_time
          fail "Span already finished" if end_time
          ensure_finished
        end

        ##
        # Sets the starting timestamp for this span to the current time, if
        # it has not yet been set. Also ensures that all ancestor spans have
        # also been started.
        # Does nothing if the starting timestamp for this span is already set.
        #
        def ensure_started
          ensure_exists!
          unless start_time
            self.start_time = ::Time.now.utc
            parent.ensure_started if parent
          end
          self
        end

        ##
        # Sets the ending timestamp for this span to the current time, if
        # it has not yet been set. Also ensures that all descendant spans have
        # also been finished.
        # Does nothing if the ending timestamp for this span is already set.
        #
        def ensure_finished
          ensure_exists!
          unless end_time
            self.end_time = ::Time.now.utc
            @children.each(&:ensure_finished)
          end
          self
        end

        ##
        # Deletes this span, and all descendant spans. After this completes,
        # {Span#exists?} will return `false`.
        #
        def delete
          ensure_exists!
          @children.each(&:delete)
          parent.remove_child(self) if parent
          trace.remove_span(self)
          @trace = nil
          @parent = nil
          self
        end

        ##
        # Moves this span under a new parent, which must be part of the same
        # trace. The entire tree under this span moves with it.
        #
        # @param [Google::Cloud::Trace::Span] new_parent The new parent.
        #
        # @example
        #   require "google/cloud/trace"
        #
        #   trace_record = Google::Cloud::Trace::TraceRecord.new "my-project"
        #   root1 = trace_record.create_span "root_span_1"
        #   root2 = trace_record.create_span "root_span_2"
        #   subspan = root1.create_span "subspan"
        #   subspan.move_under root2
        #
        def move_under new_parent
          ensure_exists!
          ensure_no_cycle! new_parent
          if parent
            parent.remove_child self
          else
            trace.remove_root self
          end
          if new_parent
            new_parent.add_child self
            @parent_span_id = new_parent.span_id
          else
            trace.add_root self
            @parent_span_id = 0
          end
          @parent = new_parent
          self
        end

        ##
        # Add the given span to this span's child list.
        #
        # @private
        #
        def add_child child
          @children << child
        end

        ##
        # Remove the given span from this span's child list.
        #
        # @private
        #
        def remove_child child
          @children.delete child
        end

        ##
        # Ensure this span exists (i.e. has not been deleted) and throw a
        # RuntimeError if not.
        #
        # @private
        #
        def ensure_exists!
          fail "Span has been deleted" unless trace
        end

        ##
        # Ensure moving this span under the given parent would not result
        # in a cycle, and throw a RuntimeError if it would.
        #
        # @private
        #
        def ensure_no_cycle! new_parent
          ptr = new_parent
          until ptr.nil?
            fail "Move would result in a cycle" if ptr.equal?(self)
            ptr = ptr.parent
          end
        end

        ##
        # Returns true if this span has the same children as the given other.
        #
        # @private
        #
        def same_children? other
          child_ids = @children.map(&:span_id)
          other_child_ids = other.children.map(&:span_id)
          ::Set.new(child_ids) == ::Set.new(other_child_ids)
        end
      end
    end
  end
end
