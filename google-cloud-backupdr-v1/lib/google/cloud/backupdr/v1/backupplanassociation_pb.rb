# frozen_string_literal: true
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: google/cloud/backupdr/v1/backupplanassociation.proto

require 'google/protobuf'

require 'google/api/field_behavior_pb'
require 'google/api/field_info_pb'
require 'google/api/resource_pb'
require 'google/cloud/backupdr/v1/backupvault_cloudsql_pb'
require 'google/protobuf/field_mask_pb'
require 'google/protobuf/timestamp_pb'
require 'google/rpc/status_pb'


descriptor_data = "\n4google/cloud/backupdr/v1/backupplanassociation.proto\x12\x18google.cloud.backupdr.v1\x1a\x1fgoogle/api/field_behavior.proto\x1a\x1bgoogle/api/field_info.proto\x1a\x19google/api/resource.proto\x1a\x33google/cloud/backupdr/v1/backupvault_cloudsql.proto\x1a google/protobuf/field_mask.proto\x1a\x1fgoogle/protobuf/timestamp.proto\x1a\x17google/rpc/status.proto\"\xdc\x07\n\x15\x42\x61\x63kupPlanAssociation\x12\x14\n\x04name\x18\x01 \x01(\tB\x06\xe0\x41\x08\xe0\x41\x03\x12\x1d\n\rresource_type\x18\x02 \x01(\tB\x06\xe0\x41\x05\xe0\x41\x02\x12\x18\n\x08resource\x18\x03 \x01(\tB\x06\xe0\x41\x05\xe0\x41\x02\x12?\n\x0b\x62\x61\x63kup_plan\x18\x04 \x01(\tB*\xe0\x41\x02\xfa\x41$\n\"backupdr.googleapis.com/BackupPlan\x12\x34\n\x0b\x63reate_time\x18\x05 \x01(\x0b\x32\x1a.google.protobuf.TimestampB\x03\xe0\x41\x03\x12\x34\n\x0bupdate_time\x18\x06 \x01(\x0b\x32\x1a.google.protobuf.TimestampB\x03\xe0\x41\x03\x12I\n\x05state\x18\x07 \x01(\x0e\x32\x35.google.cloud.backupdr.v1.BackupPlanAssociation.StateB\x03\xe0\x41\x03\x12H\n\x11rules_config_info\x18\x08 \x03(\x0b\x32(.google.cloud.backupdr.v1.RuleConfigInfoB\x03\xe0\x41\x03\x12\x18\n\x0b\x64\x61ta_source\x18\t \x01(\tB\x03\xe0\x41\x03\x12\x8f\x01\n5cloud_sql_instance_backup_plan_association_properties\x18\n \x01(\x0b\x32I.google.cloud.backupdr.v1.CloudSqlInstanceBackupPlanAssociationPropertiesB\x03\xe0\x41\x03H\x00\x12$\n\x17\x62\x61\x63kup_plan_revision_id\x18\x0b \x01(\tB\x03\xe0\x41\x03\x12&\n\x19\x62\x61\x63kup_plan_revision_name\x18\x0c \x01(\tB\x03\xe0\x41\x03\"b\n\x05State\x12\x15\n\x11STATE_UNSPECIFIED\x10\x00\x12\x0c\n\x08\x43REATING\x10\x01\x12\n\n\x06\x41\x43TIVE\x10\x02\x12\x0c\n\x08\x44\x45LETING\x10\x03\x12\x0c\n\x08INACTIVE\x10\x04\x12\x0c\n\x08UPDATING\x10\x05:\xbc\x01\xea\x41\xb8\x01\n-backupdr.googleapis.com/BackupPlanAssociation\x12Xprojects/{project}/locations/{location}/backupPlanAssociations/{backup_plan_association}*\x16\x62\x61\x63kupPlanAssociations2\x15\x62\x61\x63kupPlanAssociationB\x15\n\x13resource_properties\"\x89\x03\n\x0eRuleConfigInfo\x12\x14\n\x07rule_id\x18\x01 \x01(\tB\x03\xe0\x41\x03\x12X\n\x11last_backup_state\x18\x03 \x01(\x0e\x32\x38.google.cloud.backupdr.v1.RuleConfigInfo.LastBackupStateB\x03\xe0\x41\x03\x12\x32\n\x11last_backup_error\x18\x04 \x01(\x0b\x32\x12.google.rpc.StatusB\x03\xe0\x41\x03\x12P\n\'last_successful_backup_consistency_time\x18\x05 \x01(\x0b\x32\x1a.google.protobuf.TimestampB\x03\xe0\x41\x03\"\x80\x01\n\x0fLastBackupState\x12!\n\x1dLAST_BACKUP_STATE_UNSPECIFIED\x10\x00\x12\x18\n\x14\x46IRST_BACKUP_PENDING\x10\x01\x12\x15\n\x11PERMISSION_DENIED\x10\x02\x12\r\n\tSUCCEEDED\x10\x03\x12\n\n\x06\x46\x41ILED\x10\x04\"\x8c\x02\n\"CreateBackupPlanAssociationRequest\x12\x45\n\x06parent\x18\x01 \x01(\tB5\xe0\x41\x02\xfa\x41/\x12-backupdr.googleapis.com/BackupPlanAssociation\x12\'\n\x1a\x62\x61\x63kup_plan_association_id\x18\x02 \x01(\tB\x03\xe0\x41\x02\x12U\n\x17\x62\x61\x63kup_plan_association\x18\x03 \x01(\x0b\x32/.google.cloud.backupdr.v1.BackupPlanAssociationB\x03\xe0\x41\x02\x12\x1f\n\nrequest_id\x18\x04 \x01(\tB\x0b\xe0\x41\x01\xe2\x8c\xcf\xd7\x08\x02\x08\x01\"\xb0\x01\n!ListBackupPlanAssociationsRequest\x12\x45\n\x06parent\x18\x01 \x01(\tB5\xe0\x41\x02\xfa\x41/\x12-backupdr.googleapis.com/BackupPlanAssociation\x12\x16\n\tpage_size\x18\x02 \x01(\x05\x42\x03\xe0\x41\x01\x12\x17\n\npage_token\x18\x03 \x01(\tB\x03\xe0\x41\x01\x12\x13\n\x06\x66ilter\x18\x04 \x01(\tB\x03\xe0\x41\x01\"\xa5\x01\n\"ListBackupPlanAssociationsResponse\x12Q\n\x18\x62\x61\x63kup_plan_associations\x18\x01 \x03(\x0b\x32/.google.cloud.backupdr.v1.BackupPlanAssociation\x12\x17\n\x0fnext_page_token\x18\x02 \x01(\t\x12\x13\n\x0bunreachable\x18\x03 \x03(\t\"\xf3\x01\n1FetchBackupPlanAssociationsForResourceTypeRequest\x12\x45\n\x06parent\x18\x01 \x01(\tB5\xe0\x41\x02\xfa\x41/\x12-backupdr.googleapis.com/BackupPlanAssociation\x12\x1a\n\rresource_type\x18\x02 \x01(\tB\x03\xe0\x41\x02\x12\x16\n\tpage_size\x18\x03 \x01(\x05\x42\x03\xe0\x41\x01\x12\x17\n\npage_token\x18\x04 \x01(\tB\x03\xe0\x41\x01\x12\x13\n\x06\x66ilter\x18\x05 \x01(\tB\x03\xe0\x41\x01\x12\x15\n\x08order_by\x18\x06 \x01(\tB\x03\xe0\x41\x01\"\xaa\x01\n2FetchBackupPlanAssociationsForResourceTypeResponse\x12V\n\x18\x62\x61\x63kup_plan_associations\x18\x01 \x03(\x0b\x32/.google.cloud.backupdr.v1.BackupPlanAssociationB\x03\xe0\x41\x03\x12\x1c\n\x0fnext_page_token\x18\x02 \x01(\tB\x03\xe0\x41\x03\"f\n\x1fGetBackupPlanAssociationRequest\x12\x43\n\x04name\x18\x01 \x01(\tB5\xe0\x41\x02\xfa\x41/\n-backupdr.googleapis.com/BackupPlanAssociation\"\x8a\x01\n\"DeleteBackupPlanAssociationRequest\x12\x43\n\x04name\x18\x01 \x01(\tB5\xe0\x41\x02\xfa\x41/\n-backupdr.googleapis.com/BackupPlanAssociation\x12\x1f\n\nrequest_id\x18\x02 \x01(\tB\x0b\xe0\x41\x01\xe2\x8c\xcf\xd7\x08\x02\x08\x01\"\xd2\x01\n\"UpdateBackupPlanAssociationRequest\x12U\n\x17\x62\x61\x63kup_plan_association\x18\x01 \x01(\x0b\x32/.google.cloud.backupdr.v1.BackupPlanAssociationB\x03\xe0\x41\x02\x12\x34\n\x0bupdate_mask\x18\x02 \x01(\x0b\x32\x1a.google.protobuf.FieldMaskB\x03\xe0\x41\x02\x12\x1f\n\nrequest_id\x18\x03 \x01(\tB\x0b\xe0\x41\x01\xe2\x8c\xcf\xd7\x08\x02\x08\x01\"\x92\x01\n\x14TriggerBackupRequest\x12\x43\n\x04name\x18\x01 \x01(\tB5\xe0\x41\x02\xfa\x41/\n-backupdr.googleapis.com/BackupPlanAssociation\x12\x14\n\x07rule_id\x18\x02 \x01(\tB\x03\xe0\x41\x02\x12\x1f\n\nrequest_id\x18\x03 \x01(\tB\x0b\xe0\x41\x01\xe2\x8c\xcf\xd7\x08\x02\x08\x01\x42\xca\x01\n\x1c\x63om.google.cloud.backupdr.v1B\x1a\x42\x61\x63kupPlanAssociationProtoP\x01Z8cloud.google.com/go/backupdr/apiv1/backupdrpb;backupdrpb\xaa\x02\x18Google.Cloud.BackupDR.V1\xca\x02\x18Google\\Cloud\\BackupDR\\V1\xea\x02\x1bGoogle::Cloud::BackupDR::V1b\x06proto3"

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
    ["google.protobuf.Timestamp", "google/protobuf/timestamp.proto"],
    ["google.cloud.backupdr.v1.CloudSqlInstanceBackupPlanAssociationProperties", "google/cloud/backupdr/v1/backupvault_cloudsql.proto"],
    ["google.rpc.Status", "google/rpc/status.proto"],
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
    module BackupDR
      module V1
        BackupPlanAssociation = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.backupdr.v1.BackupPlanAssociation").msgclass
        BackupPlanAssociation::State = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.backupdr.v1.BackupPlanAssociation.State").enummodule
        RuleConfigInfo = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.backupdr.v1.RuleConfigInfo").msgclass
        RuleConfigInfo::LastBackupState = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.backupdr.v1.RuleConfigInfo.LastBackupState").enummodule
        CreateBackupPlanAssociationRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.backupdr.v1.CreateBackupPlanAssociationRequest").msgclass
        ListBackupPlanAssociationsRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.backupdr.v1.ListBackupPlanAssociationsRequest").msgclass
        ListBackupPlanAssociationsResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.backupdr.v1.ListBackupPlanAssociationsResponse").msgclass
        FetchBackupPlanAssociationsForResourceTypeRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.backupdr.v1.FetchBackupPlanAssociationsForResourceTypeRequest").msgclass
        FetchBackupPlanAssociationsForResourceTypeResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.backupdr.v1.FetchBackupPlanAssociationsForResourceTypeResponse").msgclass
        GetBackupPlanAssociationRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.backupdr.v1.GetBackupPlanAssociationRequest").msgclass
        DeleteBackupPlanAssociationRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.backupdr.v1.DeleteBackupPlanAssociationRequest").msgclass
        UpdateBackupPlanAssociationRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.backupdr.v1.UpdateBackupPlanAssociationRequest").msgclass
        TriggerBackupRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.backupdr.v1.TriggerBackupRequest").msgclass
      end
    end
  end
end
