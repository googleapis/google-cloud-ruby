require "minitest/autorun"

require "google/cloud/errors"
require "google/cloud/compute/v1/accelerator_types"

# Misc tests for Compute Client
class MiscTest < Minitest::Test
  ##
  # This tests verifies that an unknown enum value in a proto json is getting parsed into an :UNDEFINED_STATE
  #
  def test_parse_unknown_enum_value
    deprecation_status_json = Google::Cloud::Compute::V1::DeprecationStatus.new(
      deleted: "foo",
      state: :OBSOLETE).to_json
       
    ds_decoded = ::Google::Cloud::Compute::V1::DeprecationStatus.decode_json deprecation_status_json, ignore_unknown_fields: true
    assert_equal :OBSOLETE, ds_decoded.state
    
    # DeprecationStatus.state is a enum with the following values specified:
    # UNDEFINED_STATE = 0;
    # ACTIVE = 314733318;
    # DELETED = 120962041;
    # DEPRECATED = 463360435;
    # OBSOLETE = 66532761;
    # (see https://raw.githubusercontent.com/googleapis/googleapis-discovery/master/google/cloud/compute/v1/compute.proto)

    unknown_enum_json = deprecation_status_json.gsub "OBSOLETE", "THIS_VALUE_DOES_NOT_EXIST"
    ds_decoded = ::Google::Cloud::Compute::V1::DeprecationStatus.decode_json unknown_enum_json, ignore_unknown_fields: true
    assert_equal :UNDEFINED_STATE, ds_decoded.state
  end
end
