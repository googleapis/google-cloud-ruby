# frozen_string_literal: true

# Copyright 2021 Google LLC
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

# Auto-generated by gapic-generator-ruby. DO NOT EDIT!

require "gapic/common"
require "gapic/config"
require "gapic/config/method"

require "google/cloud/apigee_connect/v1/version"

require "google/cloud/apigee_connect/v1/tether/credentials"
require "google/cloud/apigee_connect/v1/tether/client"

module Google
  module Cloud
    module ApigeeConnect
      module V1
        ##
        # Tether provides a way for the control plane to send HTTP API requests to
        # services in data planes that runs in a remote datacenter without
        # requiring customers to open firewalls on their runtime plane.
        #
        # @example Load this service and instantiate a gRPC client
        #
        #     require "google/cloud/apigee_connect/v1/tether"
        #     client = ::Google::Cloud::ApigeeConnect::V1::Tether::Client.new
        #
        module Tether
        end
      end
    end
  end
end

helper_path = ::File.join __dir__, "tether", "helpers.rb"
require "google/cloud/apigee_connect/v1/tether/helpers" if ::File.file? helper_path
