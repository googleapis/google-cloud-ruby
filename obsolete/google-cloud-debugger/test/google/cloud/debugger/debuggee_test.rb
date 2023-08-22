# Copyright 2016 Google LLC
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

require "helper"

describe Google::Cloud::Debugger::Debuggee, :mock_debugger do
  describe "#register" do
    it "sets debuggee id when registered successfully" do
      mocked_response = OpenStruct.new(debuggee: OpenStruct.new(id: debuggee_id))
      debuggee.service.stub :register_debuggee, mocked_response do
        _(debuggee.register).must_equal true
      end
      _(debuggee.id).must_equal debuggee_id
    end

    it "revokes debuggee id if registration request raises exception" do
      mocked_register_debuggee = ->() { raise }

      debuggee.service.stub :register_debuggee, mocked_register_debuggee do
        _(debuggee.register).must_equal false
      end

      _(debuggee.id).must_be_nil
    end
  end

  describe "#registered" do
    it "returns true if debuggee id isn't nil" do
      _(debuggee.registered?).must_equal true
      debuggee.instance_variable_set :@id, nil
      _(debuggee.registered?).must_equal false
    end
  end

  describe "#revoke_registration" do
    it "unsets debuggee id" do
      debuggee.revoke_registration

      _(debuggee.id).must_be_nil
      _(debuggee.registered?).must_equal false
    end
  end

  describe "#to_grpc" do
    it "has all the attributes" do
      grpc = debuggee.to_grpc
      _(grpc.id).must_equal debuggee_id
      _(grpc.project).must_equal project
      _(grpc.uniquifier).wont_be_nil
      _(grpc.description).wont_be_nil
      _(grpc.agent_version).wont_be_nil
      _(grpc.labels.to_a).wont_be_empty
    end

    it "uses numeric project ID if available" do
      numeric_id = 1234567890
      path_base = "#{Google::Cloud::Env::METADATA_PATH_BASE}/project"
      metadata_cache = {
        Google::Cloud::Env::METADATA_ROOT_PATH => true,
        "#{path_base}/project-id" => project,
        "#{path_base}/numeric-project-id" => numeric_id
      }
      mock_env = Google::Cloud::Env.new metadata_cache: metadata_cache
      debuggee.instance_variable_set :@env, mock_env
      grpc = debuggee.to_grpc
      _(grpc.project).must_equal numeric_id.to_s
    end
  end

  describe "#read_app_json_file" do
    it "returns nil if fails to read file" do
      stubbed_read = ->(_) { raise }
      File.stub :read, stubbed_read do
        _(debuggee.send(:read_app_json_file, nil)).must_be_nil
      end
    end

    it "returns nil if fails to parse JSON" do
      stubbed_parse = ->(_, _) { raise }

      File.stub :read, nil do
        JSON.stub :parse, stubbed_parse do
          _(debuggee.send(:read_app_json_file, nil)).must_be_nil
        end
      end
    end
  end

  describe "#compute_uniquifier" do
    let(:partial_debuggee) {
      Google::Cloud::Debugger::V2::Debuggee.new(
        id: debuggee_id,
        project: project
      )
    }

    it "caches generated uniquifier" do
      uniquifier1 = debuggee.send(:compute_uniquifier, partial_debuggee)
      uniquifier2 = debuggee.send(:compute_uniquifier, partial_debuggee)

      _(uniquifier1).must_equal uniquifier2
      _(uniquifier1).must_equal debuggee.instance_variable_get(:@computed_uniquifier)
    end

    it "calls AppUniquifierGenerator.generate_app_uniquifier if source context is missing" do
      mocked_generate_app_uniquifier = Minitest::Mock.new
      mocked_generate_app_uniquifier.expect :call, nil, [Digest::SHA1]

      Google::Cloud::Debugger::Debuggee::AppUniquifierGenerator.stub :generate_app_uniquifier, mocked_generate_app_uniquifier do
        debuggee.send(:compute_uniquifier, partial_debuggee)
      end
      mocked_generate_app_uniquifier.verify
    end

    it "doesn't call AppUniquifierGenerator.generate_app_uniquifier if source context is present" do
      stubbed_generate_app_uniquifier = ->(_) {
        raise "Shouldn't be called"
      }

      source_context = Google::Devtools::Source::V1::SourceContext.new(
        git: Google::Devtools::Source::V1::GitSourceContext.new(
          url: "url", revision_id: "revision"
        )
      )
      partial_debuggee.source_contexts << source_context

      Google::Cloud::Debugger::Debuggee::AppUniquifierGenerator.stub :generate_app_uniquifier, stubbed_generate_app_uniquifier do
        debuggee.send(:compute_uniquifier, partial_debuggee)
      end
    end
  end
end
