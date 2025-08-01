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
    module DiscoveryEngine
      module V1
        module SessionService
          # Path helper methods for the SessionService API.
          module Paths
            ##
            # Create a fully-qualified Answer resource string.
            #
            # @overload answer_path(project:, location:, data_store:, session:, answer:)
            #   The resource will be in the following format:
            #
            #   `projects/{project}/locations/{location}/dataStores/{data_store}/sessions/{session}/answers/{answer}`
            #
            #   @param project [String]
            #   @param location [String]
            #   @param data_store [String]
            #   @param session [String]
            #   @param answer [String]
            #
            # @overload answer_path(project:, location:, collection:, data_store:, session:, answer:)
            #   The resource will be in the following format:
            #
            #   `projects/{project}/locations/{location}/collections/{collection}/dataStores/{data_store}/sessions/{session}/answers/{answer}`
            #
            #   @param project [String]
            #   @param location [String]
            #   @param collection [String]
            #   @param data_store [String]
            #   @param session [String]
            #   @param answer [String]
            #
            # @overload answer_path(project:, location:, collection:, engine:, session:, answer:)
            #   The resource will be in the following format:
            #
            #   `projects/{project}/locations/{location}/collections/{collection}/engines/{engine}/sessions/{session}/answers/{answer}`
            #
            #   @param project [String]
            #   @param location [String]
            #   @param collection [String]
            #   @param engine [String]
            #   @param session [String]
            #   @param answer [String]
            #
            # @return [::String]
            def answer_path **args
              resources = {
                "answer:data_store:location:project:session" => (proc do |project:, location:, data_store:, session:, answer:|
                  raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
                  raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"
                  raise ::ArgumentError, "data_store cannot contain /" if data_store.to_s.include? "/"
                  raise ::ArgumentError, "session cannot contain /" if session.to_s.include? "/"

                  "projects/#{project}/locations/#{location}/dataStores/#{data_store}/sessions/#{session}/answers/#{answer}"
                end),
                "answer:collection:data_store:location:project:session" => (proc do |project:, location:, collection:, data_store:, session:, answer:|
                  raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
                  raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"
                  raise ::ArgumentError, "collection cannot contain /" if collection.to_s.include? "/"
                  raise ::ArgumentError, "data_store cannot contain /" if data_store.to_s.include? "/"
                  raise ::ArgumentError, "session cannot contain /" if session.to_s.include? "/"

                  "projects/#{project}/locations/#{location}/collections/#{collection}/dataStores/#{data_store}/sessions/#{session}/answers/#{answer}"
                end),
                "answer:collection:engine:location:project:session" => (proc do |project:, location:, collection:, engine:, session:, answer:|
                  raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
                  raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"
                  raise ::ArgumentError, "collection cannot contain /" if collection.to_s.include? "/"
                  raise ::ArgumentError, "engine cannot contain /" if engine.to_s.include? "/"
                  raise ::ArgumentError, "session cannot contain /" if session.to_s.include? "/"

                  "projects/#{project}/locations/#{location}/collections/#{collection}/engines/#{engine}/sessions/#{session}/answers/#{answer}"
                end)
              }

              resource = resources[args.keys.sort.join(":")]
              raise ::ArgumentError, "no resource found for values #{args.keys}" if resource.nil?
              resource.call(**args)
            end

            ##
            # Create a fully-qualified Chunk resource string.
            #
            # @overload chunk_path(project:, location:, data_store:, branch:, document:, chunk:)
            #   The resource will be in the following format:
            #
            #   `projects/{project}/locations/{location}/dataStores/{data_store}/branches/{branch}/documents/{document}/chunks/{chunk}`
            #
            #   @param project [String]
            #   @param location [String]
            #   @param data_store [String]
            #   @param branch [String]
            #   @param document [String]
            #   @param chunk [String]
            #
            # @overload chunk_path(project:, location:, collection:, data_store:, branch:, document:, chunk:)
            #   The resource will be in the following format:
            #
            #   `projects/{project}/locations/{location}/collections/{collection}/dataStores/{data_store}/branches/{branch}/documents/{document}/chunks/{chunk}`
            #
            #   @param project [String]
            #   @param location [String]
            #   @param collection [String]
            #   @param data_store [String]
            #   @param branch [String]
            #   @param document [String]
            #   @param chunk [String]
            #
            # @return [::String]
            def chunk_path **args
              resources = {
                "branch:chunk:data_store:document:location:project" => (proc do |project:, location:, data_store:, branch:, document:, chunk:|
                  raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
                  raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"
                  raise ::ArgumentError, "data_store cannot contain /" if data_store.to_s.include? "/"
                  raise ::ArgumentError, "branch cannot contain /" if branch.to_s.include? "/"
                  raise ::ArgumentError, "document cannot contain /" if document.to_s.include? "/"

                  "projects/#{project}/locations/#{location}/dataStores/#{data_store}/branches/#{branch}/documents/#{document}/chunks/#{chunk}"
                end),
                "branch:chunk:collection:data_store:document:location:project" => (proc do |project:, location:, collection:, data_store:, branch:, document:, chunk:|
                  raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
                  raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"
                  raise ::ArgumentError, "collection cannot contain /" if collection.to_s.include? "/"
                  raise ::ArgumentError, "data_store cannot contain /" if data_store.to_s.include? "/"
                  raise ::ArgumentError, "branch cannot contain /" if branch.to_s.include? "/"
                  raise ::ArgumentError, "document cannot contain /" if document.to_s.include? "/"

                  "projects/#{project}/locations/#{location}/collections/#{collection}/dataStores/#{data_store}/branches/#{branch}/documents/#{document}/chunks/#{chunk}"
                end)
              }

              resource = resources[args.keys.sort.join(":")]
              raise ::ArgumentError, "no resource found for values #{args.keys}" if resource.nil?
              resource.call(**args)
            end

            ##
            # Create a fully-qualified DataStore resource string.
            #
            # @overload data_store_path(project:, location:, data_store:)
            #   The resource will be in the following format:
            #
            #   `projects/{project}/locations/{location}/dataStores/{data_store}`
            #
            #   @param project [String]
            #   @param location [String]
            #   @param data_store [String]
            #
            # @overload data_store_path(project:, location:, collection:, data_store:)
            #   The resource will be in the following format:
            #
            #   `projects/{project}/locations/{location}/collections/{collection}/dataStores/{data_store}`
            #
            #   @param project [String]
            #   @param location [String]
            #   @param collection [String]
            #   @param data_store [String]
            #
            # @return [::String]
            def data_store_path **args
              resources = {
                "data_store:location:project" => (proc do |project:, location:, data_store:|
                  raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
                  raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"

                  "projects/#{project}/locations/#{location}/dataStores/#{data_store}"
                end),
                "collection:data_store:location:project" => (proc do |project:, location:, collection:, data_store:|
                  raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
                  raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"
                  raise ::ArgumentError, "collection cannot contain /" if collection.to_s.include? "/"

                  "projects/#{project}/locations/#{location}/collections/#{collection}/dataStores/#{data_store}"
                end)
              }

              resource = resources[args.keys.sort.join(":")]
              raise ::ArgumentError, "no resource found for values #{args.keys}" if resource.nil?
              resource.call(**args)
            end

            ##
            # Create a fully-qualified Document resource string.
            #
            # @overload document_path(project:, location:, data_store:, branch:, document:)
            #   The resource will be in the following format:
            #
            #   `projects/{project}/locations/{location}/dataStores/{data_store}/branches/{branch}/documents/{document}`
            #
            #   @param project [String]
            #   @param location [String]
            #   @param data_store [String]
            #   @param branch [String]
            #   @param document [String]
            #
            # @overload document_path(project:, location:, collection:, data_store:, branch:, document:)
            #   The resource will be in the following format:
            #
            #   `projects/{project}/locations/{location}/collections/{collection}/dataStores/{data_store}/branches/{branch}/documents/{document}`
            #
            #   @param project [String]
            #   @param location [String]
            #   @param collection [String]
            #   @param data_store [String]
            #   @param branch [String]
            #   @param document [String]
            #
            # @return [::String]
            def document_path **args
              resources = {
                "branch:data_store:document:location:project" => (proc do |project:, location:, data_store:, branch:, document:|
                  raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
                  raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"
                  raise ::ArgumentError, "data_store cannot contain /" if data_store.to_s.include? "/"
                  raise ::ArgumentError, "branch cannot contain /" if branch.to_s.include? "/"

                  "projects/#{project}/locations/#{location}/dataStores/#{data_store}/branches/#{branch}/documents/#{document}"
                end),
                "branch:collection:data_store:document:location:project" => (proc do |project:, location:, collection:, data_store:, branch:, document:|
                  raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
                  raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"
                  raise ::ArgumentError, "collection cannot contain /" if collection.to_s.include? "/"
                  raise ::ArgumentError, "data_store cannot contain /" if data_store.to_s.include? "/"
                  raise ::ArgumentError, "branch cannot contain /" if branch.to_s.include? "/"

                  "projects/#{project}/locations/#{location}/collections/#{collection}/dataStores/#{data_store}/branches/#{branch}/documents/#{document}"
                end)
              }

              resource = resources[args.keys.sort.join(":")]
              raise ::ArgumentError, "no resource found for values #{args.keys}" if resource.nil?
              resource.call(**args)
            end

            ##
            # Create a fully-qualified Session resource string.
            #
            # @overload session_path(project:, location:, data_store:, session:)
            #   The resource will be in the following format:
            #
            #   `projects/{project}/locations/{location}/dataStores/{data_store}/sessions/{session}`
            #
            #   @param project [String]
            #   @param location [String]
            #   @param data_store [String]
            #   @param session [String]
            #
            # @overload session_path(project:, location:, collection:, data_store:, session:)
            #   The resource will be in the following format:
            #
            #   `projects/{project}/locations/{location}/collections/{collection}/dataStores/{data_store}/sessions/{session}`
            #
            #   @param project [String]
            #   @param location [String]
            #   @param collection [String]
            #   @param data_store [String]
            #   @param session [String]
            #
            # @overload session_path(project:, location:, collection:, engine:, session:)
            #   The resource will be in the following format:
            #
            #   `projects/{project}/locations/{location}/collections/{collection}/engines/{engine}/sessions/{session}`
            #
            #   @param project [String]
            #   @param location [String]
            #   @param collection [String]
            #   @param engine [String]
            #   @param session [String]
            #
            # @return [::String]
            def session_path **args
              resources = {
                "data_store:location:project:session" => (proc do |project:, location:, data_store:, session:|
                  raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
                  raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"
                  raise ::ArgumentError, "data_store cannot contain /" if data_store.to_s.include? "/"

                  "projects/#{project}/locations/#{location}/dataStores/#{data_store}/sessions/#{session}"
                end),
                "collection:data_store:location:project:session" => (proc do |project:, location:, collection:, data_store:, session:|
                  raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
                  raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"
                  raise ::ArgumentError, "collection cannot contain /" if collection.to_s.include? "/"
                  raise ::ArgumentError, "data_store cannot contain /" if data_store.to_s.include? "/"

                  "projects/#{project}/locations/#{location}/collections/#{collection}/dataStores/#{data_store}/sessions/#{session}"
                end),
                "collection:engine:location:project:session" => (proc do |project:, location:, collection:, engine:, session:|
                  raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
                  raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"
                  raise ::ArgumentError, "collection cannot contain /" if collection.to_s.include? "/"
                  raise ::ArgumentError, "engine cannot contain /" if engine.to_s.include? "/"

                  "projects/#{project}/locations/#{location}/collections/#{collection}/engines/#{engine}/sessions/#{session}"
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
