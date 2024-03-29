# frozen_string_literal: true
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: google/cloud/cloudcontrolspartner/v1beta/customer_workloads.proto

require 'google/protobuf'

require 'google/api/field_behavior_pb'
require 'google/api/resource_pb'
require 'google/cloud/cloudcontrolspartner/v1beta/completion_state_pb'
require 'google/protobuf/timestamp_pb'


descriptor_data = "\nAgoogle/cloud/cloudcontrolspartner/v1beta/customer_workloads.proto\x12(google.cloud.cloudcontrolspartner.v1beta\x1a\x1fgoogle/api/field_behavior.proto\x1a\x19google/api/resource.proto\x1a?google/cloud/cloudcontrolspartner/v1beta/completion_state.proto\x1a\x1fgoogle/protobuf/timestamp.proto\"\xca\x06\n\x08Workload\x12\x11\n\x04name\x18\x01 \x01(\tB\x03\xe0\x41\x08\x12\x16\n\tfolder_id\x18\x02 \x01(\x03\x42\x03\xe0\x41\x03\x12\x34\n\x0b\x63reate_time\x18\x03 \x01(\x0b\x32\x1a.google.protobuf.TimestampB\x03\xe0\x41\x03\x12\x13\n\x06\x66older\x18\x04 \x01(\tB\x03\xe0\x41\x03\x12\x64\n\x19workload_onboarding_state\x18\x05 \x01(\x0b\x32\x41.google.cloud.cloudcontrolspartner.v1beta.WorkloadOnboardingState\x12\x14\n\x0cis_onboarded\x18\x06 \x01(\x08\x12!\n\x19key_management_project_id\x18\x07 \x01(\t\x12\x10\n\x08location\x18\x08 \x01(\t\x12K\n\x07partner\x18\t \x01(\x0e\x32:.google.cloud.cloudcontrolspartner.v1beta.Workload.Partner\"\xa2\x02\n\x07Partner\x12\x17\n\x13PARTNER_UNSPECIFIED\x10\x00\x12\"\n\x1ePARTNER_LOCAL_CONTROLS_BY_S3NS\x10\x01\x12+\n\'PARTNER_SOVEREIGN_CONTROLS_BY_T_SYSTEMS\x10\x02\x12-\n)PARTNER_SOVEREIGN_CONTROLS_BY_SIA_MINSAIT\x10\x03\x12%\n!PARTNER_SOVEREIGN_CONTROLS_BY_PSN\x10\x04\x12\'\n#PARTNER_SOVEREIGN_CONTROLS_BY_CNTXT\x10\x06\x12.\n*PARTNER_SOVEREIGN_CONTROLS_BY_CNTXT_NO_EKM\x10\x07:\xa4\x01\xea\x41\xa0\x01\n,cloudcontrolspartner.googleapis.com/Workload\x12[organizations/{organization}/locations/{location}/customers/{customer}/workloads/{workload}*\tworkloads2\x08workload\"\xaf\x01\n\x14ListWorkloadsRequest\x12\x44\n\x06parent\x18\x01 \x01(\tB4\xe0\x41\x02\xfa\x41.\x12,cloudcontrolspartner.googleapis.com/Workload\x12\x11\n\tpage_size\x18\x02 \x01(\x05\x12\x12\n\npage_token\x18\x03 \x01(\t\x12\x13\n\x06\x66ilter\x18\x04 \x01(\tB\x03\xe0\x41\x01\x12\x15\n\x08order_by\x18\x05 \x01(\tB\x03\xe0\x41\x01\"\x8c\x01\n\x15ListWorkloadsResponse\x12\x45\n\tworkloads\x18\x01 \x03(\x0b\x32\x32.google.cloud.cloudcontrolspartner.v1beta.Workload\x12\x17\n\x0fnext_page_token\x18\x02 \x01(\t\x12\x13\n\x0bunreachable\x18\x03 \x03(\t\"X\n\x12GetWorkloadRequest\x12\x42\n\x04name\x18\x01 \x01(\tB4\xe0\x41\x02\xfa\x41.\n,cloudcontrolspartner.googleapis.com/Workload\"u\n\x17WorkloadOnboardingState\x12Z\n\x10onboarding_steps\x18\x01 \x03(\x0b\x32@.google.cloud.cloudcontrolspartner.v1beta.WorkloadOnboardingStep\"\x86\x03\n\x16WorkloadOnboardingStep\x12S\n\x04step\x18\x01 \x01(\x0e\x32\x45.google.cloud.cloudcontrolspartner.v1beta.WorkloadOnboardingStep.Step\x12.\n\nstart_time\x18\x02 \x01(\x0b\x32\x1a.google.protobuf.Timestamp\x12\x33\n\x0f\x63ompletion_time\x18\x03 \x01(\x0b\x32\x1a.google.protobuf.Timestamp\x12X\n\x10\x63ompletion_state\x18\x04 \x01(\x0e\x32\x39.google.cloud.cloudcontrolspartner.v1beta.CompletionStateB\x03\xe0\x41\x03\"X\n\x04Step\x12\x14\n\x10STEP_UNSPECIFIED\x10\x00\x12\x13\n\x0f\x45KM_PROVISIONED\x10\x01\x12%\n!SIGNED_ACCESS_APPROVAL_CONFIGURED\x10\x02\x42\xae\x02\n,com.google.cloud.cloudcontrolspartner.v1betaB\x16\x43ustomerWorkloadsProtoP\x01Z`cloud.google.com/go/cloudcontrolspartner/apiv1beta/cloudcontrolspartnerpb;cloudcontrolspartnerpb\xaa\x02(Google.Cloud.CloudControlsPartner.V1Beta\xca\x02(Google\\Cloud\\CloudControlsPartner\\V1beta\xea\x02+Google::Cloud::CloudControlsPartner::V1betab\x06proto3"

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
    module CloudControlsPartner
      module V1beta
        Workload = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.cloudcontrolspartner.v1beta.Workload").msgclass
        Workload::Partner = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.cloudcontrolspartner.v1beta.Workload.Partner").enummodule
        ListWorkloadsRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.cloudcontrolspartner.v1beta.ListWorkloadsRequest").msgclass
        ListWorkloadsResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.cloudcontrolspartner.v1beta.ListWorkloadsResponse").msgclass
        GetWorkloadRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.cloudcontrolspartner.v1beta.GetWorkloadRequest").msgclass
        WorkloadOnboardingState = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.cloudcontrolspartner.v1beta.WorkloadOnboardingState").msgclass
        WorkloadOnboardingStep = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.cloudcontrolspartner.v1beta.WorkloadOnboardingStep").msgclass
        WorkloadOnboardingStep::Step = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.cloudcontrolspartner.v1beta.WorkloadOnboardingStep.Step").enummodule
      end
    end
  end
end
