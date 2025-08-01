# frozen_string_literal: true
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: google/cloud/discoveryengine/v1/document.proto

require 'google/protobuf'

require 'google/api/field_behavior_pb'
require 'google/api/resource_pb'
require 'google/cloud/discoveryengine/v1/common_pb'
require 'google/protobuf/struct_pb'
require 'google/protobuf/timestamp_pb'
require 'google/rpc/status_pb'


descriptor_data = "\n.google/cloud/discoveryengine/v1/document.proto\x12\x1fgoogle.cloud.discoveryengine.v1\x1a\x1fgoogle/api/field_behavior.proto\x1a\x19google/api/resource.proto\x1a,google/cloud/discoveryengine/v1/common.proto\x1a\x1cgoogle/protobuf/struct.proto\x1a\x1fgoogle/protobuf/timestamp.proto\x1a\x17google/rpc/status.proto\"\xad\t\n\x08\x44ocument\x12.\n\x0bstruct_data\x18\x04 \x01(\x0b\x32\x17.google.protobuf.StructH\x00\x12\x13\n\tjson_data\x18\x05 \x01(\tH\x00\x12\x11\n\x04name\x18\x01 \x01(\tB\x03\xe0\x41\x05\x12\x0f\n\x02id\x18\x02 \x01(\tB\x03\xe0\x41\x05\x12\x11\n\tschema_id\x18\x03 \x01(\t\x12\x42\n\x07\x63ontent\x18\n \x01(\x0b\x32\x31.google.cloud.discoveryengine.v1.Document.Content\x12\x1a\n\x12parent_document_id\x18\x07 \x01(\t\x12\x39\n\x13\x64\x65rived_struct_data\x18\x06 \x01(\x0b\x32\x17.google.protobuf.StructB\x03\xe0\x41\x03\x12\x43\n\x08\x61\x63l_info\x18\x0b \x01(\x0b\x32\x31.google.cloud.discoveryengine.v1.Document.AclInfo\x12\x33\n\nindex_time\x18\r \x01(\x0b\x32\x1a.google.protobuf.TimestampB\x03\xe0\x41\x03\x12P\n\x0cindex_status\x18\x0f \x01(\x0b\x32\x35.google.cloud.discoveryengine.v1.Document.IndexStatusB\x03\xe0\x41\x03\x1aK\n\x07\x43ontent\x12\x13\n\traw_bytes\x18\x02 \x01(\x0cH\x00\x12\r\n\x03uri\x18\x03 \x01(\tH\x00\x12\x11\n\tmime_type\x18\x01 \x01(\tB\t\n\x07\x63ontent\x1a\xc6\x01\n\x07\x41\x63lInfo\x12T\n\x07readers\x18\x01 \x03(\x0b\x32\x43.google.cloud.discoveryengine.v1.Document.AclInfo.AccessRestriction\x1a\x65\n\x11\x41\x63\x63\x65ssRestriction\x12>\n\nprincipals\x18\x01 \x03(\x0b\x32*.google.cloud.discoveryengine.v1.Principal\x12\x10\n\x08idp_wide\x18\x02 \x01(\x08\x1a\x86\x01\n\x0bIndexStatus\x12.\n\nindex_time\x18\x01 \x01(\x0b\x32\x1a.google.protobuf.Timestamp\x12)\n\rerror_samples\x18\x02 \x03(\x0b\x32\x12.google.rpc.Status\x12\x1c\n\x0fpending_message\x18\x03 \x01(\tB\x03\xe0\x41\x05:\x96\x02\xea\x41\x92\x02\n\'discoveryengine.googleapis.com/Document\x12\x66projects/{project}/locations/{location}/dataStores/{data_store}/branches/{branch}/documents/{document}\x12\x7fprojects/{project}/locations/{location}/collections/{collection}/dataStores/{data_store}/branches/{branch}/documents/{document}B\x06\n\x04\x64\x61taB\x80\x02\n#com.google.cloud.discoveryengine.v1B\rDocumentProtoP\x01ZMcloud.google.com/go/discoveryengine/apiv1/discoveryenginepb;discoveryenginepb\xa2\x02\x0f\x44ISCOVERYENGINE\xaa\x02\x1fGoogle.Cloud.DiscoveryEngine.V1\xca\x02\x1fGoogle\\Cloud\\DiscoveryEngine\\V1\xea\x02\"Google::Cloud::DiscoveryEngine::V1b\x06proto3"

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
    ["google.protobuf.Struct", "google/protobuf/struct.proto"],
    ["google.protobuf.Timestamp", "google/protobuf/timestamp.proto"],
    ["google.cloud.discoveryengine.v1.Principal", "google/cloud/discoveryengine/v1/common.proto"],
    ["google.rpc.Status", "google/rpc/status.proto"],
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
    module DiscoveryEngine
      module V1
        Document = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.discoveryengine.v1.Document").msgclass
        Document::Content = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.discoveryengine.v1.Document.Content").msgclass
        Document::AclInfo = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.discoveryengine.v1.Document.AclInfo").msgclass
        Document::AclInfo::AccessRestriction = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.discoveryengine.v1.Document.AclInfo.AccessRestriction").msgclass
        Document::IndexStatus = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.discoveryengine.v1.Document.IndexStatus").msgclass
      end
    end
  end
end
