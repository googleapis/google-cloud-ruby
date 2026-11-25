# Copyright 2026 Google LLC
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

describe Google::Cloud::Datastore::Service, :mock_datastore do
  let(:rpc_names) { Google::Cloud::Datastore::V1::Datastore::Client.configure.rpcs.methods - Object.methods }

  it "applies the timeout to the client and every RPC config" do
    service = Google::Cloud::Datastore::Service.new project, :this_channel_is_insecure, default_database, timeout: 5
    config = service.service.configure

    _(config.timeout).must_equal 5
    _(rpc_names).wont_be :empty?
    rpc_names.each do |rpc_name|
      rpc = config.rpcs.send rpc_name
      next unless rpc.respond_to? :timeout=
      _(rpc.timeout).must_equal 5, "expected #{rpc_name} timeout to be 5"
    end
  end

  it "keeps the RPC default timeouts when no timeout is given" do
    service = Google::Cloud::Datastore::Service.new project, :this_channel_is_insecure, default_database
    config = service.service.configure
    defaults = Google::Cloud::Datastore::V1::Datastore::Client.configure

    _(config.rpcs.commit.timeout).must_equal defaults.rpcs.commit.timeout
    _(config.rpcs.lookup.timeout).must_equal defaults.rpcs.lookup.timeout
  end
end
