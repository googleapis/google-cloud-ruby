# frozen_string_literal: true
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: google/spanner/v1/result_set.proto

require 'google/protobuf'

require 'google/api/field_behavior_pb'
require 'google/protobuf/struct_pb'
require 'google/spanner/v1/query_plan_pb'
require 'google/spanner/v1/transaction_pb'
require 'google/spanner/v1/type_pb'


descriptor_data = "\n\"google/spanner/v1/result_set.proto\x12\x11google.spanner.v1\x1a\x1fgoogle/api/field_behavior.proto\x1a\x1cgoogle/protobuf/struct.proto\x1a\"google/spanner/v1/query_plan.proto\x1a#google/spanner/v1/transaction.proto\x1a\x1cgoogle/spanner/v1/type.proto\"\xf2\x01\n\tResultSet\x12\x36\n\x08metadata\x18\x01 \x01(\x0b\x32$.google.spanner.v1.ResultSetMetadata\x12(\n\x04rows\x18\x02 \x03(\x0b\x32\x1a.google.protobuf.ListValue\x12\x30\n\x05stats\x18\x03 \x01(\x0b\x32!.google.spanner.v1.ResultSetStats\x12Q\n\x0fprecommit_token\x18\x05 \x01(\x0b\x32\x33.google.spanner.v1.MultiplexedSessionPrecommitTokenB\x03\xe0\x41\x01\"\xb7\x02\n\x10PartialResultSet\x12\x36\n\x08metadata\x18\x01 \x01(\x0b\x32$.google.spanner.v1.ResultSetMetadata\x12&\n\x06values\x18\x02 \x03(\x0b\x32\x16.google.protobuf.Value\x12\x15\n\rchunked_value\x18\x03 \x01(\x08\x12\x14\n\x0cresume_token\x18\x04 \x01(\x0c\x12\x30\n\x05stats\x18\x05 \x01(\x0b\x32!.google.spanner.v1.ResultSetStats\x12Q\n\x0fprecommit_token\x18\x08 \x01(\x0b\x32\x33.google.spanner.v1.MultiplexedSessionPrecommitTokenB\x03\xe0\x41\x01\x12\x11\n\x04last\x18\t \x01(\x08\x42\x03\xe0\x41\x01\"\xb7\x01\n\x11ResultSetMetadata\x12/\n\x08row_type\x18\x01 \x01(\x0b\x32\x1d.google.spanner.v1.StructType\x12\x33\n\x0btransaction\x18\x02 \x01(\x0b\x32\x1e.google.spanner.v1.Transaction\x12<\n\x15undeclared_parameters\x18\x03 \x01(\x0b\x32\x1d.google.spanner.v1.StructType\"\xb9\x01\n\x0eResultSetStats\x12\x30\n\nquery_plan\x18\x01 \x01(\x0b\x32\x1c.google.spanner.v1.QueryPlan\x12,\n\x0bquery_stats\x18\x02 \x01(\x0b\x32\x17.google.protobuf.Struct\x12\x19\n\x0frow_count_exact\x18\x03 \x01(\x03H\x00\x12\x1f\n\x15row_count_lower_bound\x18\x04 \x01(\x03H\x00\x42\x0b\n\trow_countB\xb1\x01\n\x15\x63om.google.spanner.v1B\x0eResultSetProtoP\x01Z5cloud.google.com/go/spanner/apiv1/spannerpb;spannerpb\xaa\x02\x17Google.Cloud.Spanner.V1\xca\x02\x17Google\\Cloud\\Spanner\\V1\xea\x02\x1aGoogle::Cloud::Spanner::V1b\x06proto3"

pool = Google::Protobuf::DescriptorPool.generated_pool

begin
  pool.add_serialized_file(descriptor_data)
rescue TypeError
  # Compatibility code: will be removed in the next major version.
  require 'google/protobuf/descriptor_pb'
  parsed = Google::Protobuf::FileDescriptorProto.decode(descriptor_data)
  parsed.clear_dependency
  serialized = parsed.class.encode(parsed)
  file = pool.add_serialized_file(serialized)
  warn "Warning: Protobuf detected an import path issue while loading generated file #{__FILE__}"
  imports = [
    ["google.protobuf.ListValue", "google/protobuf/struct.proto"],
    ["google.spanner.v1.MultiplexedSessionPrecommitToken", "google/spanner/v1/transaction.proto"],
    ["google.spanner.v1.StructType", "google/spanner/v1/type.proto"],
    ["google.spanner.v1.QueryPlan", "google/spanner/v1/query_plan.proto"],
  ]
  imports.each do |type_name, expected_filename|
    import_file = pool.lookup(type_name).file_descriptor
    if import_file.name != expected_filename
      warn "- #{file.name} imports #{expected_filename}, but that import was loaded as #{import_file.name}"
    end
  end
  warn "Each proto file must use a consistent fully-qualified name."
  warn "This will become an error in the next major version."
end

module Google
  module Cloud
    module Spanner
      module V1
        ResultSet = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.spanner.v1.ResultSet").msgclass
        PartialResultSet = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.spanner.v1.PartialResultSet").msgclass
        ResultSetMetadata = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.spanner.v1.ResultSetMetadata").msgclass
        ResultSetStats = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.spanner.v1.ResultSetStats").msgclass
      end
    end
  end
end
