# frozen_string_literal: true
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: google/cloud/oracledatabase/v1/db_server.proto

require 'google/protobuf'

require 'google/api/field_behavior_pb'
require 'google/api/resource_pb'


descriptor_data = "\n.google/cloud/oracledatabase/v1/db_server.proto\x12\x1egoogle.cloud.oracledatabase.v1\x1a\x1fgoogle/api/field_behavior.proto\x1a\x19google/api/resource.proto\"\xc3\x02\n\x08\x44\x62Server\x12\x11\n\x04name\x18\x01 \x01(\tB\x03\xe0\x41\x08\x12\x19\n\x0c\x64isplay_name\x18\x02 \x01(\tB\x03\xe0\x41\x01\x12K\n\nproperties\x18\x03 \x01(\x0b\x32\x32.google.cloud.oracledatabase.v1.DbServerPropertiesB\x03\xe0\x41\x01:\xbb\x01\xea\x41\xb7\x01\n&oracledatabase.googleapis.com/DbServer\x12xprojects/{project}/locations/{location}/cloudExadataInfrastructures/{cloud_exadata_infrastructure}/dbServers/{db_server}*\tdbServers2\x08\x64\x62Server\"\xd3\x03\n\x12\x44\x62ServerProperties\x12\x11\n\x04ocid\x18\x01 \x01(\tB\x03\xe0\x41\x03\x12\x17\n\nocpu_count\x18\x02 \x01(\x05\x42\x03\xe0\x41\x01\x12\x1b\n\x0emax_ocpu_count\x18\x03 \x01(\x05\x42\x03\xe0\x41\x01\x12\x1b\n\x0ememory_size_gb\x18\x04 \x01(\x05\x42\x03\xe0\x41\x01\x12\x1f\n\x12max_memory_size_gb\x18\x05 \x01(\x05\x42\x03\xe0\x41\x01\x12$\n\x17\x64\x62_node_storage_size_gb\x18\x06 \x01(\x05\x42\x03\xe0\x41\x01\x12(\n\x1bmax_db_node_storage_size_gb\x18\x07 \x01(\x05\x42\x03\xe0\x41\x01\x12\x15\n\x08vm_count\x18\x08 \x01(\x05\x42\x03\xe0\x41\x01\x12L\n\x05state\x18\t \x01(\x0e\x32\x38.google.cloud.oracledatabase.v1.DbServerProperties.StateB\x03\xe0\x41\x03\x12\x18\n\x0b\x64\x62_node_ids\x18\n \x03(\tB\x03\xe0\x41\x03\"g\n\x05State\x12\x15\n\x11STATE_UNSPECIFIED\x10\x00\x12\x0c\n\x08\x43REATING\x10\x01\x12\r\n\tAVAILABLE\x10\x02\x12\x0f\n\x0bUNAVAILABLE\x10\x03\x12\x0c\n\x08\x44\x45LETING\x10\x04\x12\x0b\n\x07\x44\x45LETED\x10\x05\x42\xe7\x01\n\"com.google.cloud.oracledatabase.v1B\rDbServerProtoP\x01ZJcloud.google.com/go/oracledatabase/apiv1/oracledatabasepb;oracledatabasepb\xaa\x02\x1eGoogle.Cloud.OracleDatabase.V1\xca\x02\x1eGoogle\\Cloud\\OracleDatabase\\V1\xea\x02!Google::Cloud::OracleDatabase::V1b\x06proto3"

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
    module OracleDatabase
      module V1
        DbServer = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.oracledatabase.v1.DbServer").msgclass
        DbServerProperties = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.oracledatabase.v1.DbServerProperties").msgclass
        DbServerProperties::State = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.oracledatabase.v1.DbServerProperties.State").enummodule
      end
    end
  end
end
