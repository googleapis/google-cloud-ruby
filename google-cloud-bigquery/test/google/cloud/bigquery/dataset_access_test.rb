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
require "google/cloud/bigquery/condition"

describe Google::Cloud::Bigquery::Dataset, :access, :mock_bigquery do
  # Create a dataset object with the project's mocked connection object
  let(:dataset_id) { "my_dataset" }
  let(:dataset_gapi) { random_dataset_gapi dataset_id }
  let(:dataset) do
    Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi,
                                               bigquery.service
  end

  let(:condition) do
    Google::Cloud::Bigquery::Condition.new(
      "true",
      description: "example description",
      location: "path/to/example/location",
      title: "example title"
    )
  end

  it "gets the access rules" do
    _(dataset.access).must_be :empty?
  end

  it "adds an access entry with specifying user scope" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    updated_gapi = dataset_gapi.dup
    new_access = Google::Apis::BigqueryV2::Dataset::Access.new role: "WRITER", user_by_email: "writer@example.com"
    updated_gapi.access = new_access
    patch_gapi = Google::Apis::BigqueryV2::Dataset.new access: [new_access], etag: dataset_gapi.etag
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi], options: {header: {"If-Match" => dataset_gapi.etag}}, access_policy_version: nil

    _(dataset.access).must_be_kind_of Google::Cloud::Bigquery::Dataset::Access
    _(dataset.access).must_be :frozen?

    refute dataset.access.writer_user? "writer@example.com"

    dataset.access do |acl|
      _(acl).must_be_kind_of Google::Cloud::Bigquery::Dataset::Access
      _(acl).wont_be :frozen?

      # reader
      refute acl.reader_user? "reader@example.com"
      acl.add_reader_user "reader@example.com"
      assert acl.reader_user? "reader@example.com"
      acl.remove_reader_user "reader@example.com"
      refute acl.reader_user? "reader@example.com"

      # writer
      refute acl.writer_user? "writer@example.com"
      acl.add_writer_user "writer@example.com"
      assert acl.writer_user? "writer@example.com"
      acl.remove_writer_user "writer@example.com"
      refute acl.writer_user? "writer@example.com"
      acl.add_writer_user "writer@example.com" # this entry goes into the request

      # owner
      refute acl.owner_user? "owner@example.com"
      acl.add_owner_user "owner@example.com"
      assert acl.owner_user? "owner@example.com"
      acl.remove_owner_user "owner@example.com"
      refute acl.owner_user? "owner@example.com"
    end

    _(dataset.access).must_be_kind_of Google::Cloud::Bigquery::Dataset::Access
    _(dataset.access).must_be :frozen?

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
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi], options: {header: {"If-Match" => dataset_gapi.etag}}, access_policy_version: nil

    dataset.access do |acl|
      # reader
      refute acl.reader_group? "readers@example.com"
      acl.add_reader_group "readers@example.com"
      assert acl.reader_group? "readers@example.com"
      acl.remove_reader_group "readers@example.com"
      refute acl.reader_group? "readers@example.com"

      # writer
      refute acl.writer_group? "writers@example.com"
      acl.add_writer_group "writers@example.com"
      assert acl.writer_group? "writers@example.com"
      acl.remove_writer_group "writers@example.com"
      refute acl.writer_group? "writers@example.com"
      acl.add_writer_group "writers@example.com" # this entry goes into the request

      # owner
      refute acl.owner_group? "owners@example.com"
      acl.add_owner_group "owners@example.com"
      assert acl.owner_group? "owners@example.com"
      acl.remove_owner_group "owners@example.com"
      refute acl.owner_group? "owners@example.com"
    end
    mock.verify
  end

  it "adds an access entry with specifying iam_member scope" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    updated_gapi = dataset_gapi.dup
    new_access = Google::Apis::BigqueryV2::Dataset::Access.new role: "WRITER", iam_member: "writers@example.com"
    updated_gapi.access = new_access
    patch_gapi = Google::Apis::BigqueryV2::Dataset.new access: [new_access], etag: dataset_gapi.etag
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi], options: {header: {"If-Match" => dataset_gapi.etag}}, access_policy_version: nil

    dataset.access do |acl|
      # reader
      refute acl.reader_iam_member? "readers@example.com"
      acl.add_reader_iam_member "readers@example.com"
      assert acl.reader_iam_member? "readers@example.com"
      acl.remove_reader_iam_member "readers@example.com"
      refute acl.reader_iam_member? "readers@example.com"

      # writer
      refute acl.writer_iam_member? "writers@example.com"
      acl.add_writer_iam_member "writers@example.com"
      assert acl.writer_iam_member? "writers@example.com"
      acl.remove_writer_iam_member "writers@example.com"
      refute acl.writer_iam_member? "writers@example.com"
      acl.add_writer_iam_member "writers@example.com" # this entry goes into the request

      # owner
      refute acl.owner_iam_member? "owners@example.com"
      acl.add_owner_iam_member "owners@example.com"
      assert acl.owner_iam_member? "owners@example.com"
      acl.remove_owner_iam_member "owners@example.com"
      refute acl.owner_iam_member? "owners@example.com"
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
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi], options: {header: {"If-Match" => dataset_gapi.etag}}, access_policy_version: nil

    dataset.access do |acl|
      # reader
      refute acl.reader_domain? "example.com"
      acl.add_reader_domain "example.com"
      assert acl.reader_domain? "example.com"
      acl.remove_reader_domain "example.com"
      refute acl.reader_domain? "example.com"

      # writer
      refute acl.writer_domain? "example.com"
      acl.add_writer_domain "example.com"
      assert acl.writer_domain? "example.com"
      acl.remove_writer_domain "example.com"
      refute acl.writer_domain? "example.com"

      # owner
      refute acl.owner_domain? "example.com"
      acl.add_owner_domain "example.com"
      assert acl.owner_domain? "example.com"
      acl.remove_owner_domain "example.com"
      refute acl.owner_domain? "example.com"
      acl.add_owner_domain "example.com" # this entry goes into the request
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
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi], options: {header: {"If-Match" => dataset_gapi.etag}}, access_policy_version: nil

    dataset.access do |acl|
      # writer
      refute acl.writer_special? :all
      acl.add_writer_special :all
      assert acl.writer_special? :all
      acl.remove_writer_special :all
      refute acl.writer_special? :all

      # owner
      refute acl.owner_special? :all
      acl.add_owner_special :all
      assert acl.owner_special? :all
      acl.remove_owner_special :all
      refute acl.owner_special? :all

      # reader
      refute acl.reader_special? :all
      acl.add_reader_special :all
      assert acl.reader_special? :all
      acl.remove_reader_special :all
      refute acl.reader_special? :all
      acl.add_reader_special :all # this entry goes into the request
    end
    mock.verify
  end

  it "adds an access entry with specifying user scope and condition" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    updated_gapi = dataset_gapi.dup
    new_access = Google::Apis::BigqueryV2::Dataset::Access.new role: "WRITER", user_by_email: "writer@example.com",
                                                               condition: condition.to_gapi
    updated_gapi.access = new_access
    patch_gapi = Google::Apis::BigqueryV2::Dataset.new access: [new_access], etag: dataset_gapi.etag
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi],
                options: { header: { "If-Match" => dataset_gapi.etag } }, access_policy_version: nil

    _(dataset.access).must_be_kind_of Google::Cloud::Bigquery::Dataset::Access
    _(dataset.access).must_be :frozen?

    refute dataset.access.writer_user? "writer@example.com"

    dataset.access do |acl|
      _(acl).must_be_kind_of Google::Cloud::Bigquery::Dataset::Access
      _(acl).wont_be :frozen?

      # reader
      refute acl.reader_user? "reader@example.com"
      acl.add_reader_user "reader@example.com", condition: condition
      assert acl.reader_user? "reader@example.com"

      assert(acl.rules.find do |rule|
        rule.to_h[:user_by_email] == "reader@example.com" && rule.to_h[:condition] == condition.to_gapi.to_h && rule.to_h[:role] == "READER"
      end)

      acl.remove_reader_user "reader@example.com"
      refute acl.reader_user? "reader@example.com"

      # writer
      refute acl.writer_user? "writer@example.com"
      acl.add_writer_user "writer@example.com", condition: condition
      assert acl.writer_user? "writer@example.com"
      assert(acl.rules.find do |rule|
        rule.to_h[:user_by_email] == "writer@example.com" && rule.to_h[:condition] == condition.to_gapi.to_h && rule.to_h[:role] == "WRITER"
      end)
      acl.remove_writer_user "writer@example.com"
      refute acl.writer_user? "writer@example.com"
      acl.add_writer_user "writer@example.com", condition: condition # this entry goes into the request

      # owner
      refute acl.owner_user? "owner@example.com"
      acl.add_owner_user "owner@example.com", condition: condition
      assert acl.owner_user? "owner@example.com"
      assert(acl.rules.find do |rule|
        rule.to_h[:user_by_email] == "owner@example.com" && rule.to_h[:condition] == condition.to_gapi.to_h && rule.to_h[:role] == "OWNER"
      end)
      acl.remove_owner_user "owner@example.com"
      refute acl.owner_user? "owner@example.com"
    end

    _(dataset.access).must_be_kind_of Google::Cloud::Bigquery::Dataset::Access
    _(dataset.access).must_be :frozen?

    assert dataset.access.writer_user? "writer@example.com"

    mock.verify
  end

  it "adds an access entry with specifying group scope and condition" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    updated_gapi = dataset_gapi.dup
    new_access = Google::Apis::BigqueryV2::Dataset::Access.new role: "WRITER",
                                                                group_by_email: "writers@example.com", condition: condition.to_gapi
    updated_gapi.access = new_access
    patch_gapi = Google::Apis::BigqueryV2::Dataset.new access: [new_access], etag: dataset_gapi.etag
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi],
                options: { header: { "If-Match" => dataset_gapi.etag } }, access_policy_version: nil

    dataset.access do |acl|
      # reader
      refute acl.reader_group? "readers@example.com"
      acl.add_reader_group "readers@example.com", condition: condition
      assert acl.reader_group? "readers@example.com"
      assert(acl.rules.find do |rule|
        rule.to_h[:group_by_email] == "readers@example.com" && rule.to_h[:condition] == condition.to_gapi.to_h && rule.to_h[:role] == "READER"
      end)
      acl.remove_reader_group "readers@example.com"
      refute acl.reader_group? "readers@example.com"

      # writer
      refute acl.writer_group? "writers@example.com"
      acl.add_writer_group "writers@example.com", condition: condition
      assert acl.writer_group? "writers@example.com"
      assert(acl.rules.find do |rule|
        rule.to_h[:group_by_email] == "writers@example.com" && rule.to_h[:condition] == condition.to_gapi.to_h && rule.to_h[:role] == "WRITER"
      end)
      acl.remove_writer_group "writers@example.com"
      refute acl.writer_group? "writers@example.com"
      acl.add_writer_group "writers@example.com", condition: condition # this entry goes into the request

      # owner
      refute acl.owner_group? "owners@example.com"
      acl.add_owner_group "owners@example.com", condition: condition
      assert acl.owner_group? "owners@example.com"
      assert(acl.rules.find do |rule|
        rule.to_h[:group_by_email] == "owners@example.com" && rule.to_h[:condition] == condition.to_gapi.to_h && rule.to_h[:role] == "OWNER"
      end)
      acl.remove_owner_group "owners@example.com"
      refute acl.owner_group? "owners@example.com"
    end
    mock.verify
  end

  it "adds an access entry with specifying iam_member scope and condition" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    updated_gapi = dataset_gapi.dup
    new_access = Google::Apis::BigqueryV2::Dataset::Access.new role: "WRITER", iam_member: "writers@example.com",
                                                                condition: condition.to_gapi
    updated_gapi.access = new_access
    patch_gapi = Google::Apis::BigqueryV2::Dataset.new access: [new_access], etag: dataset_gapi.etag
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi],
                options: { header: { "If-Match" => dataset_gapi.etag } }, access_policy_version: nil

    dataset.access do |acl|
      # reader
      refute acl.reader_iam_member? "readers@example.com"
      acl.add_reader_iam_member "readers@example.com", condition: condition
      assert acl.reader_iam_member? "readers@example.com"
      assert(acl.rules.find do |rule|
        rule.to_h[:iam_member] == "readers@example.com" && rule.to_h[:condition] == condition.to_gapi.to_h && rule.to_h[:role] == "READER"
      end)
      acl.remove_reader_iam_member "readers@example.com"
      refute acl.reader_iam_member? "readers@example.com"

      # writer
      refute acl.writer_iam_member? "writers@example.com"
      acl.add_writer_iam_member "writers@example.com", condition: condition
      assert acl.writer_iam_member? "writers@example.com"
      assert(acl.rules.find do |rule|
        rule.to_h[:iam_member] == "writers@example.com" && rule.to_h[:condition] == condition.to_gapi.to_h && rule.to_h[:role] == "WRITER"
      end)
      acl.remove_writer_iam_member "writers@example.com"
      refute acl.writer_iam_member? "writers@example.com"
      acl.add_writer_iam_member "writers@example.com", condition: condition # this entry goes into the request

      # owner
      refute acl.owner_iam_member? "owners@example.com"
      acl.add_owner_iam_member "owners@example.com", condition: condition
      assert acl.owner_iam_member? "owners@example.com"
      assert(acl.rules.find do |rule|
        rule.to_h[:iam_member] == "owners@example.com" && rule.to_h[:condition] == condition.to_gapi.to_h && rule.to_h[:role] == "OWNER"
      end)
      acl.remove_owner_iam_member "owners@example.com"
      refute acl.owner_iam_member? "owners@example.com"
    end
    mock.verify
  end

  it "adds an access entry with specifying domain scope and condition" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    updated_gapi = dataset_gapi.dup
    new_access = Google::Apis::BigqueryV2::Dataset::Access.new role: "OWNER", domain: "example.com",
                                                                condition: condition.to_gapi
    updated_gapi.access = new_access
    patch_gapi = Google::Apis::BigqueryV2::Dataset.new access: [new_access], etag: dataset_gapi.etag
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi],
                options: { header: { "If-Match" => dataset_gapi.etag } }, access_policy_version: nil

    dataset.access do |acl|
      # reader
      refute acl.reader_domain? "example.com"
      acl.add_reader_domain "example.com", condition: condition
      assert acl.reader_domain? "example.com"
      assert(acl.rules.find do |rule|
rule.to_h[:domain] == "example.com" && rule.to_h[:condition] == condition.to_gapi.to_h && rule.to_h[:role] == "READER"
      end)
      acl.remove_reader_domain "example.com"
      refute acl.reader_domain? "example.com"

      # writer
      refute acl.writer_domain? "example.com"
      acl.add_writer_domain "example.com", condition: condition
      assert acl.writer_domain? "example.com"
      assert(acl.rules.find do |rule|
rule.to_h[:domain] == "example.com" && rule.to_h[:condition] == condition.to_gapi.to_h && rule.to_h[:role] == "WRITER"
      end)
      acl.remove_writer_domain "example.com"
      refute acl.writer_domain? "example.com"

      # owner
      refute acl.owner_domain? "example.com"
      acl.add_owner_domain "example.com", condition: condition
      assert acl.owner_domain? "example.com"
      assert(acl.rules.find do |rule|
rule.to_h[:domain] == "example.com" && rule.to_h[:condition] == condition.to_gapi.to_h && rule.to_h[:role] == "OWNER"
      end)
      acl.remove_owner_domain "example.com"
      refute acl.owner_domain? "example.com"
      acl.add_owner_domain "example.com", condition: condition # this entry goes into the request
    end
    mock.verify
  end

  describe :routine do
    let(:routine_id) { "new-routine" }
    let(:routine_gapi) { random_routine_gapi dataset_id, routine_id }
    let(:routine) { Google::Cloud::Bigquery::Routine.from_gapi routine_gapi, bigquery.service }

    it "adds an access entry with specifying a routine object" do
      mock = Minitest::Mock.new
      bigquery.service.mocked_service = mock
      updated_gapi = dataset_gapi.dup
      new_access = Google::Apis::BigqueryV2::Dataset::Access.new routine: routine_gapi.routine_reference
      updated_gapi.access = new_access
      patch_gapi = Google::Apis::BigqueryV2::Dataset.new access: [new_access], etag: dataset_gapi.etag
      mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi], options: {header: {"If-Match" => dataset_gapi.etag}}, access_policy_version: nil

      dataset.access do |acl|
        refute acl.reader_routine? routine
        acl.add_reader_routine routine
        assert acl.reader_routine? routine
        acl.remove_reader_routine routine
        refute acl.reader_routine? routine
        acl.add_reader_routine routine # this entry goes into the request
      end
      mock.verify
    end
  end

  describe :view do
    let(:view_id) { "new-view" }
    let(:view_gapi) { random_view_gapi dataset_id, view_id }
    let(:view) { Google::Cloud::Bigquery::Table.from_gapi view_gapi, bigquery.service }

    it "adds an access entry with specifying a view object" do
      mock = Minitest::Mock.new
      bigquery.service.mocked_service = mock
      updated_gapi = dataset_gapi.dup
      new_access = Google::Apis::BigqueryV2::Dataset::Access.new view: view_gapi.table_reference
      updated_gapi.access = new_access
      patch_gapi = Google::Apis::BigqueryV2::Dataset.new access: [new_access], etag: dataset_gapi.etag
      mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi], options: {header: {"If-Match" => dataset_gapi.etag}}, access_policy_version: nil

      dataset.access do |acl|
        refute acl.reader_view? view
        acl.add_reader_view view
        assert acl.reader_view? view
        acl.remove_reader_view view
        refute acl.reader_view? view
        acl.add_reader_view view # this entry goes into the request
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
      mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi], options: {header: {"If-Match" => dataset_gapi.etag}}, access_policy_version: nil

      dataset.access do |acl|
        acl.add_reader_view "test-project_id:test-dataset_id.test-view_id"
      end
      mock.verify
    end
  end

  describe :dataset do
    let(:new_dataset_id) { "new-dataset" }
    let(:new_dataset_gapi) { random_dataset_gapi new_dataset_id }
    let(:dataset_1) { Google::Cloud::Bigquery::Dataset.from_gapi new_dataset_gapi,
                                                                 bigquery.service }
    let(:target_types) { ["VIEWS"] }


    it "adds an access entry with specifying a dataset object" do
      mock = Minitest::Mock.new
      bigquery.service.mocked_service = mock
      updated_gapi = dataset_gapi.dup
      new_access = Google::Apis::BigqueryV2::Dataset::Access.new dataset: dataset_1.build_access_entry(target_types: ["VIEWS"])
      updated_gapi.access = new_access
      patch_gapi = Google::Apis::BigqueryV2::Dataset.new access: [new_access], etag: dataset_gapi.etag
      mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi], options: {header: {"If-Match" => dataset_gapi.etag}}, access_policy_version: nil

      dataset.access do |acl|
        refute acl.reader_dataset? dataset_1.build_access_entry(target_types: target_types)
        acl.add_reader_dataset dataset_1.build_access_entry(target_types: target_types)
        assert acl.reader_dataset? dataset_1.build_access_entry(target_types: target_types)
        acl.remove_reader_dataset dataset_1.build_access_entry(target_types: target_types)
        refute acl.reader_dataset? dataset_1.build_access_entry(target_types: target_types)
        acl.add_reader_dataset dataset_1.build_access_entry(target_types: target_types) # this entry goes into the request
      end
      mock.verify
    end

    it "adds an access entry with specifying a dataset hash" do
      mock = Minitest::Mock.new
      bigquery.service.mocked_service = mock
      updated_gapi = dataset_gapi.dup
      new_access = Google::Apis::BigqueryV2::Dataset::Access.new dataset: dataset_1.build_access_entry(target_types: target_types)
      updated_gapi.access = new_access
      patch_gapi = Google::Apis::BigqueryV2::Dataset.new access: [new_access], etag: dataset_gapi.etag
      mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi], options: {header: {"If-Match" => dataset_gapi.etag}}, access_policy_version: nil

      params = {
        project_id: dataset_1.project_id,
        dataset_id: dataset_1.dataset_id,
        target_types: target_types
      }

      dataset.access do |acl|
        refute acl.reader_dataset? params
        acl.add_reader_dataset params
        assert acl.reader_dataset? params
        acl.remove_reader_dataset params
        refute acl.reader_dataset? params
        acl.add_reader_dataset params # this entry goes into the request
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
      mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi], options: {header: {"If-Match" => dataset_gapi.etag}}, access_policy_version: nil

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
    mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi], options: {header: {"If-Match" => dataset_gapi.etag}}, access_policy_version: nil

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
      mock.expect :patch_dataset, updated_gapi, [project, dataset_id, patch_gapi], options: {header: {"If-Match" => dataset_gapi.etag}}, access_policy_version: nil

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
