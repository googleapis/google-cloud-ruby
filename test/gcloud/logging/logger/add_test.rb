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

describe Gcloud::Logging::Logger, :add, :mock_logging do
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

  describe :debug do
    it "creates a log entry using :debug" do
      mock_connection.post "/v2beta1/entries:write" do |env|
        entries_json = JSON.parse env.body
        entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
        entries_json["resource"].must_equal resource.to_gapi
        entries_json["labels"].must_equal labels
        entries_json["entries"].must_equal [entry_gapi("DEBUG", "Danger Will Robinson!")]
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      logger.add :debug, "Danger Will Robinson!"
    end

    it "creates a log entry using 'debug'" do
      mock_connection.post "/v2beta1/entries:write" do |env|
        entries_json = JSON.parse env.body
        entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
        entries_json["resource"].must_equal resource.to_gapi
        entries_json["labels"].must_equal labels
        entries_json["entries"].must_equal [entry_gapi("DEBUG", "Danger Will Robinson!")]
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      logger.add "debug", "Danger Will Robinson!"
    end

    it "creates a log entry using Logger::DEBUG" do
      mock_connection.post "/v2beta1/entries:write" do |env|
        entries_json = JSON.parse env.body
        entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
        entries_json["resource"].must_equal resource.to_gapi
        entries_json["labels"].must_equal labels
        entries_json["entries"].must_equal [entry_gapi("DEBUG", "Danger Will Robinson!")]
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      logger.add ::Logger::DEBUG, "Danger Will Robinson!"
    end
  end

  describe :info do
    it "creates a log entry using :info" do
      mock_connection.post "/v2beta1/entries:write" do |env|
        entries_json = JSON.parse env.body
        entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
        entries_json["resource"].must_equal resource.to_gapi
        entries_json["labels"].must_equal labels
        entries_json["entries"].must_equal [entry_gapi("INFO", "Danger Will Robinson!")]
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      logger.add :info, "Danger Will Robinson!"
    end

    it "creates a log entry using 'info'" do
      mock_connection.post "/v2beta1/entries:write" do |env|
        entries_json = JSON.parse env.body
        entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
        entries_json["resource"].must_equal resource.to_gapi
        entries_json["labels"].must_equal labels
        entries_json["entries"].must_equal [entry_gapi("INFO", "Danger Will Robinson!")]
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      logger.add "info", "Danger Will Robinson!"
    end

    it "creates a log entry using Logger::INFO" do
      mock_connection.post "/v2beta1/entries:write" do |env|
        entries_json = JSON.parse env.body
        entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
        entries_json["resource"].must_equal resource.to_gapi
        entries_json["labels"].must_equal labels
        entries_json["entries"].must_equal [entry_gapi("INFO", "Danger Will Robinson!")]
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      logger.add ::Logger::INFO, "Danger Will Robinson!"
    end
  end

  describe :warn do
    it "creates a log entry using :warn" do
      mock_connection.post "/v2beta1/entries:write" do |env|
        entries_json = JSON.parse env.body
        entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
        entries_json["resource"].must_equal resource.to_gapi
        entries_json["labels"].must_equal labels
        entries_json["entries"].must_equal [entry_gapi("WARNING", "Danger Will Robinson!")]
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      logger.add :warn, "Danger Will Robinson!"
    end

    it "creates a log entry using 'warn'" do
      mock_connection.post "/v2beta1/entries:write" do |env|
        entries_json = JSON.parse env.body
        entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
        entries_json["resource"].must_equal resource.to_gapi
        entries_json["labels"].must_equal labels
        entries_json["entries"].must_equal [entry_gapi("WARNING", "Danger Will Robinson!")]
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      logger.add "warn", "Danger Will Robinson!"
    end

    it "creates a log entry using Logger::WARN" do
      mock_connection.post "/v2beta1/entries:write" do |env|
        entries_json = JSON.parse env.body
        entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
        entries_json["resource"].must_equal resource.to_gapi
        entries_json["labels"].must_equal labels
        entries_json["entries"].must_equal [entry_gapi("WARNING", "Danger Will Robinson!")]
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      logger.add ::Logger::WARN, "Danger Will Robinson!"
    end
  end

  describe :error do
    it "creates a log entry using :error" do
      mock_connection.post "/v2beta1/entries:write" do |env|
        entries_json = JSON.parse env.body
        entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
        entries_json["resource"].must_equal resource.to_gapi
        entries_json["labels"].must_equal labels
        entries_json["entries"].must_equal [entry_gapi("ERROR", "Danger Will Robinson!")]
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      logger.add :error, "Danger Will Robinson!"
    end

    it "creates a log entry using 'error'" do
      mock_connection.post "/v2beta1/entries:write" do |env|
        entries_json = JSON.parse env.body
        entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
        entries_json["resource"].must_equal resource.to_gapi
        entries_json["labels"].must_equal labels
        entries_json["entries"].must_equal [entry_gapi("ERROR", "Danger Will Robinson!")]
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      logger.add "error", "Danger Will Robinson!"
    end

    it "creates a log entry using Logger::ERROR" do
      mock_connection.post "/v2beta1/entries:write" do |env|
        entries_json = JSON.parse env.body
        entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
        entries_json["resource"].must_equal resource.to_gapi
        entries_json["labels"].must_equal labels
        entries_json["entries"].must_equal [entry_gapi("ERROR", "Danger Will Robinson!")]
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      logger.add ::Logger::ERROR, "Danger Will Robinson!"
    end
  end

  describe :fatal do
    it "creates a log entry using :fatal" do
      mock_connection.post "/v2beta1/entries:write" do |env|
        entries_json = JSON.parse env.body
        entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
        entries_json["resource"].must_equal resource.to_gapi
        entries_json["labels"].must_equal labels
        entries_json["entries"].must_equal [entry_gapi("CRITICAL", "Danger Will Robinson!")]
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      logger.add :fatal, "Danger Will Robinson!"
    end

    it "creates a log entry using 'fatal'" do
      mock_connection.post "/v2beta1/entries:write" do |env|
        entries_json = JSON.parse env.body
        entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
        entries_json["resource"].must_equal resource.to_gapi
        entries_json["labels"].must_equal labels
        entries_json["entries"].must_equal [entry_gapi("CRITICAL", "Danger Will Robinson!")]
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      logger.add "fatal", "Danger Will Robinson!"
    end

    it "creates a log entry using Logger::FATAL" do
      mock_connection.post "/v2beta1/entries:write" do |env|
        entries_json = JSON.parse env.body
        entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
        entries_json["resource"].must_equal resource.to_gapi
        entries_json["labels"].must_equal labels
        entries_json["entries"].must_equal [entry_gapi("CRITICAL", "Danger Will Robinson!")]
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      logger.add ::Logger::FATAL, "Danger Will Robinson!"
    end
  end

  describe :unknown do
    it "creates a log entry using :unknown" do
      mock_connection.post "/v2beta1/entries:write" do |env|
        entries_json = JSON.parse env.body
        entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
        entries_json["resource"].must_equal resource.to_gapi
        entries_json["labels"].must_equal labels
        entries_json["entries"].must_equal [entry_gapi("DEFAULT", "Danger Will Robinson!")]
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      logger.add :unknown, "Danger Will Robinson!"
    end

    it "creates a log entry using 'unknown'" do
      mock_connection.post "/v2beta1/entries:write" do |env|
        entries_json = JSON.parse env.body
        entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
        entries_json["resource"].must_equal resource.to_gapi
        entries_json["labels"].must_equal labels
        entries_json["entries"].must_equal [entry_gapi("DEFAULT", "Danger Will Robinson!")]
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      logger.add "unknown", "Danger Will Robinson!"
    end

    it "creates a log entry using Logger::UNKNOWN" do
      mock_connection.post "/v2beta1/entries:write" do |env|
        entries_json = JSON.parse env.body
        entries_json["logName"].must_equal "projects/#{project}/logs/#{log_name}"
        entries_json["resource"].must_equal resource.to_gapi
        entries_json["labels"].must_equal labels
        entries_json["entries"].must_equal [entry_gapi("DEFAULT", "Danger Will Robinson!")]
        [200, {"Content-Type"=>"application/json"}, ""]
      end

      logger.add ::Logger::UNKNOWN, "Danger Will Robinson!"
    end
  end
end
