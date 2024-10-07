# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "simplecov"

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "json"
require "google/cloud/errors"
require "grpc/errors"
require "google/rpc/status_pb"

def debug_info
  Google::Rpc::DebugInfo.new detail: "status_detail"
end

def error_info
  Google::Rpc::ErrorInfo.new reason: "ErrorInfo reason", domain: "ErrorInfo domain", metadata: {"foo": "bar"}
end

def localized_message
  Google::Rpc::LocalizedMessage.new locale: "fr-CH", message: "c'est un message d'erreur"
end

def help
  link = Google::Rpc::Help::Link.new description: "example description", url: "https://example.com/error"
  Google::Rpc::Help.new links: [link]
end

def google_rpc_status extended_details: false
  any_debug = Google::Protobuf::Any.new
  any_debug.pack debug_info

  any_message = Google::Protobuf::Any.new
  any_message.pack localized_message

  any_help = Google::Protobuf::Any.new
  any_help.pack help

  status_arr = [any_debug]
  status_arr = [any_debug, any_message, any_help] if extended_details

  Google::Rpc::Status.new details: status_arr
end

def gapic_rest_error status_code:, extended_details: false
  status = google_rpc_status(extended_details: extended_details).to_json
  jp = JSON.parse(status)
  details = jp["details"]

  headers = {"content-type" => "application/json; charset=UTF-8", "content-encoding"=>"gzip"}

  gapic_rest_err = MockGapicRestError.new(
    :status => "err_message for #{status_code}",
    :details => details,
    :status_code => status_code,
    :headers => headers
  )

  gapic_rest_err
end

def wrapped_rest_error gapic_rest_error
  begin
    begin
      raise gapic_rest_error
    rescue => gapic_r_e
      raise Google::Cloud::Error.from_error gapic_r_e
    end
  rescue => e
    return e
  end
end

##
# A truncated copy of gapic-common's GapicRestError that only keeps the 
# parse details decoding implementation.
# Here to avoid referencing gapic-common.
#
class MockGapicRestError < StandardError
  attr_reader :status_code, :status, :details, :headers
  alias status_details details

  def initialize msg = nil
    super
  end

  def initialize status_code:, status:, details:, headers:
    @status_code = status_code
    @status = status
    @msg = status
    @details = parse_details details
    @headers = headers

    super
  end

  ##
  # A copy of implementation from gapic-common's GapicRestError
  #
  def parse_details details
    # For rest errors details will contain json representations of `Protobuf.Any`
    # decoded into hashes. If it's not an array, of its elements are not hashes,
    # it's some other case
    return details unless details.is_a? ::Array
    
    details.map do |detail_instance|
      next detail_instance unless detail_instance.is_a? ::Hash
      # Next, parse detail_instance into a Proto message.
      # There are three possible issues for the JSON->Any->message parsing
      # - json decoding fails
      # - the json belongs to a proto message type we don't know about
      # - any unpacking fails
      # If we hit any of these three issues we'll just return the original hash
      begin
        any = ::Google::Protobuf::Any.decode_json detail_instance.to_json
        klass = ::Google::Protobuf::DescriptorPool.generated_pool.lookup(any.type_name)&.msgclass
        next detail_instance if klass.nil?
        unpack = any.unpack klass
        next detail_instance if unpack.nil?
        unpack
      rescue ::Google::Protobuf::ParseError
        detail_instance
      end
    end.compact
  end
end
