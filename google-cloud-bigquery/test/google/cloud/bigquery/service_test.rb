# Copyright 2018 Google LLC
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

describe Google::Cloud::Bigquery::Service do
  Service = Google::Cloud::Bigquery::Service
  let(:project_id) { "my-project" }
  let(:client) { "authorization client" }
  let(:retries) { 3 }
  let(:timeout) { 30_000 }
  let(:host) { "example.com" }
  let(:quota_project) { "my-quota-project" }
  let(:dataset_id) { "my_dataset" }
  let(:table_id) { "my_table" }
  let(:project_id_default) { "my-project-default" }
  let(:dataset_id_default) { "my_dataset_default" }
  let(:table_id_default) { "my_table_default" }
  let(:project_default_ref) { Google::Apis::BigqueryV2::ProjectReference.new project_id: project_id_default }
  let(:dataset_default_ref) { Google::Apis::BigqueryV2::DatasetReference.new project_id: project_id_default, dataset_id: dataset_id_default }
  let(:table_default_ref) { Google::Apis::BigqueryV2::TableReference.new project_id: project_id_default, dataset_id: dataset_id_default, table_id: table_id_default }
  let(:default_credentials) do
    creds = OpenStruct.new empty: true
    def creds.is_a? target
      target == Google::Auth::Credentials
    end
    creds
  end
  let(:default_universe_credentials) do
    client = OpenStruct.new universe_domain: "googleapis.com"
    creds = OpenStruct.new empty: true, client: client
    def creds.is_a? target
      target == Google::Auth::Credentials
    end
    creds
  end

  it "creates a Google::Apis::BigqueryV2::BigqueryService" do
    mock_credentials = Minitest::Mock.new
    mock_credentials.expect :client, client, []
    service = Service.new project_id,
                          mock_credentials,
                          retries: retries,
                          timeout: timeout,
                          host: host,
                          quota_project: quota_project

    v2_service = service.service
    _(v2_service).must_be_kind_of Google::Apis::BigqueryV2::BigqueryService

    _(v2_service.client_options.application_name).must_equal "gcloud-ruby"
    _(v2_service.client_options.application_version).must_equal Google::Cloud::Bigquery::VERSION
    _(v2_service.client_options.open_timeout_sec).must_equal timeout
    _(v2_service.client_options.read_timeout_sec).must_equal timeout
    _(v2_service.client_options.send_timeout_sec).must_equal timeout
    _(v2_service.request_options.retries).must_equal 0 # retries argument is used in #execute
    _(v2_service.request_options.header).must_be_kind_of Hash
    _(v2_service.request_options.header["x-goog-api-client"]).must_equal "gl-ruby/#{RUBY_VERSION} gccl/#{Google::Cloud::Bigquery::VERSION}"
    _(v2_service.request_options.query).must_be_kind_of Hash
    _(v2_service.request_options.query["prettyPrint"]).must_equal false
    _(v2_service.request_options.quota_project).must_equal quota_project
    _(v2_service.authorization).must_equal client
    _(v2_service.root_url).must_equal host
    _(v2_service.universe_domain).must_equal "googleapis.com"
  end

  it "supports setting a universe domain argument" do
    service = Google::Cloud::Bigquery::Service.new "my-project", default_credentials, universe_domain: "mydomain1.com"
    _(service.universe_domain).must_equal "mydomain1.com"
    _(service.service.root_url).must_equal "https://bigquery.mydomain1.com/"
  end

  it "supports setting a universe domain via environment variable" do
    ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = "mydomain2.com"
    service = Google::Cloud::Bigquery::Service.new "my-project", default_credentials
    _(service.universe_domain).must_equal "mydomain2.com"
    _(service.service.root_url).must_equal "https://bigquery.mydomain2.com/"
  ensure
    ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = nil
  end

  it "overrides universe domain with endpoint" do
    service = Google::Cloud::Bigquery::Service.new "my-project", default_credentials,
                                                   host: "https://bigquery.example.com/",
                                                   universe_domain: "mydomain3.com"
    _(service.universe_domain).must_equal "mydomain3.com"
    _(service.service.root_url).must_equal "https://bigquery.example.com/"
  end

  it "allows credentials with matching universe domain" do
    service = Google::Cloud::Bigquery::Service.new "my-project", default_universe_credentials
    service.service
  end

  it "errors on credentials with non-matching universe domain" do
    service = Google::Cloud::Bigquery::Service.new "my-project", default_universe_credentials, universe_domain: "wronguniverse.com"
    expect do
      service.service
    end.must_raise Google::Cloud::Error
  end

  it "returns table ref from standard sql format with project, dataset, table and no default ref" do
    table_ref = Service.table_ref_from_s "#{project_id}.#{dataset_id}.#{table_id}"
    _(table_ref).must_be_kind_of Google::Apis::BigqueryV2::TableReference
    _(table_ref.project_id).must_equal project_id
    _(table_ref.dataset_id).must_equal dataset_id
    _(table_ref.table_id).must_equal table_id
  end

  it "returns table ref from legacy sql format with project, dataset, table and no default ref" do
    table_ref = Service.table_ref_from_s "#{project_id}:#{dataset_id}.#{table_id}"
    _(table_ref.project_id).must_equal project_id
    _(table_ref.dataset_id).must_equal dataset_id
    _(table_ref.table_id).must_equal table_id
  end

  it "returns table ref from standard sql format with project, dataset, table and project default ref" do
    table_ref = Service.table_ref_from_s "#{project_id}.#{dataset_id}.#{table_id}", default_ref: project_default_ref
    _(table_ref.project_id).must_equal project_id
    _(table_ref.dataset_id).must_equal dataset_id
    _(table_ref.table_id).must_equal table_id
  end

  it "returns table ref from standard sql format with project, dataset, table and dataset default ref" do
    table_ref = Service.table_ref_from_s "#{project_id}.#{dataset_id}.#{table_id}", default_ref: dataset_default_ref
    _(table_ref.project_id).must_equal project_id
    _(table_ref.dataset_id).must_equal dataset_id
    _(table_ref.table_id).must_equal table_id
  end

  it "returns table ref from standard sql format with project, dataset, table and table default ref" do
    table_ref = Service.table_ref_from_s "#{project_id}.#{dataset_id}.#{table_id}", default_ref: table_default_ref
    _(table_ref.project_id).must_equal project_id
    _(table_ref.dataset_id).must_equal dataset_id
    _(table_ref.table_id).must_equal table_id
  end

  it "returns table ref from standard sql format with dataset, table and project default ref" do
    table_ref = Service.table_ref_from_s "#{dataset_id}.#{table_id}", default_ref: project_default_ref
    _(table_ref.project_id).must_equal project_id_default
    _(table_ref.dataset_id).must_equal dataset_id
    _(table_ref.table_id).must_equal table_id
  end

  it "returns table ref from standard sql format with dataset, table and dataset default ref" do
    table_ref = Service.table_ref_from_s "#{dataset_id}.#{table_id}", default_ref: dataset_default_ref
    _(table_ref.project_id).must_equal project_id_default
    _(table_ref.dataset_id).must_equal dataset_id
    _(table_ref.table_id).must_equal table_id
  end

  it "returns table ref from standard sql format with dataset, table and table default ref" do
    table_ref = Service.table_ref_from_s "#{dataset_id}.#{table_id}", default_ref: table_default_ref
    _(table_ref.project_id).must_equal project_id_default
    _(table_ref.dataset_id).must_equal dataset_id
    _(table_ref.table_id).must_equal table_id
  end

  it "raises from standard sql format with table and project default ref" do
    err = expect do
      Service.table_ref_from_s table_id, default_ref: project_default_ref
    end.must_raise ArgumentError
    _(err.message).must_equal "TableReference is missing dataset_id"
  end

  it "returns table ref from standard sql format with table and dataset default ref" do
    table_ref = Service.table_ref_from_s table_id, default_ref: dataset_default_ref
    _(table_ref.project_id).must_equal project_id_default
    _(table_ref.dataset_id).must_equal dataset_id_default
    _(table_ref.table_id).must_equal table_id
  end

  it "returns table ref from standard sql format with table and table default ref" do
    table_ref = Service.table_ref_from_s table_id, default_ref: table_default_ref
    _(table_ref.project_id).must_equal project_id_default
    _(table_ref.dataset_id).must_equal dataset_id_default
    _(table_ref.table_id).must_equal table_id
  end
end
