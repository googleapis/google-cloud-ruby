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

require "helper"

describe Google::Cloud::Logging::Sink, :mock_logging do
  let(:sink) { Google::Cloud::Logging::Sink.from_grpc sink_grpc, logging.service }
  let(:sink_hash) { random_sink_hash }
  let(:sink_json) { sink_hash.to_json }
  let(:sink_grpc) { Google::Logging::V2::LogSink.decode_json sink_json }

  it "knows its attributes" do
    sink.name.must_equal        sink_hash["name"]
    sink.destination.must_equal sink_hash["destination"]
    sink.filter.must_equal      sink_hash["filter"]
    sink.writer_identity.must_equal  "roles/owner"
  end

  it "has deprecated values" do
    assert_output nil, /version is deprecated/ do
      sink.version.must_equal :V2
    end
    assert_output nil, /version= is deprecated and will be ignored/ do
      sink.version = :V1
    end
    assert_output nil, /unspecified\? is deprecated/ do
      sink.wont_be :unspecified?
    end
    assert_output nil, /v2\? is deprecated/ do
      sink.must_be :v2?
    end
    assert_output nil, /v1\? is deprecated/ do
      sink.wont_be :v1?
    end

    assert_output nil, /start_at is deprecated/ do
      sink.start_at.must_be :nil?
    end
    assert_output nil, /start_at= is deprecated and will be ignored/ do
      sink.start_at = Time.now
    end
    assert_output nil, /start_at is deprecated/ do
      sink.start_time.must_be :nil?
    end
    assert_output nil, /start_at= is deprecated and will be ignored/ do
      sink.start_time = Time.now
    end

    assert_output nil, /end_at is deprecated/ do
      sink.end_at.must_be :nil?
    end
    assert_output nil, /end_at= is deprecated and will be ignored/ do
      sink.end_at = Time.now
    end
    assert_output nil, /end_at is deprecated/ do
      sink.end_time.must_be :nil?
    end
    assert_output nil, /end_at= is deprecated and will be ignored/ do
      sink.end_time = Time.now
    end
  end

  it "can save itself" do
    now = Time.now
    now_grpc = Google::Protobuf::Timestamp.new(seconds: now.to_i, nanos: now.nsec)
    sink_grpc.start_time = nil
    sink_grpc.end_time = now_grpc

    new_sink_destination = "storage.googleapis.com/new-sink-bucket"
    new_sink_filter = "logName:syslog AND severity>=WARN"
    new_sink = Google::Logging::V2::LogSink.new(
      name: sink.name,
      destination: new_sink_destination,
      filter: new_sink_filter
    )
    mock = Minitest::Mock.new
    mock.expect :update_sink, sink_grpc, ["projects/test/sinks/#{sink.name}", new_sink, unique_writer_identity: nil, options: default_options]
    sink.service.mocked_sinks = mock

    sink.destination = new_sink_destination
    sink.filter = new_sink_filter
    sink.save

    mock.verify

    sink.must_be_kind_of Google::Cloud::Logging::Sink
    sink.destination.must_equal new_sink_destination
    sink.filter.must_equal new_sink_filter
    sink.writer_identity.must_equal "roles/owner"
  end

  it "can save itself with unique_writer_identity" do
    now = Time.now
    now_grpc = Google::Protobuf::Timestamp.new(seconds: now.to_i, nanos: now.nsec)

    sink_grpc.writer_identity = "serviceAccount:cloud-logs@system.gserviceaccount.com"

    new_sink_destination = "storage.googleapis.com/new-sink-bucket"
    new_sink_filter = "logName:syslog AND severity>=WARN"
    new_sink = Google::Logging::V2::LogSink.new(
      name: sink.name,
      destination: new_sink_destination,
      filter: new_sink_filter
    )
    mock = Minitest::Mock.new
    mock.expect :update_sink, sink_grpc, ["projects/test/sinks/#{sink.name}", new_sink, unique_writer_identity: true, options: default_options]
    sink.service.mocked_sinks = mock

    sink.destination = new_sink_destination
    sink.filter = new_sink_filter

    sink.save unique_writer_identity: true

    mock.verify

    sink.must_be_kind_of Google::Cloud::Logging::Sink
    sink.destination.must_equal new_sink_destination
    sink.filter.must_equal new_sink_filter
    sink.writer_identity.must_equal "serviceAccount:cloud-logs@system.gserviceaccount.com"
  end

  it "can refresh itself" do
    mock = Minitest::Mock.new
    mock.expect :get_sink, sink_grpc, ["projects/test/sinks/#{sink.name}", options: default_options]
    sink.service.mocked_sinks = mock

    sink.refresh!

    mock.verify
  end

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_sink, sink_grpc, ["projects/test/sinks/#{sink.name}", options: default_options]
    sink.service.mocked_sinks = mock

    sink.delete

    mock.verify
  end
end
