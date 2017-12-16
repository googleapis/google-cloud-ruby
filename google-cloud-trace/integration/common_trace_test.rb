# Copyright 2017 Google LLC
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


require "trace_helper"

describe Google::Cloud::Trace, :trace do
  it "automatically creates trace for a ingress request" do
    results = nil
    keep_trying_till_true 300 do
      send_request "test_trace"
      result_set = @tracer.list_traces Time.now - 30, Time.now, filter: "+root:/test_trace"
      results = result_set.instance_variable_get :@results
      !results.empty?
    end

    results.wont_be_empty
  end

  it "allows custom spans with custom labels" do
    token = rand(0x100000000000).to_s
    results = nil
    keep_trying_till_true 300 do
      send_request "test_trace", "token=#{token}"
      result_set = @tracer.list_traces Time.now - 30, Time.now, filter: "+root:/test_trace +span:integration_test_span", view: :COMPLETE
      results = result_set.instance_variable_get :@results
      !results.empty?
    end

    results.wont_be_empty

    span_found = false
    results.each do |trace_record|
      trace_record.all_spans.wont_be_empty
      trace_record.all_spans.each do |span|
        span_found = true if span.name == "integration_test_span" && span.labels["token"] == token
      end
    end
    span_found.must_equal true
  end
end
