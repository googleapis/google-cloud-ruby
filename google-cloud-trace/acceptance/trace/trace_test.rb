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

require "trace_helper"

describe Google::Cloud::Trace, :trace do
  describe "API client" do
    it "writes a trace and reads it back" do
      skip "This test is failing, probably due to a backed up indexer. Skip for now."
      orig_trace = simple_trace
      tracer.patch_traces orig_trace
      trace = wait_until do
        tracer.get_trace orig_trace.trace_id
      end
      trace.must_equal orig_trace
    end

    it "writes traces and lists them" do
      start_time = Time.now.utc - 2
      trace1 = simple_trace
      sleep 0.01
      trace2 = simple_trace
      sleep 0.01
      trace3 = simple_trace
      end_time = Time.now.utc + 1
      tracer.patch_traces [trace1, trace2, trace3]
      all_results = wait_until do
        res = tracer.list_traces start_time, end_time,
                                 view: :COMPLETE,
                                 filter: simple_span_name,
                                 order_by: "start",
                                 page_size: 4
        res.size == 3 ? res : nil
      end
      all_results.to_a.must_equal [trace1, trace2, trace3]
      all_results.results_pending?.must_equal false
      page1 = wait_until do
        res = tracer.list_traces start_time, end_time,
                                 view: :COMPLETE,
                                 filter: simple_span_name,
                                 order_by: "start",
                                 page_size: 2
        res.to_a == [trace1, trace2] ? res : nil
      end
      page1.to_a.must_equal [trace1, trace2]
      page1.results_pending?.must_equal true
      page2 = page1.next_page
      page2.to_a.must_equal [trace3]
      page2.results_pending?.must_equal false
    end
  end
end
