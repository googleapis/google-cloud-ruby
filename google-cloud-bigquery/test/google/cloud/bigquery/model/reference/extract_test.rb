# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a extract of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Bigquery::Table, :extract, :mock_bigquery do
  let(:dataset) { "dataset" }
  # Create a model object with the project's mocked connection object
  let(:model_id) { "my_model" }
  let(:model_hash) { random_model_partial_hash dataset, model_id }
  let(:model) {Google::Cloud::Bigquery::Model.new_reference project, dataset, model_id, bigquery.service }
  let(:extract_url) { "gs://my-bucket/#{model.model_id}" }
  let(:labels) { { "foo" => "bar" } }
  let(:region) { "asia-northeast1" }

  it "can extract itself to a storage url with extract" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi(model, extract_url, location: nil)
    job_resp_gapi = job_gapi.dup
    job_resp_gapi.status = status "done"

    mock.expect :insert_job, job_resp_gapi, [project, job_gapi]

    result = model.extract extract_url
    mock.verify

    _(result).must_equal true
  end

  it "can extract itself to a storage url with extract_job" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi model, extract_url, location: nil
    job_resp_gapi = job_gapi.dup
    job_resp_gapi.status = status "done"

    mock.expect :insert_job, job_resp_gapi, [project, job_gapi]

    job = model.extract_job extract_url
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::ExtractJob
  end

  it "sets a provided job_id prefix in the updater" do
    generated_id = "9876543210"
    prefix = "my_test_job_prefix_"
    job_id = prefix + generated_id

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi model, extract_url, job_id: job_id, location: nil

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = model.extract_job extract_url, prefix: prefix do |j|
      _(j.job_id).must_equal job_id
    end
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::ExtractJob
    _(job.job_id).must_equal job_id
  end

  it "can extract itself and specify the ml_tf_saved_model format and options" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi model, extract_url, location: nil
    job_gapi.configuration.extract.destination_format = "ML_TF_SAVED_MODEL"

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = model.extract_job extract_url do |j|
      j.format = :ml_tf_saved_model
    end
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::ExtractJob
  end

  it "can extract itself and specify the ml_xgboost_booster format" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi model, extract_url, location: nil
    job_gapi.configuration.extract.destination_format = "ML_XGBOOST_BOOSTER"

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = model.extract_job extract_url do |j|
      j.format = :ml_xgboost_booster
    end
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::ExtractJob
  end

  it "can extract itself with the job labels option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi model, extract_url, location: nil
    job_gapi.configuration.labels = labels

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = model.extract_job extract_url do |j|
      j.labels = labels
    end
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::ExtractJob
    _(job.labels).must_equal labels
  end

  it "can extract itself with the location option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    insert_job_gapi = extract_job_gapi model, extract_url, location: nil
    return_job_gapi = extract_job_gapi model, extract_url, location: nil
    insert_job_gapi.job_reference.location = region
    return_job_gapi.job_reference.location = region

    mock.expect :insert_job, return_job_gapi, [project, insert_job_gapi]

    job = model.extract_job extract_url do |j|
      _(j.location).must_be :nil?
      j.location = region
    end
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::ExtractJob
    _(job.location).must_equal region
  end
end
