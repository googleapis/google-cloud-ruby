# frozen_string_literal: true
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: google/cloud/netapp/v1/replication.proto

require 'google/protobuf'

require 'google/api/field_behavior_pb'
require 'google/api/resource_pb'
require 'google/cloud/netapp/v1/volume_pb'
require 'google/protobuf/duration_pb'
require 'google/protobuf/field_mask_pb'
require 'google/protobuf/timestamp_pb'


descriptor_data = "\n(google/cloud/netapp/v1/replication.proto\x12\x16google.cloud.netapp.v1\x1a\x1fgoogle/api/field_behavior.proto\x1a\x19google/api/resource.proto\x1a#google/cloud/netapp/v1/volume.proto\x1a\x1egoogle/protobuf/duration.proto\x1a google/protobuf/field_mask.proto\x1a\x1fgoogle/protobuf/timestamp.proto\"\xd4\x04\n\rTransferStats\x12\x1b\n\x0etransfer_bytes\x18\x01 \x01(\x03H\x00\x88\x01\x01\x12?\n\x17total_transfer_duration\x18\x02 \x01(\x0b\x32\x19.google.protobuf.DurationH\x01\x88\x01\x01\x12 \n\x13last_transfer_bytes\x18\x03 \x01(\x03H\x02\x88\x01\x01\x12>\n\x16last_transfer_duration\x18\x04 \x01(\x0b\x32\x19.google.protobuf.DurationH\x03\x88\x01\x01\x12\x34\n\x0clag_duration\x18\x05 \x01(\x0b\x32\x19.google.protobuf.DurationH\x04\x88\x01\x01\x12\x34\n\x0bupdate_time\x18\x06 \x01(\x0b\x32\x1a.google.protobuf.TimestampH\x05\x88\x01\x01\x12?\n\x16last_transfer_end_time\x18\x07 \x01(\x0b\x32\x1a.google.protobuf.TimestampH\x06\x88\x01\x01\x12 \n\x13last_transfer_error\x18\x08 \x01(\tH\x07\x88\x01\x01\x42\x11\n\x0f_transfer_bytesB\x1a\n\x18_total_transfer_durationB\x16\n\x14_last_transfer_bytesB\x19\n\x17_last_transfer_durationB\x0f\n\r_lag_durationB\x0e\n\x0c_update_timeB\x19\n\x17_last_transfer_end_timeB\x16\n\x14_last_transfer_error\"\xc8\x0e\n\x0bReplication\x12\x11\n\x04name\x18\x01 \x01(\tB\x03\xe0\x41\x08\x12=\n\x05state\x18\x02 \x01(\x0e\x32).google.cloud.netapp.v1.Replication.StateB\x03\xe0\x41\x03\x12\x1a\n\rstate_details\x18\x03 \x01(\tB\x03\xe0\x41\x03\x12\x46\n\x04role\x18\x04 \x01(\x0e\x32\x33.google.cloud.netapp.v1.Replication.ReplicationRoleB\x03\xe0\x41\x03\x12Z\n\x14replication_schedule\x18\x05 \x01(\x0e\x32\x37.google.cloud.netapp.v1.Replication.ReplicationScheduleB\x03\xe0\x41\x02\x12J\n\x0cmirror_state\x18\x06 \x01(\x0e\x32/.google.cloud.netapp.v1.Replication.MirrorStateB\x03\xe0\x41\x03\x12\x19\n\x07healthy\x18\x08 \x01(\x08\x42\x03\xe0\x41\x03H\x00\x88\x01\x01\x12\x34\n\x0b\x63reate_time\x18\t \x01(\x0b\x32\x1a.google.protobuf.TimestampB\x03\xe0\x41\x03\x12@\n\x12\x64\x65stination_volume\x18\n \x01(\tB$\xe0\x41\x03\xfa\x41\x1e\n\x1cnetapp.googleapis.com/Volume\x12\x42\n\x0etransfer_stats\x18\x0b \x01(\x0b\x32%.google.cloud.netapp.v1.TransferStatsB\x03\xe0\x41\x03\x12?\n\x06labels\x18\x0c \x03(\x0b\x32/.google.cloud.netapp.v1.Replication.LabelsEntry\x12\x18\n\x0b\x64\x65scription\x18\r \x01(\tH\x01\x88\x01\x01\x12\x62\n\x1d\x64\x65stination_volume_parameters\x18\x0e \x01(\x0b\x32\x33.google.cloud.netapp.v1.DestinationVolumeParametersB\x06\xe0\x41\x04\xe0\x41\x02\x12;\n\rsource_volume\x18\x0f \x01(\tB$\xe0\x41\x03\xfa\x41\x1e\n\x1cnetapp.googleapis.com/Volume\x12Q\n\x16hybrid_peering_details\x18\x10 \x01(\x0b\x32,.google.cloud.netapp.v1.HybridPeeringDetailsB\x03\xe0\x41\x03\x12\x1d\n\x10\x63luster_location\x18\x12 \x01(\tB\x03\xe0\x41\x01\x12_\n\x17hybrid_replication_type\x18\x13 \x01(\x0e\x32\x39.google.cloud.netapp.v1.Replication.HybridReplicationTypeB\x03\xe0\x41\x03\x1a-\n\x0bLabelsEntry\x12\x0b\n\x03key\x18\x01 \x01(\t\x12\r\n\x05value\x18\x02 \x01(\t:\x02\x38\x01\"\x94\x01\n\x05State\x12\x15\n\x11STATE_UNSPECIFIED\x10\x00\x12\x0c\n\x08\x43REATING\x10\x01\x12\t\n\x05READY\x10\x02\x12\x0c\n\x08UPDATING\x10\x03\x12\x0c\n\x08\x44\x45LETING\x10\x05\x12\t\n\x05\x45RROR\x10\x06\x12\x1b\n\x17PENDING_CLUSTER_PEERING\x10\x08\x12\x17\n\x13PENDING_SVM_PEERING\x10\t\"P\n\x0fReplicationRole\x12 \n\x1cREPLICATION_ROLE_UNSPECIFIED\x10\x00\x12\n\n\x06SOURCE\x10\x01\x12\x0f\n\x0b\x44\x45STINATION\x10\x02\"h\n\x13ReplicationSchedule\x12$\n REPLICATION_SCHEDULE_UNSPECIFIED\x10\x00\x12\x14\n\x10\x45VERY_10_MINUTES\x10\x01\x12\n\n\x06HOURLY\x10\x02\x12\t\n\x05\x44\x41ILY\x10\x03\"\x8f\x01\n\x0bMirrorState\x12\x1c\n\x18MIRROR_STATE_UNSPECIFIED\x10\x00\x12\r\n\tPREPARING\x10\x01\x12\x0c\n\x08MIRRORED\x10\x02\x12\x0b\n\x07STOPPED\x10\x03\x12\x10\n\x0cTRANSFERRING\x10\x04\x12\x19\n\x15\x42\x41SELINE_TRANSFERRING\x10\x05\x12\x0b\n\x07\x41\x42ORTED\x10\x06\"k\n\x15HybridReplicationType\x12\'\n#HYBRID_REPLICATION_TYPE_UNSPECIFIED\x10\x00\x12\r\n\tMIGRATION\x10\x01\x12\x1a\n\x16\x43ONTINUOUS_REPLICATION\x10\x02:\x97\x01\xea\x41\x93\x01\n!netapp.googleapis.com/Replication\x12Sprojects/{project}/locations/{location}/volumes/{volume}/replications/{replication}*\x0creplications2\x0breplicationB\n\n\x08_healthyB\x0e\n\x0c_description\"\xf6\x01\n\x14HybridPeeringDetails\x12\x16\n\tsubnet_ip\x18\x01 \x01(\tB\x03\xe0\x41\x01\x12\x14\n\x07\x63ommand\x18\x02 \x01(\tB\x03\xe0\x41\x01\x12<\n\x13\x63ommand_expiry_time\x18\x03 \x01(\x0b\x32\x1a.google.protobuf.TimestampB\x03\xe0\x41\x01\x12\x17\n\npassphrase\x18\x04 \x01(\tB\x03\xe0\x41\x01\x12\x1d\n\x10peer_volume_name\x18\x05 \x01(\tB\x03\xe0\x41\x01\x12\x1e\n\x11peer_cluster_name\x18\x06 \x01(\tB\x03\xe0\x41\x01\x12\x1a\n\rpeer_svm_name\x18\x07 \x01(\tB\x03\xe0\x41\x01\"\x9d\x01\n\x17ListReplicationsRequest\x12\x39\n\x06parent\x18\x01 \x01(\tB)\xe0\x41\x02\xfa\x41#\x12!netapp.googleapis.com/Replication\x12\x11\n\tpage_size\x18\x02 \x01(\x05\x12\x12\n\npage_token\x18\x03 \x01(\t\x12\x10\n\x08order_by\x18\x04 \x01(\t\x12\x0e\n\x06\x66ilter\x18\x05 \x01(\t\"\x83\x01\n\x18ListReplicationsResponse\x12\x39\n\x0creplications\x18\x01 \x03(\x0b\x32#.google.cloud.netapp.v1.Replication\x12\x17\n\x0fnext_page_token\x18\x02 \x01(\t\x12\x13\n\x0bunreachable\x18\x03 \x03(\t\"P\n\x15GetReplicationRequest\x12\x37\n\x04name\x18\x01 \x01(\tB)\xe0\x41\x02\xfa\x41#\n!netapp.googleapis.com/Replication\"\x8b\x02\n\x1b\x44\x65stinationVolumeParameters\x12?\n\x0cstorage_pool\x18\x01 \x01(\tB)\xe0\x41\x02\xfa\x41#\n!netapp.googleapis.com/StoragePool\x12\x11\n\tvolume_id\x18\x02 \x01(\t\x12\x12\n\nshare_name\x18\x03 \x01(\t\x12\x18\n\x0b\x64\x65scription\x18\x04 \x01(\tH\x00\x88\x01\x01\x12G\n\x0etiering_policy\x18\x05 \x01(\x0b\x32%.google.cloud.netapp.v1.TieringPolicyB\x03\xe0\x41\x01H\x01\x88\x01\x01\x42\x0e\n\x0c_descriptionB\x11\n\x0f_tiering_policy\"\xb1\x01\n\x18\x43reateReplicationRequest\x12\x39\n\x06parent\x18\x01 \x01(\tB)\xe0\x41\x02\xfa\x41#\x12!netapp.googleapis.com/Replication\x12=\n\x0breplication\x18\x02 \x01(\x0b\x32#.google.cloud.netapp.v1.ReplicationB\x03\xe0\x41\x02\x12\x1b\n\x0ereplication_id\x18\x03 \x01(\tB\x03\xe0\x41\x02\"S\n\x18\x44\x65leteReplicationRequest\x12\x37\n\x04name\x18\x01 \x01(\tB)\xe0\x41\x02\xfa\x41#\n!netapp.googleapis.com/Replication\"\x8f\x01\n\x18UpdateReplicationRequest\x12\x34\n\x0bupdate_mask\x18\x01 \x01(\x0b\x32\x1a.google.protobuf.FieldMaskB\x03\xe0\x41\x02\x12=\n\x0breplication\x18\x02 \x01(\x0b\x32#.google.cloud.netapp.v1.ReplicationB\x03\xe0\x41\x02\"`\n\x16StopReplicationRequest\x12\x37\n\x04name\x18\x01 \x01(\tB)\xe0\x41\x02\xfa\x41#\n!netapp.googleapis.com/Replication\x12\r\n\x05\x66orce\x18\x02 \x01(\x08\"S\n\x18ResumeReplicationRequest\x12\x37\n\x04name\x18\x01 \x01(\tB)\xe0\x41\x02\xfa\x41#\n!netapp.googleapis.com/Replication\"]\n\"ReverseReplicationDirectionRequest\x12\x37\n\x04name\x18\x01 \x01(\tB)\xe0\x41\x02\xfa\x41#\n!netapp.googleapis.com/Replication\"\xcd\x01\n\x17\x45stablishPeeringRequest\x12\x37\n\x04name\x18\x01 \x01(\tB)\xe0\x41\x02\xfa\x41#\n!netapp.googleapis.com/Replication\x12\x1e\n\x11peer_cluster_name\x18\x02 \x01(\tB\x03\xe0\x41\x02\x12\x1a\n\rpeer_svm_name\x18\x03 \x01(\tB\x03\xe0\x41\x02\x12\x1e\n\x11peer_ip_addresses\x18\x04 \x03(\tB\x03\xe0\x41\x01\x12\x1d\n\x10peer_volume_name\x18\x05 \x01(\tB\x03\xe0\x41\x02\"Q\n\x16SyncReplicationRequest\x12\x37\n\x04name\x18\x01 \x01(\tB)\xe0\x41\x02\xfa\x41#\n!netapp.googleapis.com/ReplicationB\xb2\x01\n\x1a\x63om.google.cloud.netapp.v1B\x10ReplicationProtoP\x01Z2cloud.google.com/go/netapp/apiv1/netapppb;netapppb\xaa\x02\x16Google.Cloud.NetApp.V1\xca\x02\x16Google\\Cloud\\NetApp\\V1\xea\x02\x19Google::Cloud::NetApp::V1b\x06proto3"

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
    ["google.protobuf.Duration", "google/protobuf/duration.proto"],
    ["google.protobuf.Timestamp", "google/protobuf/timestamp.proto"],
    ["google.cloud.netapp.v1.TieringPolicy", "google/cloud/netapp/v1/volume.proto"],
    ["google.protobuf.FieldMask", "google/protobuf/field_mask.proto"],
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
    module NetApp
      module V1
        TransferStats = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.netapp.v1.TransferStats").msgclass
        Replication = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.netapp.v1.Replication").msgclass
        Replication::State = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.netapp.v1.Replication.State").enummodule
        Replication::ReplicationRole = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.netapp.v1.Replication.ReplicationRole").enummodule
        Replication::ReplicationSchedule = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.netapp.v1.Replication.ReplicationSchedule").enummodule
        Replication::MirrorState = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.netapp.v1.Replication.MirrorState").enummodule
        Replication::HybridReplicationType = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.netapp.v1.Replication.HybridReplicationType").enummodule
        HybridPeeringDetails = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.netapp.v1.HybridPeeringDetails").msgclass
        ListReplicationsRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.netapp.v1.ListReplicationsRequest").msgclass
        ListReplicationsResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.netapp.v1.ListReplicationsResponse").msgclass
        GetReplicationRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.netapp.v1.GetReplicationRequest").msgclass
        DestinationVolumeParameters = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.netapp.v1.DestinationVolumeParameters").msgclass
        CreateReplicationRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.netapp.v1.CreateReplicationRequest").msgclass
        DeleteReplicationRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.netapp.v1.DeleteReplicationRequest").msgclass
        UpdateReplicationRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.netapp.v1.UpdateReplicationRequest").msgclass
        StopReplicationRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.netapp.v1.StopReplicationRequest").msgclass
        ResumeReplicationRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.netapp.v1.ResumeReplicationRequest").msgclass
        ReverseReplicationDirectionRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.netapp.v1.ReverseReplicationDirectionRequest").msgclass
        EstablishPeeringRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.netapp.v1.EstablishPeeringRequest").msgclass
        SyncReplicationRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.netapp.v1.SyncReplicationRequest").msgclass
      end
    end
  end
end
