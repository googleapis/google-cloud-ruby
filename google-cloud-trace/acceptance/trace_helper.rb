# Copyright 2016 Google LLC
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

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "google/cloud/trace"

# Create shared trace object so we don't create new for each test
$tracer = Google::Cloud::Trace.new

module Acceptance
  class TraceTest < Minitest::Test
    MIN_DELAY = 2
    MAX_DELAY = 11

    attr_accessor :tracer

    ##
    # Setup project based on available ENV variables
    def setup
      @tracer = $tracer
      @test_id = format "%032x", rand(0x100000000000000000000000000000000)
      refute_nil @tracer, "You do not have an active tracer to run the tests."
      super
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    let(:simple_span_name) { "/path/to/#{@test_id}" }
    let(:simple_span_labels) { { "foo" => "bar" } }

    def simple_trace
      tc = Stackdriver::Core::TraceContext.new.with is_new: false, span_id: 123
      trace = tracer.new_trace trace_context: tc
      now = Time.now.utc
      trace.create_span simple_span_name,
                        start_time: now - 1,
                        end_time: now,
                        labels: simple_span_labels
      trace
    end

    def wait_until
      delay = MIN_DELAY
      while delay <= MAX_DELAY
        sleep delay
        result = yield
        return result if result
        delay += 1
      end
      nil
    end

    # Register this spec type for when :trace is used.
    register_spec_type(self) do |desc, *addl|
      addl.include? :trace
    end
  end
end
