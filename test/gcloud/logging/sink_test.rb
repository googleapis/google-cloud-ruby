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

describe Gcloud::Logging::Sink, :mock_logging do
  let(:sink) { Gcloud::Logging::Sink.from_gapi sink_hash, logging.connection }
  let(:sink_hash) { random_sink_hash }

  it "knows its attributes" do
    sink.name.must_equal        sink_hash["name"]
    sink.destination.must_equal sink_hash["destination"]
    sink.filter.must_equal      sink_hash["filter"]
    sink.version.must_equal     sink_hash["outputVersionFormat"]
  end

  it "can set different sink format versions" do
    sink.must_be :unspecified?
    sink.version = :v2
    sink.must_be :v2?
    sink.version = :v1
    sink.must_be :v1?

    sink.version = "VERSION_FORMAT_UNSPECIFIED"
    sink.must_be :unspecified?
    sink.version = "V2"
    sink.must_be :v2?
    sink.version = "V1"
    sink.must_be :v1?
  end
end
