# frozen_string_literal: true

# Copyright 2023 Google LLC
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

require "gapic/rest"
require "gapic/config"
require "gapic/config/method"

require "google/cloud/policy_simulator/v1/version"

require "google/cloud/policy_simulator/v1/simulator/credentials"
require "google/cloud/policy_simulator/v1/simulator/paths"
require "google/cloud/policy_simulator/v1/simulator/rest/operations"
require "google/cloud/policy_simulator/v1/simulator/rest/client"

module Google
  module Cloud
    module PolicySimulator
      module V1
        ##
        # Policy Simulator API service.
        #
        # Policy Simulator is a collection of endpoints for creating, running, and
        # viewing a {::Google::Cloud::PolicySimulator::V1::Replay Replay}. A
        # {::Google::Cloud::PolicySimulator::V1::Replay Replay} is a type of simulation that
        # lets you see how your principals' access to resources might change if you
        # changed your IAM policy.
        #
        # During a {::Google::Cloud::PolicySimulator::V1::Replay Replay}, Policy Simulator
        # re-evaluates, or replays, past access attempts under both the current policy
        # and  your proposed policy, and compares those results to determine how your
        # principals' access might change under the proposed policy.
        #
        # To load this service and instantiate a REST client:
        #
        #     require "google/cloud/policy_simulator/v1/simulator/rest"
        #     client = ::Google::Cloud::PolicySimulator::V1::Simulator::Rest::Client.new
        #
        module Simulator
          # Client for the REST transport
          module Rest
          end
        end
      end
    end
  end
end

helper_path = ::File.join __dir__, "rest", "helpers.rb"
require "google/cloud/policy_simulator/v1/simulator/rest/helpers" if ::File.file? helper_path
