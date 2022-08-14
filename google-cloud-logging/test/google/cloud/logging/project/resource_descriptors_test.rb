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

describe Google::Cloud::Logging::Project, :resource_descriptors, :mock_logging do
  it "lists resource descriptors" do
    num_descriptors = 3

    mock = Minitest::Mock.new
    mock.expect :list_monitored_resource_descriptors, list_resource_descriptors_hash(num_descriptors), page_size: nil, page_token: nil
    logging.service.mocked_logging = mock

    resource_descriptors = logging.resource_descriptors

    mock.verify

    resource_descriptors.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::ResourceDescriptor }
    _(resource_descriptors.size).must_equal num_descriptors
  end

  it "lists resource descriptors with find_resource_descriptors alias" do
    num_descriptors = 3

    mock = Minitest::Mock.new
    mock.expect :list_monitored_resource_descriptors, list_resource_descriptors_hash(num_descriptors), page_size: nil, page_token: nil
    logging.service.mocked_logging = mock

    resource_descriptors = logging.find_resource_descriptors

    mock.verify

    resource_descriptors.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::ResourceDescriptor }
    _(resource_descriptors.size).must_equal num_descriptors
  end

  it "paginates resource descriptors" do
    mock = Minitest::Mock.new
    mock.expect :list_monitored_resource_descriptors, list_resource_descriptors_hash(3, "next_page_token"), page_size: nil, page_token: nil
    mock.expect :list_monitored_resource_descriptors, list_resource_descriptors_hash(2), page_size: nil, page_token: "next_page_token"
    logging.service.mocked_logging = mock

    first_descriptors = logging.resource_descriptors
    second_descriptors = logging.resource_descriptors token: first_descriptors.token

    mock.verify

    first_descriptors.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::ResourceDescriptor }
    _(first_descriptors.count).must_equal 3
    _(first_descriptors.token).wont_be :nil?
    _(first_descriptors.token).must_equal "next_page_token"

    second_descriptors.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::ResourceDescriptor }
    _(second_descriptors.count).must_equal 2
    _(second_descriptors.token).must_be :nil?
  end

  it "paginates resource descriptors with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_monitored_resource_descriptors, list_resource_descriptors_hash(3, "next_page_token"), page_size: nil, page_token: nil
    mock.expect :list_monitored_resource_descriptors, list_resource_descriptors_hash(2), page_size: nil, page_token: "next_page_token"

    logging.service.mocked_logging = mock

    first_descriptors = logging.resource_descriptors
    second_descriptors = first_descriptors.next

    mock.verify

    first_descriptors.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::ResourceDescriptor }
    _(first_descriptors.count).must_equal 3
    _(first_descriptors.next?).must_equal true #must_be :next?

    second_descriptors.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::ResourceDescriptor }
    _(second_descriptors.count).must_equal 2
    _(second_descriptors.next?).must_equal false #wont_be :next?
  end

  it "paginates resource descriptors with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_monitored_resource_descriptors, list_resource_descriptors_hash(3, "next_page_token"), page_size: 3, page_token: nil
    mock.expect :list_monitored_resource_descriptors, list_resource_descriptors_hash(2, "second_page_token"), page_size: 3, page_token: "next_page_token"

    logging.service.mocked_logging = mock

    first_descriptors = logging.resource_descriptors max: 3
    second_descriptors = first_descriptors.next

    mock.verify

    first_descriptors.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::ResourceDescriptor }
    _(first_descriptors.count).must_equal 3
    _(first_descriptors.next?).must_equal true
    _(first_descriptors.token).must_equal "next_page_token"

    # ensure the correct values are propogated to the ivars
    _(first_descriptors.instance_variable_get(:@max)).must_equal 3

    second_descriptors.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::ResourceDescriptor }
    _(second_descriptors.count).must_equal 2
    _(second_descriptors.next?).must_equal true
    _(second_descriptors.token).must_equal "second_page_token"

    # ensure the correct values are propogated to the ivars
    _(second_descriptors.instance_variable_get(:@max)).must_equal 3
  end

  it "paginates resource descriptors with all" do
    mock = Minitest::Mock.new
    mock.expect :list_monitored_resource_descriptors, list_resource_descriptors_hash(3, "next_page_token"), page_size: nil, page_token: nil
    mock.expect :list_monitored_resource_descriptors, list_resource_descriptors_hash(2), page_size: nil, page_token: "next_page_token"

    logging.service.mocked_logging = mock

    descriptors = logging.resource_descriptors.all.to_a

    mock.verify

    descriptors.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::ResourceDescriptor }
    _(descriptors.count).must_equal 5
  end

  it "paginates resource descriptors with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_monitored_resource_descriptors, list_resource_descriptors_hash(3, "next_page_token"), page_size: 3, page_token: nil
    mock.expect :list_monitored_resource_descriptors, list_resource_descriptors_hash(2), page_size: 3, page_token: "next_page_token"

    logging.service.mocked_logging = mock

    descriptors = logging.resource_descriptors(max: 3).all.to_a

    mock.verify

    descriptors.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::ResourceDescriptor }
    _(descriptors.count).must_equal 5
  end

  it "paginates resource descriptors with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_monitored_resource_descriptors, list_resource_descriptors_hash(3, "next_page_token"), page_size: nil, page_token: nil
    mock.expect :list_monitored_resource_descriptors, list_resource_descriptors_hash(3, "second_page_token"), page_size: nil, page_token: "next_page_token"

    logging.service.mocked_logging = mock

    descriptors = logging.resource_descriptors.all.take(5)

    mock.verify

    descriptors.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::ResourceDescriptor }
    _(descriptors.count).must_equal 5
  end

  it "paginates resource descriptors with all and request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_monitored_resource_descriptors, list_resource_descriptors_hash(3, "next_page_token"), page_size: nil, page_token: nil
    mock.expect :list_monitored_resource_descriptors, list_resource_descriptors_hash(3, "second_page_token"), page_size: nil, page_token: "next_page_token"

    logging.service.mocked_logging = mock

    descriptors = logging.resource_descriptors.all(request_limit: 1).to_a

    mock.verify

    descriptors.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::ResourceDescriptor }
    _(descriptors.count).must_equal 6
  end

  it "paginates resource descriptors with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_monitored_resource_descriptors, list_resource_descriptors_hash(3, "next_page_token"), page_size: 3, page_token: nil
    logging.service.mocked_logging = mock

    resource_descriptors = logging.resource_descriptors max: 3

    mock.verify

    resource_descriptors.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::ResourceDescriptor }
    _(resource_descriptors.count).must_equal 3
    _(resource_descriptors.token).wont_be :nil?
    _(resource_descriptors.token).must_equal "next_page_token"
  end

  it "paginates resource descriptors without max set" do
    mock = Minitest::Mock.new
    mock.expect :list_monitored_resource_descriptors, list_resource_descriptors_hash(3, "next_page_token"), page_size: nil, page_token: nil
    logging.service.mocked_logging = mock

    resource_descriptors = logging.resource_descriptors

    mock.verify

    resource_descriptors.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::ResourceDescriptor }
    _(resource_descriptors.count).must_equal 3
    _(resource_descriptors.token).wont_be :nil?
    _(resource_descriptors.token).must_equal "next_page_token"
  end

  def list_resource_descriptors_hash count = 2, token = nil
    response = {
      resource_descriptors: count.times.map { random_resource_descriptor_hash },
      next_page_token: token
    }.delete_if { |_, v| v.nil? }
    ::Gapic::PagedEnumerable.new nil, 
                                 :list_monitored_resource_descriptors, 
                                 Google::Cloud::Logging::V2::ListMonitoredResourceDescriptorsRequest.new, 
                                 Google::Cloud::Logging::V2::ListMonitoredResourceDescriptorsResponse.new(response), 
                                 nil, 
                                 nil
  end
end
