require "minitest/autorun"

require "google/cloud/errors"
require "google/cloud/compute/v1/accelerator_types"

# Misc smoke tests for Compute Client
class PaginationSmokeTest < Minitest::Test
  def setup
    @default_zone = "us-central1-a"
    @default_project = ENV["COMPUTE_TEST_PROJECT"]
    @client = Google::Cloud::Compute::V1::AcceleratorTypes::Rest::Client.new
    skip "COMPUTE_TEST_PROJECT must be set before running this test" if @default_project.nil?
  end

  def test_parse_unknown_enum_value
    deprectation_status_json = Google::Cloud::Compute::V1::DeprecationStatus.new(
      deleted: "foo",
      state: :OBSOLETE).to_json

    ds_decoded = ::Google::Cloud::Compute::V1::DeprecationStatus.decode_json deprectation_status_json
    assert_equal :OBSOLETE, ds_decoded.state

    unknown_enum_json = deprectation_status_json.gsub "OBSOLETE", "THIS_VALUE_DOES_NOT_EXIST"
    ds_decoded = ::Google::Cloud::Compute::V1::DeprecationStatus.decode_json unknown_enum_json
    assert_equal :UNDEFINED_STATE, ds_decoded.state
  end
end
