# Copyright 2017 Google LLC
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

describe Google::Cloud::Logging::Project, :list_logs, :mock_logging do
  it "lists logs" do
    num_logs = 3

    list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogsResponse.new(list_logs_hash(num_logs)))

    mock = Minitest::Mock.new
    mock.expect :list_logs, list_res, [parent: "projects/#{project}", page_size: nil, page_token: nil]
    logging.service.mocked_logging = mock

    logs = logging.logs

    mock.verify

    logs.each { |m| _(m).must_be_kind_of String }
    _(logs.size).must_equal num_logs
  end

  it "lists logs with find_logs alias" do
    num_logs = 3

    list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogsResponse.new(list_logs_hash(num_logs)))

    mock = Minitest::Mock.new
    mock.expect :list_logs, list_res, [parent: "projects/#{project}", page_size: nil, page_token: nil]
    logging.service.mocked_logging = mock

    logs = logging.find_logs

    mock.verify

    logs.each { |m| _(m).must_be_kind_of String }
    _(logs.size).must_equal num_logs
  end

  it "paginates logs" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogsResponse.new(list_logs_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogsResponse.new(list_logs_hash(2)))

    mock = Minitest::Mock.new
    mock.expect :list_logs, first_list_res, [parent: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_logs, second_list_res, [parent: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    logging.service.mocked_logging = mock

    first_logs = logging.logs
    second_logs = logging.logs token: first_logs.token

    mock.verify

    first_logs.each { |m| _(m).must_be_kind_of String }
    _(first_logs.count).must_equal 3
    _(first_logs.token).wont_be :nil?
    _(first_logs.token).must_equal "next_page_token"

    second_logs.each { |m| _(m).must_be_kind_of String }
    _(second_logs.count).must_equal 2
    _(second_logs.token).must_be :nil?
  end

  it "paginates logs using next? and next" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogsResponse.new(list_logs_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogsResponse.new(list_logs_hash(2)))

    mock = Minitest::Mock.new
    mock.expect :list_logs, first_list_res, [parent: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_logs, second_list_res, [parent: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    logging.service.mocked_logging = mock

    first_logs = logging.logs
    second_logs = first_logs.next

    mock.verify

    first_logs.each { |m| _(m).must_be_kind_of String }
    _(first_logs.count).must_equal 3
    _(first_logs.next?).must_equal true #must_be :next?

    second_logs.each { |m| _(m).must_be_kind_of String }
    _(second_logs.count).must_equal 2
    _(second_logs.next?).must_equal false #wont_be :next?
  end

  it "paginates logs using all" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogsResponse.new(list_logs_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogsResponse.new(list_logs_hash(2)))

    mock = Minitest::Mock.new
    mock.expect :list_logs, first_list_res, [parent: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_logs, second_list_res, [parent: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    logging.service.mocked_logging = mock

    all_logs = logging.logs.all.to_a

    mock.verify

    all_logs.each { |m| _(m).must_be_kind_of String }
    _(all_logs.count).must_equal 5
  end

  it "paginates logs using all using Enumerator" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogsResponse.new(list_logs_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogsResponse.new(list_logs_hash(3, "second_page_token")))

    mock = Minitest::Mock.new
    mock.expect :list_logs, first_list_res, [parent: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_logs, second_list_res, [parent: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    logging.service.mocked_logging = mock

    all_logs = logging.logs.all.take(5)

    mock.verify

    all_logs.each { |m| _(m).must_be_kind_of String }
    _(all_logs.count).must_equal 5
  end

  it "paginates logs using all with request_limit set" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogsResponse.new(list_logs_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogsResponse.new(list_logs_hash(3, "second_page_token")))

    mock = Minitest::Mock.new
    mock.expect :list_logs, first_list_res, [parent: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_logs, second_list_res, [parent: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    logging.service.mocked_logging = mock

    all_logs = logging.logs.all(request_limit: 1).to_a

    mock.verify

    all_logs.each { |m| _(m).must_be_kind_of String }
    _(all_logs.count).must_equal 6
  end

  it "paginates logs with a resource" do
    list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogsResponse.new(list_logs_hash(3, "next_page_token")))

    mock = Minitest::Mock.new
    mock.expect :list_logs, list_res, [parent: "projects/project1", page_size: nil, page_token: nil]
    logging.service.mocked_logging = mock

    logs = logging.logs resource: "projects/project1"

    mock.verify

    logs.each { |m| _(m).must_be_kind_of String }
    _(logs.count).must_equal 3
    _(logs.token).wont_be :nil?
    _(logs.token).must_equal "next_page_token"
  end

  it "paginates logs with a resource" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogsResponse.new(list_logs_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogsResponse.new(list_logs_hash(2, "second_page_token")))

    mock = Minitest::Mock.new
    mock.expect :list_logs, first_list_res, [parent: "projects/project1", page_size: nil, page_token: nil]
    mock.expect :list_logs, second_list_res, [parent: "projects/project1", page_size: nil, page_token: "next_page_token"]
    logging.service.mocked_logging = mock

    first_logs = logging.logs resource: "projects/project1"
    second_logs = first_logs.next

    mock.verify

    first_logs.each { |m| _(m).must_be_kind_of String }
    _(first_logs.count).must_equal 3
    _(first_logs.next?).must_equal true
    _(first_logs.token).must_equal "next_page_token"

    # ensure the correct values are propogated to the ivars
    _(first_logs.instance_variable_get(:@resource)).must_equal "projects/project1"
    _(first_logs.instance_variable_get(:@max)).must_be_nil

    second_logs.each { |m| _(m).must_be_kind_of String }
    _(second_logs.count).must_equal 2
    _(second_logs.next?).must_equal true
    _(second_logs.token).must_equal "second_page_token"

    # ensure the correct values are propogated to the ivars
    _(second_logs.instance_variable_get(:@resource)).must_equal "projects/project1"
    _(second_logs.instance_variable_get(:@max)).must_be_nil
  end

  it "paginates logs with a resource" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogsResponse.new(list_logs_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogsResponse.new(list_logs_hash(2, "second_page_token")))

    mock = Minitest::Mock.new
    mock.expect :list_logs, first_list_res, [parent: "projects/#{project}", page_size: 3, page_token: nil]
    mock.expect :list_logs, second_list_res, [parent: "projects/#{project}", page_size: 3, page_token: "next_page_token"]
    logging.service.mocked_logging = mock

    first_logs = logging.logs max: 3
    second_logs = first_logs.next

    mock.verify

    first_logs.each { |m| _(m).must_be_kind_of String }
    _(first_logs.count).must_equal 3
    _(first_logs.next?).must_equal true
    _(first_logs.token).must_equal "next_page_token"

    # ensure the correct values are propogated to the ivars
    _(first_logs.instance_variable_get(:@resource)).must_be_nil
    _(first_logs.instance_variable_get(:@max)).must_equal 3

    second_logs.each { |m| _(m).must_be_kind_of String }
    _(second_logs.count).must_equal 2
    _(second_logs.next?).must_equal true
    _(second_logs.token).must_equal "second_page_token"

    # ensure the correct values are propogated to the ivars
    _(second_logs.instance_variable_get(:@resource)).must_be_nil
    _(second_logs.instance_variable_get(:@max)).must_equal 3
  end

  def list_logs_hash count = 2, token = nil
    {
      log_names: count.times.map { "log-name" },
      next_page_token: token
    }.delete_if { |_, v| v.nil? }
  end
end
