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

describe Gcloud::Logging::Project, :resources, :mock_logging do
  it "lists resources" do
    num_resources = 3
    mock_connection.get "/v2beta1/monitoredResourceDescriptors" do |env|
      [200, {"Content-Type"=>"application/json"},
       list_resources_json(num_resources)]
    end

    resources = logging.resources
    resources.each { |m| m.must_be_kind_of Gcloud::Logging::Resource }
    resources.size.must_equal num_resources
  end

  it "lists resources with find_resources alias" do
    num_resources = 3
    mock_connection.get "/v2beta1/monitoredResourceDescriptors" do |env|
      [200, {"Content-Type"=>"application/json"},
       list_resources_json(num_resources)]
    end

    resources = logging.find_resources
    resources.each { |m| m.must_be_kind_of Gcloud::Logging::Resource }
    resources.size.must_equal num_resources
  end

  it "paginates resources" do
    mock_connection.get "/v2beta1/monitoredResourceDescriptors" do |env|
      env.params.wont_include "pageToken"
      [200, {"Content-Type"=>"application/json"},
       list_resources_json(3, "next_page_token")]
    end
    mock_connection.get "/v2beta1/monitoredResourceDescriptors" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type"=>"application/json"},
       list_resources_json(2)]
    end

    first_resources = logging.resources
    first_resources.each { |m| m.must_be_kind_of Gcloud::Logging::Resource }
    first_resources.count.must_equal 3
    first_resources.token.wont_be :nil?
    first_resources.token.must_equal "next_page_token"

    second_resources = logging.resources token: first_resources.token
    second_resources.each { |m| m.must_be_kind_of Gcloud::Logging::Resource }
    second_resources.count.must_equal 2
    second_resources.token.must_be :nil?
  end

  it "paginates resources with max set" do
    mock_connection.get "/v2beta1/monitoredResourceDescriptors" do |env|
      env.params.must_include "maxResults"
      env.params["maxResults"].must_equal "3"
      [200, {"Content-Type"=>"application/json"},
       list_resources_json(3, "next_page_token")]
    end

    resources = logging.resources max: 3
    resources.each { |m| m.must_be_kind_of Gcloud::Logging::Resource }
    resources.count.must_equal 3
    resources.token.wont_be :nil?
    resources.token.must_equal "next_page_token"
  end

  it "paginates resources without max set" do
    mock_connection.get "/v2beta1/monitoredResourceDescriptors" do |env|
      env.params.wont_include "maxResults"
      [200, {"Content-Type"=>"application/json"},
       list_resources_json(3, "next_page_token")]
    end

    resources = logging.resources
    resources.each { |m| m.must_be_kind_of Gcloud::Logging::Resource }
    resources.count.must_equal 3
    resources.token.wont_be :nil?
    resources.token.must_equal "next_page_token"
  end

  def list_resources_json count = 2, token = nil
    {
      resourceDescriptors: count.times.map { random_resource_hash },
      nextPageToken: token
    }.delete_if { |_, v| v.nil? }.to_json
  end
end
