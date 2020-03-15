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

require "helper"
require "google/cloud/dialogflow"
require "gapic/common"
require "gapic/grpc"

describe Google::Cloud::Dialogflow do
  it "constructs an agents client with the default version" do
    Gapic::ServiceStub.stub :new, :stub do
      grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
      client = Google::Cloud::Dialogflow.agents do |config|
        config.credentials = grpc_channel
      end
      client.must_be_kind_of Google::Cloud::Dialogflow::V2::Agents::Client
    end
  end

  it "constructs a contexts client with the default version" do
    Gapic::ServiceStub.stub :new, :stub do
      grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
      client = Google::Cloud::Dialogflow.contexts do |config|
        config.credentials = grpc_channel
      end
      client.must_be_kind_of Google::Cloud::Dialogflow::V2::Contexts::Client
    end
  end

  it "constructs an entity types client with the default version" do
    Gapic::ServiceStub.stub :new, :stub do
      grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
      client = Google::Cloud::Dialogflow.entity_types do |config|
        config.credentials = grpc_channel
      end
      client.must_be_kind_of Google::Cloud::Dialogflow::V2::EntityTypes::Client
    end
  end

  it "constructs an intents client with the default version" do
    Gapic::ServiceStub.stub :new, :stub do
      grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
      client = Google::Cloud::Dialogflow.intents do |config|
        config.credentials = grpc_channel
      end
      client.must_be_kind_of Google::Cloud::Dialogflow::V2::Intents::Client
    end
  end

  it "constructs a session entity types client with the default version" do
    Gapic::ServiceStub.stub :new, :stub do
      grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
      client = Google::Cloud::Dialogflow.session_entity_types do |config|
        config.credentials = grpc_channel
      end
      client.must_be_kind_of Google::Cloud::Dialogflow::V2::SessionEntityTypes::Client
    end
  end

  it "constructs a sessions client with the default version" do
    Gapic::ServiceStub.stub :new, :stub do
      grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
      client = Google::Cloud::Dialogflow.sessions do |config|
        config.credentials = grpc_channel
      end
      client.must_be_kind_of Google::Cloud::Dialogflow::V2::Sessions::Client
    end
  end
end
