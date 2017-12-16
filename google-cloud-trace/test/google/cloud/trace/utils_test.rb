# Copyright 2016 Google LLC
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

describe Google::Cloud::Trace::Utils do
  let(:secs) { 1234567890 }
  let(:nsecs) { 987654321 }
  let(:time_proto) {
    Google::Protobuf::Timestamp.new seconds: secs, nanos: nsecs
  }
  let(:time_obj) {
    Time.at(secs, Rational(nsecs, 1000))
  }

  it "converts time objects to proto objects" do
    Google::Cloud::Trace::Utils.time_to_grpc(time_obj).must_equal time_proto
  end

  it "converts proto objects to time objects" do
    Google::Cloud::Trace::Utils.grpc_to_time(time_proto).must_equal time_obj
  end
end
