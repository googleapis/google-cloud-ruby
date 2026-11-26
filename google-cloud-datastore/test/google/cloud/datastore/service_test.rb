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

describe Google::Cloud::Datastore::Service do
  let(:project) { "test" }
  let(:database) { "" }
  let(:credentials) { :this_channel_is_insecure }
  let(:host) { "localhost:8081" }
  let(:timeout) { 123.4 }
  let(:default_config) { Google::Cloud::Datastore::V1::Datastore::Client.configure }

  it "keeps the default timeouts when no timeout is given" do
    service = Google::Cloud::Datastore::Service.new project, credentials, database, host: host
    config = service.service.configure

    _(config.timeout).must_be :nil?
    assert_config_rpcs_timeouts default_config.rpcs, config.rpcs
  end

  it "applies the timeout to the client config and to every RPC config" do
    service = Google::Cloud::Datastore::Service.new project, credentials, database, host: host, timeout: timeout
    config = service.service.configure

    _(config.timeout).must_equal timeout
    assert_config_rpcs_timeouts default_config.rpcs, config.rpcs, timeout: timeout
  end

  it "sends requests with the configured timeout" do
    service = Google::Cloud::Datastore::Service.new project, credentials, database, host: host, timeout: timeout
    sent_timeouts = {}
    stub = service.service.instance_variable_get :@datastore_stub
    stub.define_singleton_method :call_rpc do |method, _request, options:|
      sent_timeouts[method] = options.timeout
      nil
    end

    service.lookup Google::Cloud::Datastore::V1::Key.new
    service.commit []
    service.allocate_ids Google::Cloud::Datastore::V1::Key.new

    _(sent_timeouts).must_equal({ lookup: timeout, commit: timeout, allocate_ids: timeout })
  end

  it "does not change the default client configuration" do
    Google::Cloud::Datastore::Service.new(project, credentials, database, host: host, timeout: timeout).service

    _(default_config.timeout).must_be :nil?
    _(default_config.rpcs.lookup.timeout).must_equal 60.0
  end

  # @param [Numeric, nil] timeout Expected non-default timeout.
  def assert_config_rpcs_timeouts expected_rpcs, actual_rpcs, timeout: nil
    expected_rpc_names = expected_rpcs.methods - Object.methods
    # Explicit sanity check of the number of expected rpcs
    _(expected_rpc_names.count).must_equal 8
    _((actual_rpcs.methods - Object.methods).count).must_equal 8
    expected_rpc_names.each do |rpc_name|
      expected_timeout = timeout || expected_rpcs.send(rpc_name).timeout
      actual_timeout = actual_rpcs.send(rpc_name).timeout
      if expected_timeout.nil?
        assert_nil actual_timeout, "Unexpected timeout for #{rpc_name}"
      else
        assert_equal expected_timeout, actual_timeout, "Unexpected timeout for #{rpc_name}"
      end
    end
  end
end
