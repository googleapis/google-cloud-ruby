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

require "gapic/config"
require "gapic/config/method"

class ServiceConfig
  extend Gapic::Config

  config_attr :endpoint,     "localhost", String
  config_attr :timeout,      60,          Numeric, nil
  config_attr :metadata,     nil,         Hash, nil
  config_attr :retry_policy, nil,         Hash, Proc, nil

  attr_reader :rpc_method

  def initialize parent_config = nil
    @parent_config = parent_config unless parent_config.nil?
    @rpc_method = Gapic::Config::Method.new parent_config&.rpc_method

    yield self if block_given?
  end
end

class MethodConfigTest < Minitest::Test
  def test_rpc_method
    config = ServiceConfig.new

    assert_equal "localhost", config.endpoint
    assert_equal 60,          config.timeout
    assert_nil config.metadata
    assert_nil config.retry_policy

    assert_nil config.rpc_method.timeout
    assert_nil config.rpc_method.metadata
    assert_nil config.rpc_method.retry_policy

    config.rpc_method.timeout = 120
    config.rpc_method.metadata = { header: "value" }
    config.rpc_method.retry_policy = { initial_delay: 15 }

    assert_equal 120, config.rpc_method.timeout
    assert_equal({ header: "value" }, config.rpc_method.metadata)
    assert_equal({ initial_delay: 15 }, config.rpc_method.retry_policy)

    config.rpc_method.retry_policy = ->(error) { true }
    assert_kind_of Proc, config.rpc_method.retry_policy

    config.rpc_method.timeout = nil
    config.rpc_method.metadata = nil
    config.rpc_method.retry_policy = nil

    assert_nil config.rpc_method.timeout
    assert_nil config.rpc_method.metadata
    assert_nil config.rpc_method.retry_policy
  end

  def test_rpc_method_validation
    config = ServiceConfig.new

    assert_raises ArgumentError do
      config.rpc_method.timeout = "60"
    end

    assert_raises ArgumentError do
      config.rpc_method.metadata = ["header", "value"]
    end

    assert_raises ArgumentError do
      config.rpc_method.retry_policy = Gapic::CallOptions::RetryPolicy.new
    end
  end

  def test_nested
    parent_config = ServiceConfig.new do |parent|
      parent.rpc_method.timeout = 120
      parent.rpc_method.metadata = { header: "value" }
      parent.rpc_method.retry_policy = { initial_delay: 15 }
    end
    config = ServiceConfig.new parent_config

    assert_equal "localhost", config.endpoint
    assert_equal 60,          config.timeout

    assert_equal 120, config.rpc_method.timeout
    assert_equal({ header: "value" }, config.rpc_method.metadata)
    assert_equal({ initial_delay: 15 }, config.rpc_method.retry_policy)

    config.rpc_method.timeout = 90
    config.rpc_method.metadata = { x_header: "another value" }
    config.rpc_method.retry_policy = { initial_delay: 30 }

    assert_equal 90, config.rpc_method.timeout
    assert_equal({ x_header: "another value" }, config.rpc_method.metadata)
    assert_equal({ initial_delay: 30 }, config.rpc_method.retry_policy)

    config.rpc_method.retry_policy = ->(error) { true }
    assert_kind_of Proc, config.rpc_method.retry_policy

    config.rpc_method.timeout = nil
    config.rpc_method.metadata = nil
    config.rpc_method.retry_policy = nil

    assert_equal 120, config.rpc_method.timeout
    assert_equal({ header: "value" }, config.rpc_method.metadata)
    assert_equal({ initial_delay: 15 }, config.rpc_method.retry_policy)

    parent_config.rpc_method.timeout = nil
    parent_config.rpc_method.metadata = nil
    parent_config.rpc_method.retry_policy = nil

    assert_nil parent_config.rpc_method.timeout
    assert_nil parent_config.rpc_method.metadata
    assert_nil parent_config.rpc_method.retry_policy
  end

  def test_nested_validation
    parent_config = ServiceConfig.new do |parent|
      parent.rpc_method.timeout = 120
      parent.rpc_method.metadata = { header: "value" }
      parent.rpc_method.retry_policy = { initial_delay: 15 }
    end
    config = ServiceConfig.new parent_config

    assert_raises ArgumentError do
      config.rpc_method.timeout = "60"
    end

    assert_raises ArgumentError do
      config.rpc_method.metadata = ["header", "value"]
    end

    assert_raises ArgumentError do
      config.rpc_method.retry_policy = Gapic::CallOptions::RetryPolicy.new
    end
  end
end
