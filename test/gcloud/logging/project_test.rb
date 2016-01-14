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

describe Gcloud::Logging::Project, :mock_logging do
  it "knows the project identifier" do
    logging.must_be_kind_of Gcloud::Logging::Project
    logging.project.must_equal project
  end

  it "deletes a log" do
    log_name = "syslog"

    mock_connection.delete "/v2beta1/projects/#{project}/logs/#{log_name}" do |env|
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    success = logging.delete_log log_name
    success.must_equal true
  end

  it "deletes a log with full path name" do
    log_name = "projects/#{project}/logs/syslog"

    mock_connection.delete "/v2beta1/#{log_name}" do |env|
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    success = logging.delete_log log_name
    success.must_equal true
  end
end
