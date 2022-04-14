require "minitest/autorun"

require "google/cloud/errors"
require "google/cloud/compute/v1/accelerator_types"

# Misc tests for Compute Client
class MiscTest < Minitest::Test
  ##
  # This tests verifies that an unknown enum value in a proto json is getting parsed into an :UNDEFINED_STATE
  #
  def test_parse_unknown_stringenum_value
    deprecation_status_json = ::Google::Cloud::Compute::V1::DeprecationStatus.new(
      deleted: "foo",
      state: :OBSOLETE).to_json

    ds_decoded = ::Google::Cloud::Compute::V1::DeprecationStatus.decode_json deprecation_status_json, ignore_unknown_fields: true
    assert_equal "OBSOLETE", ds_decoded.state

    # DeprecationStatus.state is a enum with the following values specified:
    # UNDEFINED_STATE = 0;
    # ACTIVE = 314733318;
    # DELETED = 120962041;
    # DEPRECATED = 463360435;
    # OBSOLETE = 66532761;
    # (see https://raw.githubusercontent.com/googleapis/googleapis-discovery/master/google/cloud/compute/v1/compute.proto)

    unknown_enum_json = deprecation_status_json.gsub "OBSOLETE", "THIS_VALUE_DOES_NOT_EXIST"
    ds_decoded = ::Google::Cloud::Compute::V1::DeprecationStatus.decode_json unknown_enum_json, ignore_unknown_fields: true
    assert_equal "THIS_VALUE_DOES_NOT_EXIST", ds_decoded.state
  end

  def test_parse_numeric_stringenum_value
    deprecation_status_json = ::Google::Cloud::Compute::V1::DeprecationStatus.new(
      deleted: "foo",
      state: :OBSOLETE).to_json

    ds_decoded = ::Google::Cloud::Compute::V1::DeprecationStatus.decode_json deprecation_status_json, ignore_unknown_fields: true
    assert_equal "OBSOLETE", ds_decoded.state
    
    int_enumstr_json = deprecation_status_json.gsub "\"OBSOLETE\"", "42"
    
    err = assert_raises ::Google::Protobuf::ParseError do 
      ds_decoded = ::Google::Cloud::Compute::V1::DeprecationStatus.decode_json int_enumstr_json, ignore_unknown_fields: true
    end

    assert_match /Error parsing JSON/, err.message
    assert_match /Expected string/, err.message
  end
  
  def test_parse_numeric_stringenum_value
    operation_json = ::Google::Cloud::Compute::V1::Operation.new(
      status: :PENDING
    ).to_json

    # enum Status {
    #   // A value indicating that the enum field is not set.
    #   UNDEFINED_STATUS = 0;
  
    #   DONE = 2104194;
  
    #   PENDING = 35394935;
  
    #   RUNNING = 121282975;
  
    # }
    
    op_decoded = ::Google::Cloud::Compute::V1::Operation.decode_json operation_json, ignore_unknown_fields: true
    assert_equal :PENDING, op_decoded.status

    # Passing an unknown int works
    int_enum_json = operation_json.gsub '"PENDING"', '42'
    op_decoded = ::Google::Cloud::Compute::V1::Operation.decode_json int_enum_json, ignore_unknown_fields: true
    assert_equal 42, op_decoded.status

    # Passing an unknown string value works, as long as you give the `ignore_unknown_fields: true` option
    unknown_enum_json = operation_json.gsub "PENDING", "THIS_VALUE_DOES_NOT_EXIST"
    op_decoded = ::Google::Cloud::Compute::V1::Operation.decode_json unknown_enum_json, ignore_unknown_fields: true
    assert_equal :UNDEFINED_STATUS, op_decoded.status

    # Passing an unknown string value throws without the `ignore_unknown_fields: true` option
    ex = assert_raises ::Google::Protobuf::ParseError do
      op_decoded = ::Google::Cloud::Compute::V1::Operation.decode_json unknown_enum_json
    end
    assert_match /Error parsing JSON.*Unknown enumerator.*THIS_VALUE_DOES_NOT_EXIST/, ex.message
  end
end
