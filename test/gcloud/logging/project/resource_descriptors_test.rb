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

describe Gcloud::Logging::Project, :resource_descriptors, :mock_logging do
  it "lists resource descriptors" do
    num_descriptors = 3
    mock_connection.get "/v2beta1/monitoredResourceDescriptors" do |env|
      [200, {"Content-Type"=>"application/json"},
       list_resource_descriptors_json(num_descriptors)]
    end

    resource_descriptors = logging.resource_descriptors
    resource_descriptors.each { |m| m.must_be_kind_of Gcloud::Logging::ResourceDescriptor }
    resource_descriptors.size.must_equal num_descriptors
  end

  it "lists resource descriptors with find_resource_descriptors alias" do
    num_descriptors = 3
    mock_connection.get "/v2beta1/monitoredResourceDescriptors" do |env|
      [200, {"Content-Type"=>"application/json"},
       list_resource_descriptors_json(num_descriptors)]
    end

    resource_descriptors = logging.find_resource_descriptors
    resource_descriptors.each { |m| m.must_be_kind_of Gcloud::Logging::ResourceDescriptor }
    resource_descriptors.size.must_equal num_descriptors
  end

  it "paginates resource descriptors" do
    mock_connection.get "/v2beta1/monitoredResourceDescriptors" do |env|
      env.params.wont_include "pageToken"
      [200, {"Content-Type"=>"application/json"},
       list_resource_descriptors_json(3, "next_page_token")]
    end
    mock_connection.get "/v2beta1/monitoredResourceDescriptors" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type"=>"application/json"},
       list_resource_descriptors_json(2)]
    end

    first_descriptors = logging.resource_descriptors
    first_descriptors.each { |m| m.must_be_kind_of Gcloud::Logging::ResourceDescriptor }
    first_descriptors.count.must_equal 3
    first_descriptors.token.wont_be :nil?
    first_descriptors.token.must_equal "next_page_token"

    second_descriptors = logging.resource_descriptors token: first_descriptors.token
    second_descriptors.each { |m| m.must_be_kind_of Gcloud::Logging::ResourceDescriptor }
    second_descriptors.count.must_equal 2
    second_descriptors.token.must_be :nil?
  end

  it "paginates resource descriptors with next? and next" do
    mock_connection.get "/v2beta1/monitoredResourceDescriptors" do |env|
      env.params.wont_include "pageToken"
      [200, {"Content-Type"=>"application/json"},
       list_resource_descriptors_json(3, "next_page_token")]
    end
    mock_connection.get "/v2beta1/monitoredResourceDescriptors" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type"=>"application/json"},
       list_resource_descriptors_json(2)]
    end

    first_descriptors = logging.resource_descriptors
    first_descriptors.each { |m| m.must_be_kind_of Gcloud::Logging::ResourceDescriptor }
    first_descriptors.count.must_equal 3
    first_descriptors.next?.must_equal true #must_be :next?

    second_descriptors = first_descriptors.next
    second_descriptors.each { |m| m.must_be_kind_of Gcloud::Logging::ResourceDescriptor }
    second_descriptors.count.must_equal 2
    second_descriptors.next?.must_equal false #wont_be :next?
  end

  it "paginates resource descriptors with max set" do
    mock_connection.get "/v2beta1/monitoredResourceDescriptors" do |env|
      env.params.must_include "maxResults"
      env.params["maxResults"].must_equal "3"
      [200, {"Content-Type"=>"application/json"},
       list_resource_descriptors_json(3, "next_page_token")]
    end

    resource_descriptors = logging.resource_descriptors max: 3
    resource_descriptors.each { |m| m.must_be_kind_of Gcloud::Logging::ResourceDescriptor }
    resource_descriptors.count.must_equal 3
    resource_descriptors.token.wont_be :nil?
    resource_descriptors.token.must_equal "next_page_token"
  end

  it "paginates resource descriptors without max set" do
    mock_connection.get "/v2beta1/monitoredResourceDescriptors" do |env|
      env.params.wont_include "maxResults"
      [200, {"Content-Type"=>"application/json"},
       list_resource_descriptors_json(3, "next_page_token")]
    end

    resource_descriptors = logging.resource_descriptors
    resource_descriptors.each { |m| m.must_be_kind_of Gcloud::Logging::ResourceDescriptor }
    resource_descriptors.count.must_equal 3
    resource_descriptors.token.wont_be :nil?
    resource_descriptors.token.must_equal "next_page_token"
  end

  def list_resource_descriptors_json count = 2, token = nil
    {
      resourceDescriptors: count.times.map { random_resource_descriptor_hash },
      nextPageToken: token
    }.delete_if { |_, v| v.nil? }.to_json
  end
end
