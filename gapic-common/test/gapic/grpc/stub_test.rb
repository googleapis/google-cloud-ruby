# Copyright 2019 Google LLC
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

require "test_helper"
require "gapic/grpc"

class GrpcStubTest < Minitest::Spec
  FakeCallCredentials = Class.new GRPC::Core::CallCredentials do
    attr_reader :updater_proc

    def initialize updater_proc
      @updater_proc = updater_proc
    end
  end

  FakeChannel = Class.new GRPC::Core::Channel do
    def initialize
    end
  end

  FakeChannelCredentials = Class.new GRPC::Core::ChannelCredentials do
    attr_reader :call_creds

    def compose call_creds
      @call_creds = call_creds
    end
  end

  FakeCredentials = Class.new Google::Auth::Credentials do
    def initialize
    end

    def updater_proc
      ->{}
    end
  end

  def test_with_channel
    fake_channel = FakeChannel.new

    mock = Minitest::Mock.new
    mock.expect :nil?, false
    mock.expect :new, nil, ["service:port", nil, channel_override: fake_channel, interceptors: []]

    Gapic::ServiceStub.new mock, endpoint: "service:port", credentials: fake_channel

    mock.verify
  end

  def test_with_channel_credentials
    fake_channel_creds = FakeChannelCredentials.new

    mock = Minitest::Mock.new
    mock.expect :nil?, false
    mock.expect :new, nil, ["service:port", fake_channel_creds, channel_args: {}, interceptors: []]

    Gapic::ServiceStub.new mock, endpoint: "service:port", credentials: fake_channel_creds

    mock.verify
  end

  def test_with_symbol_credentials
    creds = :this_channel_is_insecure

    mock = Minitest::Mock.new
    mock.expect :nil?, false
    mock.expect :new, nil, ["service:port", creds, channel_args: {}, interceptors: []]

    Gapic::ServiceStub.new mock, endpoint: "service:port", credentials: creds

    mock.verify
  end

  def test_with_credentials
    GRPC::Core::CallCredentials.stub :new, FakeCallCredentials.method(:new) do
      GRPC::Core::ChannelCredentials.stub :new, FakeChannelCredentials.method(:new) do
        mock = Minitest::Mock.new
        mock.expect :nil?, false
        mock.expect :new, nil, ["service:port", FakeCallCredentials, channel_args: {}, interceptors: []]

        Gapic::ServiceStub.new mock, endpoint: "service:port", credentials: FakeCredentials.new

        mock.verify
      end
    end
  end

  def test_with_proc
    GRPC::Core::CallCredentials.stub :new, FakeCallCredentials.method(:new) do
      GRPC::Core::ChannelCredentials.stub :new, FakeChannelCredentials.method(:new) do
        mock = Minitest::Mock.new
        mock.expect :nil?, false
        mock.expect :new, nil, ["service:port", FakeCallCredentials, channel_args: {}, interceptors: []]

        credentials_proc = ->{}

        Gapic::ServiceStub.new mock, endpoint: "service:port", credentials: credentials_proc

        mock.verify
      end
    end
  end
end
