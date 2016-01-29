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
require "logger"

describe Gcloud::Logging::Logger, :debug, :mock_logging do
  let(:log_name) { "web_app_log" }
  let(:resource) do
    Gcloud::Logging::Resource.new.tap do |r|
      r.type = "gce_instance"
      r.labels["zone"] = "global"
      r.labels["instance_id"] = "abc123"
    end
  end
  let(:labels) { { "env" => "production" } }
  let(:logger) { Gcloud::Logging::Logger.new logging, log_name, resource, labels }

  before do
    logger.level = ::Logger::DEBUG
  end

  it "creates a log entry with #debug" do
    mock_connection.post "/v2beta1/entries:write" do |env|
      entries_json = JSON.parse env.body
      entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
      entries_json["resource"].must_equal resource.to_gapi
      entries_json["labels"].must_equal labels
      entries_json["entries"].must_equal [entry_gapi("DEBUG", "Danger Will Robinson!")]
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    logger.debug "Danger Will Robinson!"
  end

  it "creates a log entry with #info" do
    mock_connection.post "/v2beta1/entries:write" do |env|
      entries_json = JSON.parse env.body
      entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
      entries_json["resource"].must_equal resource.to_gapi
      entries_json["labels"].must_equal labels
      entries_json["entries"].must_equal [entry_gapi("INFO", "Danger Will Robinson!")]
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    logger.info "Danger Will Robinson!"
  end

  it "creates a log entry with #warn" do
    mock_connection.post "/v2beta1/entries:write" do |env|
      entries_json = JSON.parse env.body
      entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
      entries_json["resource"].must_equal resource.to_gapi
      entries_json["labels"].must_equal labels
      entries_json["entries"].must_equal [entry_gapi("WARNING", "Danger Will Robinson!")]
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    logger.warn "Danger Will Robinson!"
  end

  it "creates a log entry with #error" do
    mock_connection.post "/v2beta1/entries:write" do |env|
      entries_json = JSON.parse env.body
      entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
      entries_json["resource"].must_equal resource.to_gapi
      entries_json["labels"].must_equal labels
      entries_json["entries"].must_equal [entry_gapi("ERROR", "Danger Will Robinson!")]
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    logger.error "Danger Will Robinson!"
  end

  it "creates a log entry with #fatal" do
    mock_connection.post "/v2beta1/entries:write" do |env|
      entries_json = JSON.parse env.body
      entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
      entries_json["resource"].must_equal resource.to_gapi
      entries_json["labels"].must_equal labels
      entries_json["entries"].must_equal [entry_gapi("CRITICAL", "Danger Will Robinson!")]
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    logger.fatal "Danger Will Robinson!"
  end

  it "creates a log entry with #unknown" do
    mock_connection.post "/v2beta1/entries:write" do |env|
      entries_json = JSON.parse env.body
      entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
      entries_json["resource"].must_equal resource.to_gapi
      entries_json["labels"].must_equal labels
      entries_json["entries"].must_equal [entry_gapi("DEFAULT", "Danger Will Robinson!")]
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    logger.unknown "Danger Will Robinson!"
  end
end
