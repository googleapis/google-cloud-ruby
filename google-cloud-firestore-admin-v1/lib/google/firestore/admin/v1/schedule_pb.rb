# frozen_string_literal: true
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: google/firestore/admin/v1/schedule.proto

require 'google/protobuf'

require 'google/api/field_behavior_pb'
require 'google/api/resource_pb'
require 'google/protobuf/duration_pb'
require 'google/protobuf/timestamp_pb'
require 'google/type/dayofweek_pb'


descriptor_data = "\n(google/firestore/admin/v1/schedule.proto\x12\x19google.firestore.admin.v1\x1a\x1fgoogle/api/field_behavior.proto\x1a\x19google/api/resource.proto\x1a\x1egoogle/protobuf/duration.proto\x1a\x1fgoogle/protobuf/timestamp.proto\x1a\x1bgoogle/type/dayofweek.proto\"\xd6\x03\n\x0e\x42\x61\x63kupSchedule\x12\x11\n\x04name\x18\x01 \x01(\tB\x03\xe0\x41\x03\x12\x34\n\x0b\x63reate_time\x18\x03 \x01(\x0b\x32\x1a.google.protobuf.TimestampB\x03\xe0\x41\x03\x12\x34\n\x0bupdate_time\x18\n \x01(\x0b\x32\x1a.google.protobuf.TimestampB\x03\xe0\x41\x03\x12,\n\tretention\x18\x06 \x01(\x0b\x32\x19.google.protobuf.Duration\x12\x46\n\x10\x64\x61ily_recurrence\x18\x07 \x01(\x0b\x32*.google.firestore.admin.v1.DailyRecurrenceH\x00\x12H\n\x11weekly_recurrence\x18\x08 \x01(\x0b\x32+.google.firestore.admin.v1.WeeklyRecurrenceH\x00:w\xea\x41t\n\'firestore.googleapis.com/BackupSchedule\x12Iprojects/{project}/databases/{database}/backupSchedules/{backup_schedule}B\x0c\n\nrecurrence\"\x11\n\x0f\x44\x61ilyRecurrence\"7\n\x10WeeklyRecurrence\x12#\n\x03\x64\x61y\x18\x02 \x01(\x0e\x32\x16.google.type.DayOfWeekB\xdc\x01\n\x1d\x63om.google.firestore.admin.v1B\rScheduleProtoP\x01Z9cloud.google.com/go/firestore/apiv1/admin/adminpb;adminpb\xa2\x02\x04GCFS\xaa\x02\x1fGoogle.Cloud.Firestore.Admin.V1\xca\x02\x1fGoogle\\Cloud\\Firestore\\Admin\\V1\xea\x02#Google::Cloud::Firestore::Admin::V1b\x06proto3"

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
    ["google.protobuf.Duration", "google/protobuf/duration.proto"],
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
    module Firestore
      module Admin
        module V1
          BackupSchedule = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.firestore.admin.v1.BackupSchedule").msgclass
          DailyRecurrence = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.firestore.admin.v1.DailyRecurrence").msgclass
          WeeklyRecurrence = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.firestore.admin.v1.WeeklyRecurrence").msgclass
        end
      end
    end
  end
end
