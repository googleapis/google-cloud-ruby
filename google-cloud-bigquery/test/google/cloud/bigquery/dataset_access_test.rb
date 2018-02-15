# Copyright 2015 Google LLC
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

describe Google::Cloud::Bigquery::Dataset, :access, :mock_bigquery do
  # Create a dataset object with the project's mocked connection object
  let(:dataset_id) { "my_dataset" }
  let(:dataset_gapi) { random_dataset_gapi dataset_id }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi,
                                                      bigquery.service }

  it "gets the access rules" do
    dataset.access.must_be :empty?
  end

  it "adds an access entry with specifying user scope" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    updated_gapi = dataset_gapi.dup
    new_access = Google::Apis::BigqueryV2::Dataset::Access.new role: "WRITER", user_by_email: "writer@example.com"
    updated_gapi.access = new_access
    patch_gapi = Google::Apis::BigqueryV2::Dataset.new access: [new_access], etag: dataset_gapi.etag
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi, {options: {header: {"If-Match" => dataset_gapi.etag}}}]

    dataset.access.must_be_kind_of Google::Cloud::Bigquery::Dataset::Access
    dataset.access.must_be :frozen?

    refute dataset.access.writer_user? "writer@example.com"

    dataset.access do |acl|
      acl.must_be_kind_of Google::Cloud::Bigquery::Dataset::Access
      acl.wont_be :frozen?

      refute acl.writer_user? "writer@example.com"
      acl.add_writer_user "writer@example.com"
      assert acl.writer_user? "writer@example.com"
    end

    dataset.access.must_be_kind_of Google::Cloud::Bigquery::Dataset::Access
    dataset.access.must_be :frozen?

    assert dataset.access.writer_user? "writer@example.com"

    mock.verify
  end

  it "adds an access entry with specifying group scope" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    updated_gapi = dataset_gapi.dup
    new_access = Google::Apis::BigqueryV2::Dataset::Access.new role: "WRITER", group_by_email: "writers@example.com"
    updated_gapi.access = new_access
    patch_gapi = Google::Apis::BigqueryV2::Dataset.new access: [new_access], etag: dataset_gapi.etag
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi, {options: {header: {"If-Match" => dataset_gapi.etag}}}]

    dataset.access do |acl|
      refute acl.writer_group? "writers@example.com"
      acl.add_writer_group "writers@example.com"
      assert acl.writer_group? "writers@example.com"
    end
    mock.verify
  end

  it "adds an access entry with specifying domain scope" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    updated_gapi = dataset_gapi.dup
    new_access = Google::Apis::BigqueryV2::Dataset::Access.new role: "OWNER", domain: "example.com"
    updated_gapi.access = new_access
    patch_gapi = Google::Apis::BigqueryV2::Dataset.new access: [new_access], etag: dataset_gapi.etag
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi, {options: {header: {"If-Match" => dataset_gapi.etag}}}]

    dataset.access do |acl|
      refute acl.owner_domain? "example.com"
      acl.add_owner_domain "example.com"
      assert acl.owner_domain? "example.com"
    end
    mock.verify
  end

  it "adds an access entry with specifying special scope" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    updated_gapi = dataset_gapi.dup
    new_access = Google::Apis::BigqueryV2::Dataset::Access.new role: "READER", special_group: "allAuthenticatedUsers"
    updated_gapi.access = new_access
    patch_gapi = Google::Apis::BigqueryV2::Dataset.new access: [new_access], etag: dataset_gapi.etag
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi, {options: {header: {"If-Match" => dataset_gapi.etag}}}]

    dataset.access do |acl|
      refute acl.reader_special? :all
      acl.add_reader_special :all
      assert acl.reader_special? :all
    end
    mock.verify
  end

  describe :view do
    let(:view_id) { "new-view" }
    let(:view_gapi) { random_view_gapi dataset_id, view_id }
    let(:view) { Google::Cloud::Bigquery::Table.from_gapi view_gapi,
                                                  bigquery.service }

    it "adds an access entry with specifying a view object" do
      mock = Minitest::Mock.new
      bigquery.service.mocked_service = mock
      updated_gapi = dataset_gapi.dup
      new_access = Google::Apis::BigqueryV2::Dataset::Access.new view: view_gapi.table_reference
      updated_gapi.access = new_access
      patch_gapi = Google::Apis::BigqueryV2::Dataset.new access: [new_access], etag: dataset_gapi.etag
      mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi, {options: {header: {"If-Match" => dataset_gapi.etag}}}]

      dataset.access do |acl|
        acl.add_reader_view view
      end
      mock.verify
    end

    it "adds an access entry with specifying a view string" do
      mock = Minitest::Mock.new
      bigquery.service.mocked_service = mock
      updated_gapi = dataset_gapi.dup
      view_reference = Google::Apis::BigqueryV2::TableReference.new project_id: "test-project_id",
                                                                     dataset_id: "test-dataset_id",
                                                                     table_id: "test-view_id"
      new_access = Google::Apis::BigqueryV2::Dataset::Access.new view: view_reference
      updated_gapi.access = new_access
      patch_gapi = Google::Apis::BigqueryV2::Dataset.new access: [new_access], etag: dataset_gapi.etag
      mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi, {options: {header: {"If-Match" => dataset_gapi.etag}}}]

      dataset.access do |acl|
        acl.add_reader_view "test-project_id:test-dataset_id.test-view_id"
      end
      mock.verify
    end
  end

  it "updates multiple access entries in the block" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    updated_gapi = dataset_gapi.dup
    new_access = Google::Apis::BigqueryV2::Dataset::Access.new role: "WRITER", user_by_email: "writer@example.com"
    new_access_2 = Google::Apis::BigqueryV2::Dataset::Access.new role: "READER", group_by_email: "readers@example.com"
    updated_gapi.access = new_access
    patch_gapi = Google::Apis::BigqueryV2::Dataset.new access: [new_access, new_access_2], etag: dataset_gapi.etag
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi, {options: {header: {"If-Match" => dataset_gapi.etag}}}]

    dataset.access do |acl|
      refute acl.writer_user? "writer@example.com"
      refute acl.reader_group? "readers@example.com"
      acl.add_writer_user "writer@example.com"
      acl.add_reader_group "readers@example.com"
      assert acl.writer_user? "writer@example.com"
      assert acl.reader_group? "readers@example.com"
    end
    mock.verify
  end

  it "does not make an API call when no updates are made" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    dataset.access do |acl|
      # No changes, no API calls made
    end
    mock.verify
  end

  describe :remove do
    let(:dataset_gapi) do
      gapi = random_dataset_gapi dataset_id
      gapi.access = [
        Google::Apis::BigqueryV2::Dataset::Access.new(role: "WRITER", user_by_email: "writer@example.com"),
        Google::Apis::BigqueryV2::Dataset::Access.new(role: "READER", user_by_email: "reader@example.com")
      ]
      gapi
    end

    it "removes an access entry" do
      mock = Minitest::Mock.new
      bigquery.service.mocked_service = mock
      updated_gapi = dataset_gapi.dup
      new_access = Google::Apis::BigqueryV2::Dataset::Access.new role: "WRITER", user_by_email: "writer@example.com"
      updated_gapi.access = new_access
      patch_gapi = Google::Apis::BigqueryV2::Dataset.new access: [new_access], etag: dataset_gapi.etag
      mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi, {options: {header: {"If-Match" => dataset_gapi.etag}}}]

      dataset.access do |acl|
        assert acl.writer_user? "writer@example.com"
        assert acl.reader_user? "reader@example.com"
        acl.remove_reader_user "reader@example.com"
        assert acl.writer_user? "writer@example.com"
        refute acl.reader_user? "reader@example.com"
      end
      mock.verify
    end
  end
end
