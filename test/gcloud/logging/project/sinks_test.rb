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

describe Gcloud::Logging::Project, :sinks, :mock_logging do
  it "lists sinks" do
    num_sinks = 3
    mock_connection.get "/v2beta1/projects/#{project}/sinks" do |env|
      [200, {"Content-Type"=>"application/json"},
       list_sinks_json(num_sinks)]
    end

    sinks = logging.sinks
    sinks.each { |s| s.must_be_kind_of Gcloud::Logging::Sink }
    sinks.size.must_equal num_sinks
  end

  it "lists sinks with find_sinks alias" do
    num_sinks = 3
    mock_connection.get "/v2beta1/projects/#{project}/sinks" do |env|
      [200, {"Content-Type"=>"application/json"},
       list_sinks_json(num_sinks)]
    end

    sinks = logging.find_sinks
    sinks.each { |s| s.must_be_kind_of Gcloud::Logging::Sink }
    sinks.size.must_equal num_sinks
  end

  it "paginates sinks" do
    mock_connection.get "/v2beta1/projects/#{project}/sinks" do |env|
      env.params.wont_include "pageToken"
      [200, {"Content-Type"=>"application/json"},
       list_sinks_json(3, "next_page_token")]
    end
    mock_connection.get "/v2beta1/projects/#{project}/sinks" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type"=>"application/json"},
       list_sinks_json(2)]
    end

    first_sinks = logging.sinks
    first_sinks.each { |s| s.must_be_kind_of Gcloud::Logging::Sink }
    first_sinks.count.must_equal 3
    first_sinks.token.wont_be :nil?
    first_sinks.token.must_equal "next_page_token"

    second_sinks = logging.sinks token: first_sinks.token
    second_sinks.each { |s| s.must_be_kind_of Gcloud::Logging::Sink }
    second_sinks.count.must_equal 2
    second_sinks.token.must_be :nil?
  end

  it "paginates sinks with max set" do
    mock_connection.get "/v2beta1/projects/#{project}/sinks" do |env|
      env.params.must_include "maxResults"
      env.params["maxResults"].must_equal "3"
      [200, {"Content-Type"=>"application/json"},
       list_sinks_json(3, "next_page_token")]
    end

    sinks = logging.sinks max: 3
    sinks.each { |s| s.must_be_kind_of Gcloud::Logging::Sink }
    sinks.count.must_equal 3
    sinks.token.wont_be :nil?
    sinks.token.must_equal "next_page_token"
  end

  it "paginates sinks without max set" do
    mock_connection.get "/v2beta1/projects/#{project}/sinks" do |env|
      env.params.wont_include "maxResults"
      [200, {"Content-Type"=>"application/json"},
       list_sinks_json(3, "next_page_token")]
    end

    sinks = logging.sinks
    sinks.each { |s| s.must_be_kind_of Gcloud::Logging::Sink }
    sinks.count.must_equal 3
    sinks.token.wont_be :nil?
    sinks.token.must_equal "next_page_token"
  end

  def list_sinks_json count = 2, token = nil
    {
      sinks: count.times.map { random_sink_hash },
      nextPageToken: token
    }.delete_if { |_, v| v.nil? }.to_json
  end
end
