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
require "json"

describe Google::Cloud::Bigquery::Project, :mock_bigquery do
  let(:email) { "my_service_account@bigquery-encryption.iam.gserviceaccount.com" }
  let(:service_account_resp) { OpenStruct.new email: email }
  let(:dataset_id) { "my_dataset" }
  let(:filter) { "labels.foo:bar" }
  let(:default_credentials) do
    creds = OpenStruct.new empty: true
    def creds.is_a? target
      target == Google::Auth::Credentials
    end
    creds
  end

  it "gets the universe domain" do
    service = Google::Cloud::Bigquery::Service.new "my-project", default_credentials
    project = Google::Cloud::Bigquery::Project.new service
    _(project.universe_domain).must_equal "googleapis.com"
  end

  it "gets and memoizes its service_account_email" do
    mock = Minitest::Mock.new
    mock.expect :get_project_service_account, service_account_resp, [project]
    bigquery.service.mocked_service = mock

    _(bigquery.service_account_email).must_equal email
    _(bigquery.service_account_email).must_equal email # memoized, no request

    mock.verify
  end

  it "creates an empty dataset" do
    mock = Minitest::Mock.new
    created_dataset = create_dataset_gapi dataset_id
    inserted_dataset = Google::Apis::BigqueryV2::Dataset.new(
      dataset_reference: Google::Apis::BigqueryV2::DatasetReference.new(
        project_id: project, dataset_id: dataset_id)
    )
    mock.expect :insert_dataset, created_dataset, [project, inserted_dataset]
    bigquery.service.mocked_service = mock

    dataset = bigquery.create_dataset dataset_id

    mock.verify

    _(dataset).must_be_kind_of Google::Cloud::Bigquery::Dataset
  end

  it "creates a dataset with options" do
    name = "My Dataset"
    description = "This is my dataset"
    default_expiration = 999
    location = "EU"

    mock = Minitest::Mock.new
    created_dataset = create_dataset_gapi dataset_id, name, description, default_expiration, location
    inserted_dataset = Google::Apis::BigqueryV2::Dataset.new(
      dataset_reference: Google::Apis::BigqueryV2::DatasetReference.new(
        project_id: project, dataset_id: dataset_id),
      friendly_name: name,
      description: description,
      default_table_expiration_ms: default_expiration,
      location: location)
    mock.expect :insert_dataset, created_dataset, [project, inserted_dataset]
    bigquery.service.mocked_service = mock

    dataset = bigquery.create_dataset dataset_id, name: name,
                                      description: description,
                                      expiration: default_expiration,
                                      location: location

    mock.verify

    _(dataset).must_be_kind_of Google::Cloud::Bigquery::Dataset
    _(dataset.name).must_equal name
    _(dataset.description).must_equal description
    _(dataset.default_expiration).must_equal default_expiration
    _(dataset.location).must_equal location
  end

  it "creates a dataset and access rules using a block" do
    mock = Minitest::Mock.new
    filled_access = [Google::Apis::BigqueryV2::Dataset::Access.new(
      role: "WRITER", user_by_email: "writers@example.com")]
    created_dataset = create_dataset_gapi dataset_id
    created_dataset.access = filled_access
    inserted_dataset = Google::Apis::BigqueryV2::Dataset.new(
      dataset_reference: Google::Apis::BigqueryV2::DatasetReference.new(
        project_id: project, dataset_id: dataset_id),
      access: filled_access)
    mock.expect :insert_dataset, created_dataset, [project, inserted_dataset]
    bigquery.service.mocked_service = mock

    dataset = bigquery.create_dataset dataset_id do |ds|
      ds.access do |acl|
        refute acl.writer_user? "writers@example.com"
        acl.add_writer_user "writers@example.com"
        assert acl.writer_user? "writers@example.com"
      end
    end

    mock.verify

    _(dataset).must_be_kind_of Google::Cloud::Bigquery::Dataset
    _(dataset.access).wont_be :empty?
  end

  it "creates a dataset with options and access rules using a block" do
    name = "My Dataset"
    description = "This is my dataset"
    default_expiration = 999
    location = "EU"
    labels = { "foo" => "bar" }

    mock = Minitest::Mock.new
    filled_access = [Google::Apis::BigqueryV2::Dataset::Access.new(
      role: "WRITER", user_by_email: "writers@example.com")]
    created_dataset = create_dataset_gapi dataset_id, name, description, default_expiration, location
    created_dataset.access = filled_access
    inserted_dataset = Google::Apis::BigqueryV2::Dataset.new(
      dataset_reference: Google::Apis::BigqueryV2::DatasetReference.new(
        project_id: project, dataset_id: dataset_id),
      friendly_name: name,
      description: description,
      default_table_expiration_ms: default_expiration,
      labels: labels,
      location: location,
      access: filled_access)
    mock.expect :insert_dataset, created_dataset, [project, inserted_dataset]
    bigquery.service.mocked_service = mock

    dataset = bigquery.create_dataset dataset_id, location: location do |ds|
      ds.name = name
      ds.description = description
      ds.default_expiration = default_expiration
      ds.labels = labels
      ds.access do |acl|
        refute acl.writer_user? "writers@example.com"
        acl.add_writer_user "writers@example.com"
        assert acl.writer_user? "writers@example.com"
      end
      expect { ds.delete }.must_raise RuntimeError
      expect { ds.create_table }.must_raise RuntimeError
      expect { ds.create_view }.must_raise RuntimeError
      expect { ds.create_materialized_view }.must_raise RuntimeError
      expect { ds.table }.must_raise RuntimeError
      expect { ds.tables }.must_raise RuntimeError
      expect { ds.model }.must_raise RuntimeError
      expect { ds.models }.must_raise RuntimeError
      expect { ds.create_routine }.must_raise RuntimeError
      expect { ds.routine }.must_raise RuntimeError
      expect { ds.routines }.must_raise RuntimeError
      expect { ds.query_job }.must_raise RuntimeError
      expect { ds.query }.must_raise RuntimeError
      expect { ds.external }.must_raise RuntimeError
      expect { ds.load_job }.must_raise RuntimeError
      expect { ds.load }.must_raise RuntimeError
      expect { ds.reload! }.must_raise RuntimeError
      expect { ds.refresh! }.must_raise RuntimeError
    end

    mock.verify

    _(dataset).must_be_kind_of Google::Cloud::Bigquery::Dataset
    _(dataset.name).must_equal name
    _(dataset.description).must_equal description
    _(dataset.default_expiration).must_equal default_expiration
    _(dataset.labels).must_equal labels
    _(dataset.location).must_equal location
    _(dataset.access).wont_be :empty?
  end

  it "creates a dataset with block options and access rules not using a block" do
    name = "My Dataset"
    description = "This is my dataset"
    default_expiration = 999
    location = "EU"

    mock = Minitest::Mock.new
    filled_access = [Google::Apis::BigqueryV2::Dataset::Access.new(
      role: "WRITER", user_by_email: "writers@example.com")]
    created_dataset = create_dataset_gapi dataset_id, name, description, default_expiration, location
    created_dataset.access = filled_access
    inserted_dataset = Google::Apis::BigqueryV2::Dataset.new(
      dataset_reference: Google::Apis::BigqueryV2::DatasetReference.new(
        project_id: project, dataset_id: dataset_id),
      friendly_name: name,
      description: description,
      default_table_expiration_ms: default_expiration,
      location: location,
      access: filled_access)
    mock.expect :insert_dataset, created_dataset, [project, inserted_dataset]
    bigquery.service.mocked_service = mock

    dataset = bigquery.create_dataset dataset_id, location: location do |ds|
      ds.name = name
      ds.description = description
      ds.default_expiration = default_expiration
      ds.access.add_writer_user "writers@example.com"
    end

    mock.verify

    _(dataset).must_be_kind_of Google::Cloud::Bigquery::Dataset
    _(dataset.name).must_equal name
    _(dataset.description).must_equal description
    _(dataset.default_expiration).must_equal default_expiration
    _(dataset.location).must_equal location
    _(dataset.access).wont_be :empty?
  end

  it "raises when creating a dataset with a blank id" do
    stub = Object.new
    def stub.insert_dataset *args
      raise Google::Apis::ClientError.new("invalid", status_code: 409)
    end
    bigquery.service.mocked_service = stub

    # it would be really great if the error handling would differentiate
    # between AlreadyExistsError and InvalidArgumentError
    expect { bigquery.create_dataset "" }.must_raise Google::Cloud::AlreadyExistsError
  end

  it "lists datasets" do
    mock = Minitest::Mock.new
    mock.expect :list_datasets, list_datasets_gapi(3),
      [project], all: nil, filter: nil, max_results: nil, page_token: nil
    bigquery.service.mocked_service = mock

    datasets = bigquery.datasets

    mock.verify

    _(datasets.size).must_equal 3
    datasets.each do |ds|
      _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset
      _(ds).wont_be :reference?
      _(ds).must_be :resource?
      _(ds).must_be :resource_partial?
      _(ds).wont_be :resource_full?
    end
  end

  it "paginates datasets with all set" do
    mock = Minitest::Mock.new
    mock.expect :list_datasets, list_datasets_gapi(3, "next_page_token"),
      [project], all: true, filter: nil, max_results: nil, page_token: nil
    bigquery.service.mocked_service = mock

    datasets = bigquery.datasets all: true

    mock.verify

    _(datasets.count).must_equal 3
    datasets.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset }
    _(datasets.token).wont_be :nil?
    _(datasets.token).must_equal "next_page_token"
  end

  it "paginates datasets with filter set" do
    mock = Minitest::Mock.new
    mock.expect :list_datasets, list_datasets_gapi(3, "next_page_token"),
      [project], all: nil, filter: filter, max_results: nil, page_token: nil
    bigquery.service.mocked_service = mock

    datasets = bigquery.datasets filter: filter

    mock.verify

    _(datasets.count).must_equal 3
    datasets.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset }
    _(datasets.token).wont_be :nil?
    _(datasets.token).must_equal "next_page_token"
  end

  it "paginates datasets with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_datasets, list_datasets_gapi(3, "next_page_token"),
      [project], all: nil, filter: nil, max_results: 3, page_token: nil
    bigquery.service.mocked_service = mock

    datasets = bigquery.datasets max: 3

    mock.verify

    _(datasets.count).must_equal 3
    datasets.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset }
    _(datasets.token).wont_be :nil?
    _(datasets.token).must_equal "next_page_token"
  end

  it "paginates datasets" do
    mock = Minitest::Mock.new
    mock.expect :list_datasets, list_datasets_gapi(3, "next_page_token"),
      [project], all: nil, filter: nil, max_results: nil, page_token: nil
    mock.expect :list_datasets, list_datasets_gapi(2),
      [project], all: nil, filter: nil, max_results: nil, page_token: "next_page_token"
    bigquery.service.mocked_service = mock

    first_datasets = bigquery.datasets
    second_datasets = bigquery.datasets token: first_datasets.token

    mock.verify

    _(first_datasets.count).must_equal 3
    first_datasets.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset }
    _(first_datasets.token).wont_be :nil?
    _(first_datasets.token).must_equal "next_page_token"

    _(second_datasets.count).must_equal 2
    second_datasets.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset }
    _(second_datasets.token).must_be :nil?
  end

  it "paginates datasets with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_datasets, list_datasets_gapi(3, "next_page_token"),
      [project], all: nil, filter: nil, max_results: nil, page_token: nil
    mock.expect :list_datasets, list_datasets_gapi(2),
      [project], all: nil, filter: nil, max_results: nil, page_token: "next_page_token"
    bigquery.service.mocked_service = mock

    first_datasets = bigquery.datasets
    second_datasets = first_datasets.next

    mock.verify

    _(first_datasets.count).must_equal 3
    first_datasets.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset }
    _(first_datasets.next?).must_equal true

    _(second_datasets.count).must_equal 2
    second_datasets.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset }
    _(second_datasets.next?).must_equal false
  end

  it "paginates datasets with next? and next with all/hidden set" do
    mock = Minitest::Mock.new
    mock.expect :list_datasets, list_datasets_gapi(3, "next_page_token"),
      [project], all: true, filter: nil, max_results: nil, page_token: nil
    mock.expect :list_datasets, list_datasets_gapi(2),
      [project], all: true, filter: nil, max_results: nil, page_token: "next_page_token"
    bigquery.service.mocked_service = mock

    first_datasets = bigquery.datasets all: true
    second_datasets = first_datasets.next

    mock.verify

    _(first_datasets.count).must_equal 3
    first_datasets.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset }
    _(first_datasets.next?).must_equal true

    _(second_datasets.count).must_equal 2
    second_datasets.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset }
    _(second_datasets.next?).must_equal false
  end

  it "paginates datasets with next? and next with filter set" do
    mock = Minitest::Mock.new
    mock.expect :list_datasets, list_datasets_gapi(3, "next_page_token"),
      [project], all: nil, filter: filter, max_results: nil, page_token: nil
    mock.expect :list_datasets, list_datasets_gapi(2),
      [project], all: nil, filter: filter, max_results: nil, page_token: "next_page_token"
    bigquery.service.mocked_service = mock

    first_datasets = bigquery.datasets filter: filter
    second_datasets = first_datasets.next

    mock.verify

    _(first_datasets.count).must_equal 3
    first_datasets.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset }
    _(first_datasets.next?).must_equal true

    _(second_datasets.count).must_equal 2
    second_datasets.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset }
    _(second_datasets.next?).must_equal false
  end

  it "paginates datasets with next? and next with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_datasets, list_datasets_gapi(3, "next_page_token"),
      [project], all: nil, filter: nil, max_results: 3, page_token: nil
    mock.expect :list_datasets, list_datasets_gapi(2),
      [project], all: nil, filter: nil, max_results: 3, page_token: "next_page_token"
    bigquery.service.mocked_service = mock

    first_datasets = bigquery.datasets max: 3
    second_datasets = first_datasets.next

    mock.verify

    _(first_datasets.count).must_equal 3
    first_datasets.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset }
    _(first_datasets.next?).must_equal true

    _(second_datasets.count).must_equal 2
    second_datasets.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset }
    _(second_datasets.next?).must_equal false
  end

  it "paginates datasets with all" do
    mock = Minitest::Mock.new
    mock.expect :list_datasets, list_datasets_gapi(3, "next_page_token"),
      [project], all: nil, filter: nil, max_results: nil, page_token: nil
    mock.expect :list_datasets, list_datasets_gapi(2),
      [project], all: nil, filter: nil, max_results: nil, page_token: "next_page_token"
    bigquery.service.mocked_service = mock

    datasets = bigquery.datasets.all.to_a

    mock.verify

    _(datasets.count).must_equal 5
    datasets.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset }
  end

  it "paginates datasets with all with all/hidden set" do
    mock = Minitest::Mock.new
    mock.expect :list_datasets, list_datasets_gapi(3, "next_page_token"),
      [project], all: true, filter: nil, max_results: nil, page_token: nil
    mock.expect :list_datasets, list_datasets_gapi(2),
      [project], all: true, filter: nil, max_results: nil, page_token: "next_page_token"
    bigquery.service.mocked_service = mock

    datasets = bigquery.datasets(all: true).all.to_a

    mock.verify

    _(datasets.count).must_equal 5
    datasets.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset }
  end

  it "paginates datasets with all with filter set" do
    mock = Minitest::Mock.new
    mock.expect :list_datasets, list_datasets_gapi(3, "next_page_token"),
      [project], all: nil, filter: filter, max_results: nil, page_token: nil
    mock.expect :list_datasets, list_datasets_gapi(2),
      [project], all: nil, filter: filter, max_results: nil, page_token: "next_page_token"
    bigquery.service.mocked_service = mock

    datasets = bigquery.datasets(filter: filter).all.to_a

    mock.verify

    _(datasets.count).must_equal 5
    datasets.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset }
  end

  it "paginates datasets with all with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_datasets, list_datasets_gapi(3, "next_page_token"),
      [project], all: nil, filter: nil, max_results: 3, page_token: nil
    mock.expect :list_datasets, list_datasets_gapi(2),
      [project], all: nil, filter: nil, max_results: 3, page_token: "next_page_token"
    bigquery.service.mocked_service = mock

    datasets = bigquery.datasets(max: 3).all.to_a

    mock.verify

    _(datasets.count).must_equal 5
    datasets.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset }
  end

  it "iterates datasets with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_datasets, list_datasets_gapi(3, "next_page_token"),
      [project], all: nil, filter: nil, max_results: nil, page_token: nil
    mock.expect :list_datasets, list_datasets_gapi(3, "second_page_token"),
      [project], all: nil, filter: nil, max_results: nil, page_token: "next_page_token"
    bigquery.service.mocked_service = mock

    datasets = bigquery.datasets.all.take(5)

    mock.verify

    _(datasets.count).must_equal 5
    datasets.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset }
  end

  it "iterates datasets with all with request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_datasets, list_datasets_gapi(3, "next_page_token"),
      [project], all: nil, filter: nil, max_results: nil, page_token: nil
    mock.expect :list_datasets, list_datasets_gapi(3, "second_page_token"),
      [project], all: nil, filter: nil, max_results: nil, page_token: "next_page_token"
    bigquery.service.mocked_service = mock

    datasets = bigquery.datasets.all(request_limit: 1).to_a

    mock.verify

    _(datasets.count).must_equal 6
    datasets.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset }
  end

  it "finds a dataset" do
    dataset_id = "found_dataset"
    dataset_name = "Found Dataset"

    mock = Minitest::Mock.new
    mock.expect :get_dataset, find_dataset_gapi(dataset_id, dataset_name),
      [project, dataset_id]
    bigquery.service.mocked_service = mock

    dataset = bigquery.dataset dataset_id

    mock.verify

    _(dataset).must_be_kind_of Google::Cloud::Bigquery::Dataset
    _(dataset.dataset_id).must_equal dataset_id
    _(dataset.name).must_equal dataset_name
  end

  it "finds a dataset with skip_lookup option" do
    dataset_id = "found_dataset"
    # No HTTP mock needed, since the lookup is not made

    dataset = bigquery.dataset dataset_id, skip_lookup: true

    _(dataset).must_be_kind_of Google::Cloud::Bigquery::Dataset
    _(dataset).must_be :reference?
    _(dataset).wont_be :resource?
    _(dataset).wont_be :resource_partial?
    _(dataset).wont_be :resource_full?
  end

  it "finds a dataset with skip_lookup option and then reloads it" do
    dataset_id = "found_dataset"
    dataset_name = "Found Dataset"

    mock = Minitest::Mock.new
    mock.expect :get_dataset, find_dataset_gapi(dataset_id, dataset_name),
      [project, dataset_id]
    bigquery.service.mocked_service = mock

    dataset = bigquery.dataset dataset_id, skip_lookup: true

    _(dataset).must_be_kind_of Google::Cloud::Bigquery::Dataset
    _(dataset).must_be :reference?
    _(dataset).wont_be :resource?
    _(dataset).wont_be :resource_partial?
    _(dataset).wont_be :resource_full?
    _(dataset.dataset_id).must_equal dataset_id # does not call reload! internally

    dataset.reload!
    _(dataset.name).must_equal dataset_name
    _(dataset).wont_be :reference?
    _(dataset).must_be :resource?
    _(dataset).wont_be :resource_partial?
    _(dataset).must_be :resource_full?

    mock.verify
  end

  it "finds a dataset with skip_lookup option and then loads it by calling exists?" do
    dataset_id = "found_dataset"
    dataset_name = "Found Dataset"

    mock = Minitest::Mock.new
    mock.expect :get_dataset, find_dataset_gapi(dataset_id, dataset_name),
      [project, dataset_id]
    bigquery.service.mocked_service = mock

    dataset = bigquery.dataset dataset_id, skip_lookup: true

    _(dataset).must_be_kind_of Google::Cloud::Bigquery::Dataset
    _(dataset).must_be :reference?
    _(dataset.project_id).must_equal project # does not call reload! internally
    _(dataset.dataset_id).must_equal dataset_id # does not call reload! internally
    _(dataset.dataset_ref).wont_be_nil
    _(dataset).must_be :reference?
    _(dataset).wont_be :resource?
    _(dataset).wont_be :resource_partial?
    _(dataset).wont_be :resource_full?

    dataset.exists? # calls reload! internally
    _(dataset).wont_be :reference?
    _(dataset).must_be :resource?
    _(dataset).wont_be :resource_partial?
    _(dataset).must_be :resource_full?
    _(dataset.name).must_equal dataset_name

    mock.verify
  end

  it "finds a dataset with skip_lookup option if dataset_id is nil" do
    dataset_id = nil

    error = expect do
      bigquery.dataset dataset_id, skip_lookup: true
    end.must_raise ArgumentError
    _(error.message).must_equal "dataset_id is required"
  end

  it "finds a job" do
    job_id = "9876543210"
    mock = Minitest::Mock.new
    mock.expect :get_job, find_job_gapi(job_id),
      [project, job_id], location: nil
    bigquery.service.mocked_service = mock

    job = bigquery.job job_id

    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::Job
    _(job.job_id).must_equal job_id
  end

  it "finds a job with location" do
    job_id = "9876543210"
    region = "EU"
    mock = Minitest::Mock.new
    mock.expect :get_job, find_job_gapi(job_id, location: region),
                [project, job_id], location: region
    bigquery.service.mocked_service = mock

    job = bigquery.job job_id, location: region

    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::Job
    _(job.job_id).must_equal job_id
    _(job.location).must_equal region
  end

  it "lists projects" do
    mock = Minitest::Mock.new
    mock.expect :list_projects, list_projects_gapi(3),
      max_results: nil, page_token: nil
    bigquery.service.mocked_service = mock

    projects = bigquery.projects

    mock.verify

    _(projects.size).must_equal 3
    projects.each do |project|
      _(project).must_be_kind_of Google::Cloud::Bigquery::Project
      _(project.name).must_equal "project-name"
      _(project.numeric_id).must_equal 1234567890
      _(project.project).must_equal "project-id-12345"
    end
  end

  it "lists projects with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_projects, list_projects_gapi(3, "next_page_token"),
      max_results: 3, page_token: nil
    bigquery.service.mocked_service = mock

    projects = bigquery.projects max: 3

    mock.verify

    _(projects.count).must_equal 3
    projects.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Project }
    _(projects.token).wont_be :nil?
    _(projects.token).must_equal "next_page_token"
  end

  it "paginates projects" do
    mock = Minitest::Mock.new
    mock.expect :list_projects, list_projects_gapi(3, "next_page_token"),
      max_results: nil, page_token: nil
    mock.expect :list_projects, list_projects_gapi(2),
      max_results: nil, page_token: "next_page_token"
    bigquery.service.mocked_service = mock

    first_projects = bigquery.projects
    second_projects = bigquery.projects token: first_projects.token

    mock.verify

    _(first_projects.count).must_equal 3
    first_projects.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Project }
    _(first_projects.token).wont_be :nil?
    _(first_projects.token).must_equal "next_page_token"

    _(second_projects.count).must_equal 2
    second_projects.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Project }
    _(second_projects.token).must_be :nil?
  end

  it "paginates projects using next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_projects, list_projects_gapi(3, "next_page_token"),
      max_results: nil, page_token: nil
    mock.expect :list_projects, list_projects_gapi(2),
      max_results: nil, page_token: "next_page_token"
    bigquery.service.mocked_service = mock

    first_projects = bigquery.projects
    second_projects = first_projects.next

    mock.verify

    _(first_projects.count).must_equal 3
    first_projects.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Project }
    _(first_projects.next?).must_equal true

    _(second_projects.count).must_equal 2
    second_projects.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Project }
    _(second_projects.next?).must_equal false
  end

  it "paginates projects with all" do
    mock = Minitest::Mock.new
    mock.expect :list_projects, list_projects_gapi(3, "next_page_token"),
      max_results: nil, page_token: nil
    mock.expect :list_projects, list_projects_gapi(2),
      max_results: nil, page_token: "next_page_token"
    bigquery.service.mocked_service = mock

    projects = bigquery.projects.all.to_a

    mock.verify

    _(projects.count).must_equal 5
    projects.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Project }
  end

  it "iterates projects with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_projects, list_projects_gapi(3, "next_page_token"),
      max_results: nil, page_token: nil
    mock.expect :list_projects, list_projects_gapi(3, "second_page_token"),
      max_results: nil, page_token: "next_page_token"
    bigquery.service.mocked_service = mock

    projects = bigquery.projects.all.take(5)

    mock.verify

    _(projects.count).must_equal 5
    projects.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Project }
  end

  it "iterates projects with all with request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_projects, list_projects_gapi(3, "next_page_token"),
      max_results: nil, page_token: nil
    mock.expect :list_projects, list_projects_gapi(3, "second_page_token"),
      max_results: nil, page_token: "next_page_token"
    bigquery.service.mocked_service = mock

    projects = bigquery.projects.all(request_limit: 1).to_a

    mock.verify

    _(projects.count).must_equal 6
    projects.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Project }
  end

  it "creates a schema" do
    schema = bigquery.schema
    _(schema).must_be_kind_of Google::Cloud::Bigquery::Schema
    _(schema).wont_be :frozen?
    _(schema.fields).must_be :empty?
  end

  it "creates a schema with configuration in a block" do
    schema = bigquery.schema do |s|
      s.string "first_name", mode: :required
    end
    _(schema).must_be_kind_of Google::Cloud::Bigquery::Schema
    _(schema).wont_be :frozen?
    _(schema.fields).wont_be :empty?
    _(schema.fields.size).must_equal 1
    _(schema.fields[0].name).must_equal "first_name"
    _(schema.fields[0].mode).must_equal "REQUIRED"
  end

  def create_dataset_gapi id, name = nil, description = nil, default_expiration = nil, location = "US"
    Google::Apis::BigqueryV2::Dataset.from_json \
      random_dataset_hash(id, name, description, default_expiration, location).to_json
  end

  def find_dataset_gapi id, name = nil, description = nil, default_expiration = nil
    Google::Apis::BigqueryV2::Dataset.from_json \
      random_dataset_hash(id, name, description, default_expiration).to_json
  end

  def list_projects_gapi count = 2, token = nil
    hash = {
      "kind" => "bigquery#projectList",
      "etag" => "etag",
      "projects" => count.times.map { random_project_hash },
      "totalItems" => count
    }
    hash["nextPageToken"] = token unless token.nil?

    Google::Apis::BigqueryV2::ProjectList.from_json hash.to_json
  end
end
