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

describe Google::Cloud::Logging::Project, :sinks, :mock_logging do
  it "lists sinks" do
    num_sinks = 3
    list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListSinksResponse.new(list_sinks_hash(num_sinks)))

    mock = Minitest::Mock.new
    mock.expect :list_sinks, list_res, [parent: project_path, page_size: nil, page_token: nil]
    logging.service.mocked_sinks = mock

    sinks = logging.sinks

    mock.verify

    sinks.each { |s| _(s).must_be_kind_of Google::Cloud::Logging::Sink }
    _(sinks.size).must_equal num_sinks
  end

  it "lists sinks with find_sinks alias" do
    num_sinks = 3
    list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListSinksResponse.new(list_sinks_hash(num_sinks)))

    mock = Minitest::Mock.new
    mock.expect :list_sinks, list_res, [parent: project_path, page_size: nil, page_token: nil]
    logging.service.mocked_sinks = mock

    sinks = logging.find_sinks

    mock.verify

    sinks.each { |s| _(s).must_be_kind_of Google::Cloud::Logging::Sink }
    _(sinks.size).must_equal num_sinks
  end

  it "paginates sinks" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListSinksResponse.new(list_sinks_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListSinksResponse.new(list_sinks_hash(2)))

    mock = Minitest::Mock.new
    mock.expect :list_sinks, first_list_res, [parent: project_path, page_size: nil, page_token: nil]
    mock.expect :list_sinks, second_list_res, [parent: project_path, page_size: nil, page_token: "next_page_token"]
    logging.service.mocked_sinks = mock

    first_sinks = logging.sinks
    second_sinks = logging.sinks token: first_sinks.token

    mock.verify

    first_sinks.each { |s| _(s).must_be_kind_of Google::Cloud::Logging::Sink }
    _(first_sinks.count).must_equal 3
    _(first_sinks.token).wont_be :nil?
    _(first_sinks.token).must_equal "next_page_token"

    second_sinks.each { |s| _(s).must_be_kind_of Google::Cloud::Logging::Sink }
    _(second_sinks.count).must_equal 2
    _(second_sinks.token).must_be :nil?
  end

  it "paginates sinks with next? and next" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListSinksResponse.new(list_sinks_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListSinksResponse.new(list_sinks_hash(2)))

    mock = Minitest::Mock.new
    mock.expect :list_sinks, first_list_res, [parent: project_path, page_size: nil, page_token: nil]
    mock.expect :list_sinks, second_list_res, [parent: project_path, page_size: nil, page_token: "next_page_token"]
    logging.service.mocked_sinks = mock

    first_sinks = logging.sinks
    second_sinks = first_sinks.next

    mock.verify

    first_sinks.each { |s| _(s).must_be_kind_of Google::Cloud::Logging::Sink }
    _(first_sinks.count).must_equal 3
    _(first_sinks.next?).must_equal true #must_be :next?

    second_sinks.each { |s| _(s).must_be_kind_of Google::Cloud::Logging::Sink }
    _(second_sinks.count).must_equal 2
    _(second_sinks.next?).must_equal false #wont_be :next?
  end

  it "paginates sinks with next? and next and max set" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListSinksResponse.new(list_sinks_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListSinksResponse.new(list_sinks_hash(2, "second_page_token")))

    mock = Minitest::Mock.new
    mock.expect :list_sinks, first_list_res, [parent: project_path, page_size: 3, page_token: nil]
    mock.expect :list_sinks, second_list_res, [parent: project_path, page_size: 3, page_token: "next_page_token"]
    logging.service.mocked_sinks = mock

    first_sinks = logging.sinks max: 3
    second_sinks = first_sinks.next

    mock.verify

    first_sinks.each { |s| _(s).must_be_kind_of Google::Cloud::Logging::Sink }
    _(first_sinks.count).must_equal 3
    _(first_sinks.next?).must_equal true
    _(first_sinks.token).must_equal "next_page_token"

    # ensure the correct values are propogated to the ivars
    _(first_sinks.instance_variable_get(:@max)).must_equal 3

    second_sinks.each { |s| _(s).must_be_kind_of Google::Cloud::Logging::Sink }
    _(second_sinks.count).must_equal 2
    _(second_sinks.next?).must_equal true
    _(second_sinks.token).must_equal "second_page_token"

    # ensure the correct values are propogated to the ivars
    _(second_sinks.instance_variable_get(:@max)).must_equal 3
  end

  it "paginates sinks with all" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListSinksResponse.new(list_sinks_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListSinksResponse.new(list_sinks_hash(2)))

    mock = Minitest::Mock.new
    mock.expect :list_sinks, first_list_res, [parent: project_path, page_size: nil, page_token: nil]
    mock.expect :list_sinks, second_list_res, [parent: project_path, page_size: nil, page_token: "next_page_token"]
    logging.service.mocked_sinks = mock

    all_sinks = logging.sinks.all.to_a

    mock.verify

    all_sinks.each { |s| _(s).must_be_kind_of Google::Cloud::Logging::Sink }
    _(all_sinks.count).must_equal 5
  end

  it "paginates sinks with all and max set" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListSinksResponse.new(list_sinks_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListSinksResponse.new(list_sinks_hash(2)))

    mock = Minitest::Mock.new
    mock.expect :list_sinks, first_list_res, [parent: project_path, page_size: 3, page_token: nil]
    mock.expect :list_sinks, second_list_res, [parent: project_path, page_size: 3, page_token: "next_page_token"]
    logging.service.mocked_sinks = mock

    all_sinks = logging.sinks(max: 3).all.to_a

    mock.verify

    all_sinks.each { |s| _(s).must_be_kind_of Google::Cloud::Logging::Sink }
    _(all_sinks.count).must_equal 5
  end

  it "paginates sinks with all using Enumerator" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListSinksResponse.new(list_sinks_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListSinksResponse.new(list_sinks_hash(3, "second_page_token")))

    mock = Minitest::Mock.new
    mock.expect :list_sinks, first_list_res, [parent: project_path, page_size: nil, page_token: nil]
    mock.expect :list_sinks, second_list_res, [parent: project_path, page_size: nil, page_token: "next_page_token"]
    logging.service.mocked_sinks = mock

    all_sinks = logging.sinks.all.take(5)

    mock.verify

    all_sinks.each { |s| _(s).must_be_kind_of Google::Cloud::Logging::Sink }
    _(all_sinks.count).must_equal 5
  end

  it "paginates sinks with all and request_limit set" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListSinksResponse.new(list_sinks_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListSinksResponse.new(list_sinks_hash(3, "second_page_token")))

    mock = Minitest::Mock.new
    mock.expect :list_sinks, first_list_res, [parent: project_path, page_size: nil, page_token: nil]
    mock.expect :list_sinks, second_list_res, [parent: project_path, page_size: nil, page_token: "next_page_token"]
    logging.service.mocked_sinks = mock

    all_sinks = logging.sinks.all(request_limit: 1).to_a

    mock.verify

    all_sinks.each { |s| _(s).must_be_kind_of Google::Cloud::Logging::Sink }
    _(all_sinks.count).must_equal 6
  end

  it "paginates sinks with max set" do
    list_req = OpenStruct.new(response: Google::Cloud::Logging::V2::ListSinksRequest.new(parent: project_path, page_size: 3))
    list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListSinksResponse.new(list_sinks_hash(3, "next_page_token")))

    mock = Minitest::Mock.new
    mock.expect :list_sinks, list_res, [parent: project_path, page_size: 3, page_token: nil]
    logging.service.mocked_sinks = mock

    sinks = logging.sinks max: 3

    mock.verify

    sinks.each { |s| _(s).must_be_kind_of Google::Cloud::Logging::Sink }
    _(sinks.count).must_equal 3
    _(sinks.token).wont_be :nil?
    _(sinks.token).must_equal "next_page_token"
  end

  it "paginates sinks without max set" do
    list_req = OpenStruct.new(response: Google::Cloud::Logging::V2::ListSinksRequest.new(parent: project_path))
    list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListSinksResponse.new(list_sinks_hash(3, "next_page_token")))

    mock = Minitest::Mock.new
    mock.expect :list_sinks, list_res, [parent: project_path, page_size: nil, page_token: nil]
    logging.service.mocked_sinks = mock

    sinks = logging.sinks

    mock.verify

    sinks.each { |s| _(s).must_be_kind_of Google::Cloud::Logging::Sink }
    _(sinks.count).must_equal 3
    _(sinks.token).wont_be :nil?
    _(sinks.token).must_equal "next_page_token"
  end

  it "creates a sink" do
    new_sink_name = "new-sink-#{Time.now.to_i}"
    new_sink_destination = "storage.googleapis.com/new-sinks"
    new_sink = Google::Cloud::Logging::V2::LogSink.new name: new_sink_name, destination: new_sink_destination

    create_res = Google::Cloud::Logging::V2::LogSink.new(empty_sink_hash.merge(name: new_sink_name,
                                                                        destination: new_sink_destination,
                                                                        writer_identity: "roles/owner"))

    mock = Minitest::Mock.new
    mock.expect :create_sink, create_res, [parent: "projects/test", sink: new_sink, unique_writer_identity: nil]
    logging.service.mocked_sinks = mock

    sink = logging.create_sink new_sink_name, new_sink_destination

    mock.verify

    _(sink).must_be_kind_of Google::Cloud::Logging::Sink
    _(sink.name).must_equal new_sink_name
    _(sink.destination).must_equal new_sink_destination
    _(sink.filter).must_be :empty?
    _(sink.writer_identity).must_equal "roles/owner"
  end

  it "creates a sink with additional attributes" do
    new_sink_name = "new-sink-#{Time.now.to_i}"
    new_sink_destination = "storage.googleapis.com/new-sinks"
    new_sink_filter = "logName:syslog AND severity>=WARN"
    new_sink = Google::Cloud::Logging::V2::LogSink.new(
      name: new_sink_name,
      destination: new_sink_destination,
      filter: new_sink_filter
    )
    create_res = Google::Cloud::Logging::V2::LogSink.new(empty_sink_hash.merge(
                                                          name: new_sink_name,
                                                          destination: new_sink_destination,
                                                          filter: new_sink_filter,
                                                          writer_identity: "roles/owner"))

    mock = Minitest::Mock.new
    mock.expect :create_sink, create_res, [parent: "projects/test", sink: new_sink, unique_writer_identity: nil]
    logging.service.mocked_sinks = mock

    sink = logging.create_sink new_sink_name,
                               new_sink_destination,
                               filter: new_sink_filter

    mock.verify

    _(sink).must_be_kind_of Google::Cloud::Logging::Sink
    _(sink.name).must_equal new_sink_name
    _(sink.destination).must_equal new_sink_destination
    _(sink.filter).must_equal new_sink_filter
    _(sink.writer_identity).must_equal "roles/owner"
  end

  it "creates a sink with unique_writer_identity" do
    new_sink_name = "new-sink-#{Time.now.to_i}"
    new_sink_destination = "storage.googleapis.com/new-sinks"
    new_sink = Google::Cloud::Logging::V2::LogSink.new name: new_sink_name, destination: new_sink_destination

    create_res = Google::Cloud::Logging::V2::LogSink.new(empty_sink_hash.merge(name: new_sink_name,
                                                                        destination: new_sink_destination,
                                                                        writer_identity: "serviceAccount:cloud-logs@system.gserviceaccount.com"))

    mock = Minitest::Mock.new
    mock.expect :create_sink, create_res, [parent: "projects/test", sink: new_sink, unique_writer_identity: true]
    logging.service.mocked_sinks = mock

    sink = logging.create_sink new_sink_name, new_sink_destination, unique_writer_identity: true

    mock.verify

    _(sink).must_be_kind_of Google::Cloud::Logging::Sink
    _(sink.name).must_equal new_sink_name
    _(sink.destination).must_equal new_sink_destination
    _(sink.filter).must_be :empty?
    _(sink.writer_identity).must_equal "serviceAccount:cloud-logs@system.gserviceaccount.com"
  end

  it "gets a sink" do
    sink_name = "existing-sink-#{Time.now.to_i}"
    get_res = Google::Cloud::Logging::V2::LogSink.new(random_sink_hash.merge(name: sink_name))

    mock = Minitest::Mock.new
    mock.expect :get_sink, get_res, [sink_name: "projects/test/sinks/#{sink_name}"]
    logging.service.mocked_sinks = mock

    sink = logging.sink sink_name

    mock.verify

    _(sink).must_be_kind_of Google::Cloud::Logging::Sink
    _(sink.name).must_equal sink_name
    _(sink.writer_identity).must_equal "roles/owner"
  end

  def list_sinks_hash count = 2, token = nil
    {
      sinks: count.times.map { random_sink_hash },
      next_page_token: token
    }.delete_if { |_, v| v.nil? }
  end

  def empty_sink_hash
    {
      name:                  "",
      destination:           "",
      filter:                "",
      output_version_format: :VERSION_FORMAT_UNSPECIFIED
    }
  end
end
