require "bigquery_helper"

describe Google::Cloud::Bigquery::Dataset, :bigquery do
  let(:dataset_id) { "#{prefix}_dataset_for_dataset_view_test" }
  let(:dataset_name) { "#{prefix}_dataset_for_dataset_view_test" }
  let(:dataset_description) { "This is my dataset" }
  let(:dataset_expiration) { 3600000 }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id, location: "US", name: dataset_name, description: dataset_description, expiration: dataset_expiration
    end
    d
  end

  before do
    dataset
  end

  after do
    dataset.delete force: true if dataset
  end

  it "gets dataset with DATASET_VIEW_UNSPECIFIED" do
    fresh = bigquery.dataset dataset_id, dataset_view: Google::Cloud::Bigquery::DatasetView::DATASET_VIEW_UNSPECIFIED
    _(fresh).must_be_kind_of Google::Cloud::Bigquery::Dataset
    _(fresh.name).must_equal dataset_name
    _(fresh.description).must_equal dataset_description
    _(fresh.default_expiration).must_equal dataset_expiration
    _(fresh.access).wont_be :empty?
  end

  it "gets dataset with METADATA" do
    fresh = bigquery.dataset dataset_id, dataset_view: Google::Cloud::Bigquery::DatasetView::METADATA
    _(fresh).must_be_kind_of Google::Cloud::Bigquery::Dataset
    _(fresh.name).must_equal dataset_name
    _(fresh.description).must_equal dataset_description
    _(fresh.default_expiration).must_equal dataset_expiration
    # METADATA view should not include access control list
    _(fresh.access).must_be :empty?
  end

  it "gets dataset with ACL" do
    fresh = bigquery.dataset dataset_id, dataset_view: Google::Cloud::Bigquery::DatasetView::ACL
    _(fresh).must_be_kind_of Google::Cloud::Bigquery::Dataset
    # ACL view should not include metadata
    _(fresh.name).must_be_nil
    _(fresh.description).must_be_nil
    _(fresh.default_expiration).must_be_nil
    _(fresh.access).wont_be :empty?
  end

  it "gets dataset with FULL" do
    fresh = bigquery.dataset dataset_id, dataset_view: Google::Cloud::Bigquery::DatasetView::FULL
    _(fresh).must_be_kind_of Google::Cloud::Bigquery::Dataset
    _(fresh.name).must_equal dataset_name
    _(fresh.description).must_equal dataset_description
    _(fresh.default_expiration).must_equal dataset_expiration
    _(fresh.access).wont_be :empty?
  end

  it "raises error with invalid dataset_view" do
    err = expect {fresh = bigquery.dataset dataset_id, dataset_view: "INVALID_VALUE"}.must_raise 
      Google::Cloud::InvalidArgumentError
    _(err.message).must_match "INVALID_ARGUMENT: Invalid value at 'dataset_view' (type.googleapis.com/google.cloud.bigquery.v2.GetDatasetRequest.DatasetView), \"INVALID_VALUE\""
  end
end