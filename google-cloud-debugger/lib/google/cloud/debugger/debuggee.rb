# Copyright 2017 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "digest/sha1"
require "google/cloud/debugger/debuggee/app_uniquifier_generator"
require "google/cloud/debugger/version"
require "json"

module Google
  module Cloud
    module Debugger
      class Debuggee
        attr_reader :service
        attr_reader :module_name
        attr_reader :module_version
        attr_reader :id

        def initialize service, module_name: , module_version:
          @service = service
          @module_name = module_name
          @module_version = module_version
          @computed_uniquifier = nil
          @id = nil
        end

        def register
          begin
            response = service.register_debuggee to_grpc
            @id = response.debuggee.id
          rescue
            revoke_registration
          end
          !!id
        end

        def registered?
          !!id
        end

        def revoke_registration
          @id = nil
        end

        private
        def build_request_arg
          debuggee_args = {
            project: project_id,
            description: description,
            labels: labels,
            agent_version: agent_version
          }

          source_context = read_app_json_file "source-context.json"
          debuggee_args[:source_contexts] = [source_context] if source_context

          source_contexts = read_app_json_file "source-contexts.json"
          if source_contexts
            debuggee_args[:ext_source_contexts] = source_contexts
          elsif source_context
            debuggee_args[:ext_source_contexts] = [{context: source_context}]
          end

          debuggee_args[:uniquifier] = compute_uniquifier debuggee_args

          debuggee_args
        end

        def to_grpc
          debuggee_args = build_request_arg

          grpc = Google::Devtools::Clouddebugger::V2::Debuggee.decode_json \
            debuggee_args.to_json

          grpc
        end

        def labels
          {
            "projectid" => String(project_id),
            "module" => String(module_name),
            "version" => String(module_version)
          }
        end

        def description
          "#{module_name}-#{module_version}"
        end

        def project_id
          service.project
        end

        def agent_version
          "google.com/ruby#{RUBY_VERSION}-#{Google::Cloud::Debugger::VERSION}"
        end

        def compute_uniquifier debuggee_args
          return @computed_uniquifier if @computed_uniquifier

          sha = Digest::SHA1.new
          sha << debuggee_args.to_s

          unless debuggee_args.key?(:source_contexts) ||
                 debuggee_args.key?(:ext_source_contexts)
            AppUniquifierGenerator.generate_app_uniquifier sha
          end

          @computed_uniquifier = sha.hexdigest
        end

        def read_app_json_file file_path
          begin
            JSON.parse File.read(file_path), {:symbolize_names => true}
          rescue
            nil
          end
        end
      end
    end
  end
end

