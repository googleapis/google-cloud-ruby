# Copyright 2014 Google Inc. All rights reserved.
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

gem "minitest"
require "minitest/autorun"
require "ostruct"
require "gcloud/storage"

class TestStorage < Minitest::Spec
  let(:project) { "test" }
  let(:credentials) { OpenStruct.new }
  let(:storage) { Gcloud::Storage::Project.new project, credentials }

  def setup
    @connection = Faraday::Adapter::Test::Stubs.new
    connection = storage.instance_variable_get "@connection"
    client = connection.instance_variable_get "@client"
    client.connection = Faraday.new do |builder|
      # builder.options.params_encoder = Faraday::FlatParamsEncoder
      builder.adapter :test, @connection
    end
  end

  def teardown
    @connection.verify_stubbed_calls
  end

  def mock_connection
    @connection
  end

  # Register this spec type for when :storage is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_storage
  end
end
