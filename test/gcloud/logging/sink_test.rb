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
  let(:sink) { Gcloud::Logging::Sink.from_grpc sink_grpc, logging.service }
  let(:sink_hash) { random_sink_hash }
  let(:sink_json) { sink_hash.to_json }
  let(:sink_grpc) { Google::Logging::V2::LogSink.decode_json sink_json }

  it "knows its attributes" do
    sink.name.must_equal        sink_hash["name"]
    sink.destination.must_equal sink_hash["destination"]
    sink.filter.must_equal      sink_hash["filter"]
    sink.version.must_equal     :VERSION_FORMAT_UNSPECIFIED
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

  it "can save itself" do
    new_sink_destination = "storage.googleapis.com/new-sink-bucket"
    new_sink_filter = "logName:syslog AND severity>=WARN"
    new_sink = Google::Logging::V2::LogSink.new(
      name: sink.name,
      destination: new_sink_destination,
      filter: new_sink_filter,
      output_version_format: :V1
    )
    update_req = Google::Logging::V2::UpdateSinkRequest.new(
      sink_name: "projects/test/sinks/#{sink.name}",
      sink: new_sink
    )
    mock = Minitest::Mock.new
    mock.expect :update_sink, sink_grpc, [update_req]
    sink.service.mocked_sinks = mock

    sink.destination = new_sink_destination
    sink.filter = new_sink_filter
    sink.version = :v1
    sink.save

    mock.verify

    sink.must_be_kind_of Gcloud::Logging::Sink
    sink.destination.must_equal new_sink_destination
    sink.filter.must_equal new_sink_filter
    sink.must_be :v1?
  end

  it "can refresh itself" do
    get_req = Google::Logging::V2::GetSinkRequest.new sink_name: "projects/test/sinks/#{sink.name}"
    mock = Minitest::Mock.new
    mock.expect :get_sink, sink_grpc, [get_req]
    sink.service.mocked_sinks = mock

    sink.refresh!

    mock.verify
  end

  it "can delete itself" do
    delete_req = Google::Logging::V2::DeleteSinkRequest.new sink_name: "projects/test/sinks/#{sink.name}"
    mock = Minitest::Mock.new
    mock.expect :delete_sink, sink_grpc, [delete_req]
    sink.service.mocked_sinks = mock

    sink.delete

    mock.verify
  end
end
