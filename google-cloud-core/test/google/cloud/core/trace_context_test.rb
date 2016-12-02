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


require "helper"
require "google/cloud/core/trace_context"

describe Google::Cloud::Core::TraceContext do
  it "generates a new context with a randomly generated trace ID" do
    tc = Google::Cloud::Core::TraceContext.new
    tc.trace_id.must_match /\w{32}/
    tc.span_id.must_be_nil
    tc.sampled?.must_be_nil
    tc.new?.must_equal true
  end

  describe ".parse_string" do
    it "parses a header string with trace ID only" do
      tc = Google::Cloud::Core::TraceContext.parse_string \
        "0123456789abcdef0123456789abcdef"
      tc.trace_id.must_equal "0123456789abcdef0123456789abcdef"
      tc.span_id.must_be_nil
      tc.sampled?.must_be_nil
      tc.new?.must_equal false
    end

    it "parses a header string with span ID" do
      tc = Google::Cloud::Core::TraceContext.parse_string \
        "0123456789abcdef0123456789abcdef/987654321"
      tc.trace_id.must_equal "0123456789abcdef0123456789abcdef"
      tc.span_id.must_equal 987654321
      tc.sampled?.must_be_nil
    end

    it "parses a header string with option 1" do
      tc = Google::Cloud::Core::TraceContext.parse_string \
        "0123456789abcdef0123456789abcdef;o=1"
      tc.trace_id.must_equal "0123456789abcdef0123456789abcdef"
      tc.span_id.must_be_nil
      tc.sampled?.must_equal true
    end

    it "parses a header string with option 0" do
      tc = Google::Cloud::Core::TraceContext.parse_string \
        "0123456789abcdef0123456789abcdef;o=0"
      tc.trace_id.must_equal "0123456789abcdef0123456789abcdef"
      tc.span_id.must_be_nil
      tc.sampled?.must_equal false
    end

    it "parses a header string with all fields" do
      tc = Google::Cloud::Core::TraceContext.parse_string \
        "0123456789abcdef0123456789abcdef/987654321;o=1"
      tc.trace_id.must_equal "0123456789abcdef0123456789abcdef"
      tc.span_id.must_equal 987654321
      tc.sampled?.must_equal true
    end
  end

  describe ".to_string" do
    it "parses a header string with trace ID only" do
      tc = Google::Cloud::Core::TraceContext.new \
        trace_id: "0123456789abcdef0123456789abcdef"
      tc.to_string.must_equal "0123456789abcdef0123456789abcdef"
    end

    it "parses a header string with span ID" do
      tc = Google::Cloud::Core::TraceContext.new \
        trace_id: "0123456789abcdef0123456789abcdef", span_id: 987654321
      tc.to_string.must_equal "0123456789abcdef0123456789abcdef/987654321"
    end

    it "parses a header string with options" do
      tc = Google::Cloud::Core::TraceContext.new \
        trace_id: "0123456789abcdef0123456789abcdef", sampled: true
      tc.to_string.must_equal "0123456789abcdef0123456789abcdef;o=1"
    end

    it "parses a header string with all fields" do
      tc = Google::Cloud::Core::TraceContext.new \
        trace_id: "0123456789abcdef0123456789abcdef", span_id: 987654321,
        sampled: false
      tc.to_string.must_equal "0123456789abcdef0123456789abcdef/987654321;o=0"
    end
  end

  describe ".parse_rack_env" do
    it "uses the memoized value if present" do
      original_tc = Google::Cloud::Core::TraceContext.new \
        trace_id: "0123456789abcdef0123456789abcdef", span_id: 987654321,
        sampled: true
      env = {
        "HTTP_X_CLOUD_TRACE_CONTEXT" =>
          "0123456789abcdef0123456789abcdef/123456789;o=0",
        Google::Cloud::Core::TraceContext::MEMO_RACK_KEY => original_tc
      }
      tc = Google::Cloud::Core::TraceContext.parse_rack_env env
      tc.must_equal original_tc
      tc.must_equal env[Google::Cloud::Core::TraceContext::MEMO_RACK_KEY]
    end

    it "reads a trace context header" do
      env = {"HTTP_X_CLOUD_TRACE_CONTEXT" =>
        "0123456789abcdef0123456789abcdef/987654321;o=1"}
      tc = Google::Cloud::Core::TraceContext.parse_rack_env env
      tc.trace_id.must_equal "0123456789abcdef0123456789abcdef"
      tc.span_id.must_equal 987654321
      tc.sampled?.must_equal true
      tc.new?.must_equal false
      tc.must_equal env[Google::Cloud::Core::TraceContext::MEMO_RACK_KEY]
    end

    it "initializes a default context when no header is found" do
      env = {}
      tc = Google::Cloud::Core::TraceContext.parse_rack_env(env)
      tc.trace_id.must_match /\w{32}/
      tc.span_id.must_be_nil
      tc.sampled?.must_be_nil
      tc.new?.must_equal true
      tc.must_equal env[Google::Cloud::Core::TraceContext::MEMO_RACK_KEY]
    end

    it "calls the given block if provided" do
      original_tc = Google::Cloud::Core::TraceContext.new \
        trace_id: "0123456789abcdef0123456789abcdef", span_id: 987654321,
        sampled: true
      modified_tc = Google::Cloud::Core::TraceContext.new \
        trace_id: "0123456789abcdef0123456789abcdef", span_id: 123456789,
        sampled: false
      env = { Google::Cloud::Core::TraceContext::MEMO_RACK_KEY => original_tc }
      tc = Google::Cloud::Core::TraceContext.parse_rack_env(env) { |c, e|
        c.must_equal original_tc
        modified_tc
      }
      tc.must_equal modified_tc
      tc.must_equal env[Google::Cloud::Core::TraceContext::MEMO_RACK_KEY]
    end
  end

  it "can be saved and retrieved from the thread" do
    Google::Cloud::Core::TraceContext.get.must_be_nil
    tc = Google::Cloud::Core::TraceContext.new
    Google::Cloud::Core::TraceContext.set tc
    Google::Cloud::Core::TraceContext.get.must_equal tc
  end
end
