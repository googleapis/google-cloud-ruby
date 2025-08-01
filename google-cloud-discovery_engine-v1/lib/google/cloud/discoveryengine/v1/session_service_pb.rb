# frozen_string_literal: true
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: google/cloud/discoveryengine/v1/session_service.proto

require 'google/protobuf'

require 'google/api/annotations_pb'
require 'google/api/client_pb'
require 'google/api/field_behavior_pb'
require 'google/api/resource_pb'
require 'google/cloud/discoveryengine/v1/conversational_search_service_pb'
require 'google/cloud/discoveryengine/v1/session_pb'
require 'google/protobuf/empty_pb'


descriptor_data = "\n5google/cloud/discoveryengine/v1/session_service.proto\x12\x1fgoogle.cloud.discoveryengine.v1\x1a\x1cgoogle/api/annotations.proto\x1a\x17google/api/client.proto\x1a\x1fgoogle/api/field_behavior.proto\x1a\x19google/api/resource.proto\x1a\x43google/cloud/discoveryengine/v1/conversational_search_service.proto\x1a-google/cloud/discoveryengine/v1/session.proto\x1a\x1bgoogle/protobuf/empty.proto2\xda\x0e\n\x0eSessionService\x12\xf4\x02\n\rCreateSession\x12\x35.google.cloud.discoveryengine.v1.CreateSessionRequest\x1a(.google.cloud.discoveryengine.v1.Session\"\x81\x02\xda\x41\x0eparent,session\x82\xd3\xe4\x93\x02\xe9\x01\"9/v1/{parent=projects/*/locations/*/dataStores/*}/sessions:\x07sessionZR\"G/v1/{parent=projects/*/locations/*/collections/*/dataStores/*}/sessions:\x07sessionZO\"D/v1/{parent=projects/*/locations/*/collections/*/engines/*}/sessions:\x07session\x12\xbd\x02\n\rDeleteSession\x12\x35.google.cloud.discoveryengine.v1.DeleteSessionRequest\x1a\x16.google.protobuf.Empty\"\xdc\x01\xda\x41\x04name\x82\xd3\xe4\x93\x02\xce\x01*9/v1/{name=projects/*/locations/*/dataStores/*/sessions/*}ZI*G/v1/{name=projects/*/locations/*/collections/*/dataStores/*/sessions/*}ZF*D/v1/{name=projects/*/locations/*/collections/*/engines/*/sessions/*}\x12\x91\x03\n\rUpdateSession\x12\x35.google.cloud.discoveryengine.v1.UpdateSessionRequest\x1a(.google.cloud.discoveryengine.v1.Session\"\x9e\x02\xda\x41\x13session,update_mask\x82\xd3\xe4\x93\x02\x81\x02\x32\x41/v1/{session.name=projects/*/locations/*/dataStores/*/sessions/*}:\x07sessionZZ2O/v1/{session.name=projects/*/locations/*/collections/*/dataStores/*/sessions/*}:\x07sessionZW2L/v1/{session.name=projects/*/locations/*/collections/*/engines/*/sessions/*}:\x07session\x12\xc9\x02\n\nGetSession\x12\x32.google.cloud.discoveryengine.v1.GetSessionRequest\x1a(.google.cloud.discoveryengine.v1.Session\"\xdc\x01\xda\x41\x04name\x82\xd3\xe4\x93\x02\xce\x01\x12\x39/v1/{name=projects/*/locations/*/dataStores/*/sessions/*}ZI\x12G/v1/{name=projects/*/locations/*/collections/*/dataStores/*/sessions/*}ZF\x12\x44/v1/{name=projects/*/locations/*/collections/*/engines/*/sessions/*}\x12\xdc\x02\n\x0cListSessions\x12\x34.google.cloud.discoveryengine.v1.ListSessionsRequest\x1a\x35.google.cloud.discoveryengine.v1.ListSessionsResponse\"\xde\x01\xda\x41\x06parent\x82\xd3\xe4\x93\x02\xce\x01\x12\x39/v1/{parent=projects/*/locations/*/dataStores/*}/sessionsZI\x12G/v1/{parent=projects/*/locations/*/collections/*/dataStores/*}/sessionsZF\x12\x44/v1/{parent=projects/*/locations/*/collections/*/engines/*}/sessions\x1aR\xca\x41\x1e\x64iscoveryengine.googleapis.com\xd2\x41.https://www.googleapis.com/auth/cloud-platformB\x86\x02\n#com.google.cloud.discoveryengine.v1B\x13SessionServiceProtoP\x01ZMcloud.google.com/go/discoveryengine/apiv1/discoveryenginepb;discoveryenginepb\xa2\x02\x0f\x44ISCOVERYENGINE\xaa\x02\x1fGoogle.Cloud.DiscoveryEngine.V1\xca\x02\x1fGoogle\\Cloud\\DiscoveryEngine\\V1\xea\x02\"Google::Cloud::DiscoveryEngine::V1b\x06proto3"

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
    module DiscoveryEngine
      module V1
      end
    end
  end
end
