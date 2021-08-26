# frozen_string_literal: true

# Copyright 2020 Google LLC
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


require "firestore_helper"

describe Google::Cloud::Firestore::Service, :firestore_acceptance do
  let :config_metadata do
    {
      "google-cloud-resource-prefix": "projects/#{firestore.project_id}/databases/(default)"
    }
  end

  it "passes the correct configuration to its v1 client" do
    _(firestore.project_id).wont_be :empty?
    config = firestore.service.firestore.configure
    _(config).must_be_kind_of Google::Cloud::Firestore::V1::Firestore::Client::Configuration
    _(config.lib_name).must_equal "gccl"
    _(config.lib_version).must_equal Google::Cloud::Firestore::VERSION
    _(config.metadata).must_equal config_metadata
  end
end
