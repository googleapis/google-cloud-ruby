# frozen_string_literal: true

# Copyright 2025 Google LLC
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


module Google
  module Cloud
    module PubSub
      module V1
        module SubscriptionAdmin
          # Path helper methods for the SubscriptionAdmin API.
          module Paths
            ##
            # Create a fully-qualified Project resource string.
            #
            # The resource will be in the following format:
            #
            # `projects/{project}`
            #
            # @param project [String]
            #
            # @return [::String]
            def project_path project:
              "projects/#{project}"
            end

            ##
            # Create a fully-qualified Snapshot resource string.
            #
            # The resource will be in the following format:
            #
            # `projects/{project}/snapshots/{snapshot}`
            #
            # @param project [String]
            # @param snapshot [String]
            #
            # @return [::String]
            def snapshot_path project:, snapshot:
              raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"

              "projects/#{project}/snapshots/#{snapshot}"
            end

            ##
            # Create a fully-qualified Subscription resource string.
            #
            # The resource will be in the following format:
            #
            # `projects/{project}/subscriptions/{subscription}`
            #
            # @param project [String]
            # @param subscription [String]
            #
            # @return [::String]
            def subscription_path project:, subscription:
              raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"

              "projects/#{project}/subscriptions/#{subscription}"
            end

            ##
            # Create a fully-qualified Topic resource string.
            #
            # @overload topic_path(project:, topic:)
            #   The resource will be in the following format:
            #
            #   `projects/{project}/topics/{topic}`
            #
            #   @param project [String]
            #   @param topic [String]
            #
            # @overload topic_path()
            #   The resource will be in the following format:
            #
            #   `_deleted-topic_`
            #
            # @return [::String]
            def topic_path **args
              resources = {
                "project:topic" => (proc do |project:, topic:|
                  raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"

                  "projects/#{project}/topics/#{topic}"
                end),
                "" => (proc do
                  "_deleted-topic_"
                end)
              }

              resource = resources[args.keys.sort.join(":")]
              raise ::ArgumentError, "no resource found for values #{args.keys}" if resource.nil?
              resource.call(**args)
            end

            extend self
          end
        end
      end
    end
  end
end
