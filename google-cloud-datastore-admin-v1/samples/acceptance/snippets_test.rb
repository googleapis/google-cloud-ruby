# Copyright 2020 Google LLC
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

require_relative "helper"
require_relative "../snippets"

describe "Firestore in Datastore mode Admin V1 samples" do
  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT") }
  let(:storage_file_prefix) { random_storage_file_prefix }
  let(:output_url_prefix) { storage_url prefix: storage_file_prefix }

  it "client_create" do
    client = client_create
    assert_kind_of Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Client, client
  end

  it "index_list, index_get" do
    indexes = nil
    out, _err = capture_io do
      indexes = index_list project_id: project_id
    end
    assert indexes
    refute_empty indexes
    index = indexes.first
    assert_kind_of Google::Cloud::Datastore::Admin::V1::Index, index
    assert_includes out, "Got index: #{index.index_id}"
    assert_includes out, "Got list of indexes"

    out, _err = capture_io do
      index = index_get project_id: project_id, index_id: index.index_id
    end
    assert_kind_of Google::Cloud::Datastore::Admin::V1::Index, index
    assert_includes out, "Got index: #{index.index_id}"
  end

  it "entities_export, entities_import" do
    begin
      op = nil
      out, _err = capture_io do
        op = entities_export project_id: project_id, output_url_prefix: output_url_prefix
      end
      assert_includes out, "Entities were exported"
      assert op
      assert op.response
      assert_equal "#{output_url_prefix}/#{storage_file_prefix}.overall_export_metadata", op.response.output_url

      out, _err = capture_io do
        entities_import project_id: project_id, input_url: op.response.output_url
      end
      assert_includes out, "Entities were imported"
    ensure
      # cleanup: delete exported objects
      require "google/cloud/storage"
      storage = Google::Cloud::Storage.new
      files = storage.bucket(storage_bucket_name).files prefix: storage_file_prefix
      files.each do |f|
        f.delete
        puts "Deleted: #{f.name}"
      end
    end
  end
end
