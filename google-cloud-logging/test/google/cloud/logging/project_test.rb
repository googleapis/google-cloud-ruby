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

describe Google::Cloud::Logging::Project, :mock_logging do
  it "knows the project identifier" do
    logging.must_be_kind_of Google::Cloud::Logging::Project
    logging.project.must_equal project
  end

  it "creates an empty entry" do
    entry = logging.entry
    entry.must_be_kind_of Google::Cloud::Logging::Entry
    entry.resource.must_be_kind_of Google::Cloud::Logging::Resource
  end

  it "creates an entry with all attributes" do
    log_name = "log_name"
    resource = logging.resource "gae_app",
                                "module_id" => "1",
                                "version_id" => "20150925t173233"
    timestamp = Time.now
    severity = "DEBUG"
    insert_id = "123456"
    labels = { "env" => "production" }
    payload = { "pay" => "load" }

    entry = logging.entry log_name: log_name,
                          resource: resource,
                          timestamp: timestamp,
                          severity: severity,
                          insert_id: insert_id,
                          labels: labels,
                          payload: payload

    entry.must_be_kind_of Google::Cloud::Logging::Entry
    entry.log_name.must_equal log_name
    entry.resource.must_equal resource
    entry.timestamp.must_equal timestamp
    entry.severity.must_equal severity
    entry.insert_id.must_equal insert_id
    entry.labels.must_equal labels
    entry.payload.must_equal payload
  end

  it "creates a resource instance" do
    resource = logging.resource "gae_app",
                                "module_id" => "1",
                                "version_id" => "20150925t173233"
    resource.must_be_kind_of Google::Cloud::Logging::Resource
    resource.type.must_equal   "gae_app"
    resource.labels["module_id"].must_equal "1"
    resource.labels["version_id"].must_equal "20150925t173233"
  end

  it "deletes a log" do
    log_name = "syslog"

    mock = Minitest::Mock.new
    mock.expect :delete_log, Google::Protobuf::Empty.new, ["projects/#{project}/logs/#{log_name}", options: default_options]
    logging.service.mocked_logging = mock

    success = logging.delete_log log_name

    mock.verify

    success.must_equal true
  end

  it "deletes a log with full path name" do
    log_name = "projects/#{project}/logs/syslog"

    mock = Minitest::Mock.new
    mock.expect :delete_log, Google::Protobuf::Empty.new, [log_name, options: default_options]
    logging.service.mocked_logging = mock

    success = logging.delete_log log_name

    mock.verify

    success.must_equal true
  end
end
