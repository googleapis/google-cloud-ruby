# frozen_string_literal: true
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: google/devtools/clouddebugger/v2/debugger.proto

require 'google/protobuf'

require 'google/api/client_pb'
require 'google/api/field_behavior_pb'
require 'google/devtools/clouddebugger/v2/data_pb'
require 'google/protobuf/empty_pb'
require 'google/api/annotations_pb'


descriptor_data = "\n/google/devtools/clouddebugger/v2/debugger.proto\x12 google.devtools.clouddebugger.v2\x1a\x17google/api/client.proto\x1a\x1fgoogle/api/field_behavior.proto\x1a+google/devtools/clouddebugger/v2/data.proto\x1a\x1bgoogle/protobuf/empty.proto\x1a\x1cgoogle/api/annotations.proto\"\x94\x01\n\x14SetBreakpointRequest\x12\x18\n\x0b\x64\x65\x62uggee_id\x18\x01 \x01(\tB\x03\xe0\x41\x02\x12\x45\n\nbreakpoint\x18\x02 \x01(\x0b\x32,.google.devtools.clouddebugger.v2.BreakpointB\x03\xe0\x41\x02\x12\x1b\n\x0e\x63lient_version\x18\x04 \x01(\tB\x03\xe0\x41\x02\"Y\n\x15SetBreakpointResponse\x12@\n\nbreakpoint\x18\x01 \x01(\x0b\x32,.google.devtools.clouddebugger.v2.Breakpoint\"i\n\x14GetBreakpointRequest\x12\x18\n\x0b\x64\x65\x62uggee_id\x18\x01 \x01(\tB\x03\xe0\x41\x02\x12\x1a\n\rbreakpoint_id\x18\x02 \x01(\tB\x03\xe0\x41\x02\x12\x1b\n\x0e\x63lient_version\x18\x04 \x01(\tB\x03\xe0\x41\x02\"Y\n\x15GetBreakpointResponse\x12@\n\nbreakpoint\x18\x01 \x01(\x0b\x32,.google.devtools.clouddebugger.v2.Breakpoint\"l\n\x17\x44\x65leteBreakpointRequest\x12\x18\n\x0b\x64\x65\x62uggee_id\x18\x01 \x01(\tB\x03\xe0\x41\x02\x12\x1a\n\rbreakpoint_id\x18\x02 \x01(\tB\x03\xe0\x41\x02\x12\x1b\n\x0e\x63lient_version\x18\x03 \x01(\tB\x03\xe0\x41\x02\"\xf0\x02\n\x16ListBreakpointsRequest\x12\x18\n\x0b\x64\x65\x62uggee_id\x18\x01 \x01(\tB\x03\xe0\x41\x02\x12\x19\n\x11include_all_users\x18\x02 \x01(\x08\x12\x18\n\x10include_inactive\x18\x03 \x01(\x08\x12^\n\x06\x61\x63tion\x18\x04 \x01(\x0b\x32N.google.devtools.clouddebugger.v2.ListBreakpointsRequest.BreakpointActionValue\x12\x19\n\rstrip_results\x18\x05 \x01(\x08\x42\x02\x18\x01\x12\x12\n\nwait_token\x18\x06 \x01(\t\x12\x1b\n\x0e\x63lient_version\x18\x08 \x01(\tB\x03\xe0\x41\x02\x1a[\n\x15\x42reakpointActionValue\x12\x42\n\x05value\x18\x01 \x01(\x0e\x32\x33.google.devtools.clouddebugger.v2.Breakpoint.Action\"u\n\x17ListBreakpointsResponse\x12\x41\n\x0b\x62reakpoints\x18\x01 \x03(\x0b\x32,.google.devtools.clouddebugger.v2.Breakpoint\x12\x17\n\x0fnext_wait_token\x18\x02 \x01(\t\"c\n\x14ListDebuggeesRequest\x12\x14\n\x07project\x18\x02 \x01(\tB\x03\xe0\x41\x02\x12\x18\n\x10include_inactive\x18\x03 \x01(\x08\x12\x1b\n\x0e\x63lient_version\x18\x04 \x01(\tB\x03\xe0\x41\x02\"V\n\x15ListDebuggeesResponse\x12=\n\tdebuggees\x18\x01 \x03(\x0b\x32*.google.devtools.clouddebugger.v2.Debuggee2\xf2\t\n\tDebugger2\x12\xf2\x01\n\rSetBreakpoint\x12\x36.google.devtools.clouddebugger.v2.SetBreakpointRequest\x1a\x37.google.devtools.clouddebugger.v2.SetBreakpointResponse\"p\x82\xd3\xe4\x93\x02\x42\"4/v2/debugger/debuggees/{debuggee_id}/breakpoints/set:\nbreakpoint\xda\x41%debuggee_id,breakpoint,client_version\x12\xf5\x01\n\rGetBreakpoint\x12\x36.google.devtools.clouddebugger.v2.GetBreakpointRequest\x1a\x37.google.devtools.clouddebugger.v2.GetBreakpointResponse\"s\x82\xd3\xe4\x93\x02\x42\x12@/v2/debugger/debuggees/{debuggee_id}/breakpoints/{breakpoint_id}\xda\x41(debuggee_id,breakpoint_id,client_version\x12\xda\x01\n\x10\x44\x65leteBreakpoint\x12\x39.google.devtools.clouddebugger.v2.DeleteBreakpointRequest\x1a\x16.google.protobuf.Empty\"s\x82\xd3\xe4\x93\x02\x42*@/v2/debugger/debuggees/{debuggee_id}/breakpoints/{breakpoint_id}\xda\x41(debuggee_id,breakpoint_id,client_version\x12\xdd\x01\n\x0fListBreakpoints\x12\x38.google.devtools.clouddebugger.v2.ListBreakpointsRequest\x1a\x39.google.devtools.clouddebugger.v2.ListBreakpointsResponse\"U\x82\xd3\xe4\x93\x02\x32\x12\x30/v2/debugger/debuggees/{debuggee_id}/breakpoints\xda\x41\x1a\x64\x65\x62uggee_id,client_version\x12\xb9\x01\n\rListDebuggees\x12\x36.google.devtools.clouddebugger.v2.ListDebuggeesRequest\x1a\x37.google.devtools.clouddebugger.v2.ListDebuggeesResponse\"7\x82\xd3\xe4\x93\x02\x18\x12\x16/v2/debugger/debuggees\xda\x41\x16project,client_version\x1a\x7f\xca\x41\x1c\x63louddebugger.googleapis.com\xd2\x41]https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/cloud_debuggerB\xc5\x01\n$com.google.devtools.clouddebugger.v2B\rDebuggerProtoP\x01Z8cloud.google.com/go/debugger/apiv2/debuggerpb;debuggerpb\xaa\x02\x18Google.Cloud.Debugger.V2\xca\x02\x18Google\\Cloud\\Debugger\\V2\xea\x02\x1bGoogle::Cloud::Debugger::V2b\x06proto3"

pool = Google::Protobuf::DescriptorPool.generated_pool

begin
  pool.add_serialized_file(descriptor_data)
rescue TypeError => e
  # Compatibility code: will be removed in the next major version.
  require 'google/protobuf/descriptor_pb'
  parsed = Google::Protobuf::FileDescriptorProto.decode(descriptor_data)
  parsed.clear_dependency
  serialized = parsed.class.encode(parsed)
  file = pool.add_serialized_file(serialized)
  warn "Warning: Protobuf detected an import path issue while loading generated file #{__FILE__}"
  imports = [
    ["google.devtools.clouddebugger.v2.Breakpoint", "google/devtools/clouddebugger/v2/data.proto"],
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
    module Debugger
      module V2
        SetBreakpointRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.devtools.clouddebugger.v2.SetBreakpointRequest").msgclass
        SetBreakpointResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.devtools.clouddebugger.v2.SetBreakpointResponse").msgclass
        GetBreakpointRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.devtools.clouddebugger.v2.GetBreakpointRequest").msgclass
        GetBreakpointResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.devtools.clouddebugger.v2.GetBreakpointResponse").msgclass
        DeleteBreakpointRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.devtools.clouddebugger.v2.DeleteBreakpointRequest").msgclass
        ListBreakpointsRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.devtools.clouddebugger.v2.ListBreakpointsRequest").msgclass
        ListBreakpointsRequest::BreakpointActionValue = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.devtools.clouddebugger.v2.ListBreakpointsRequest.BreakpointActionValue").msgclass
        ListBreakpointsResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.devtools.clouddebugger.v2.ListBreakpointsResponse").msgclass
        ListDebuggeesRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.devtools.clouddebugger.v2.ListDebuggeesRequest").msgclass
        ListDebuggeesResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.devtools.clouddebugger.v2.ListDebuggeesResponse").msgclass
      end
    end
  end
end
