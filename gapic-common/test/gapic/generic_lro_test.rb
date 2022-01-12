# Copyright 2021 Google LLC
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

require "gapic/operation"
require "gapic/generic_lro/operation"
require "google/protobuf/any_pb"
require "google/protobuf/well_known_types"
require "google/rpc/status_pb"
require "google/longrunning/operations_pb"

GenericLRO = Gapic::GenericLRO::Operation

class GenericLROTest < Minitest::Test
  NAME = "seabiscuit"
  REGION = "MARS"
  ERR_CODE = 3059181
  ERR_MSG = "my hovercraft is full of eels"

  # Testing unfinished object for symbol status
  def test_unfinished_operation
    op = create_op MockOperation.new(status: :NOTDONE, name: NAME)
    refute op.done?
    refute op.error?
    refute op.response?
    assert_nil op.results
    assert_nil op.error
    assert_nil op.response
  end

  # Testing unfinished object for boolean status
  def test_unfinished_operation_boolean
    op = create_op MockOperation.new(status: false, name: NAME)
    refute op.done?
    refute op.error?
    refute op.response?
    assert_nil op.results
    assert_nil op.error
    assert_nil op.response
  end

  # Testing errored-out object for symbol status
  def test_errored_operation
    op = create_op MockOperation.new(status: :DONE, err_code: ERR_CODE, err_msg: ERR_MSG)
    assert op.done?
    assert op.error?
    refute op.response?
    assert_equal ERR_CODE, op.results.code
    assert_equal ERR_MSG, op.results.message
    assert_equal ERR_CODE, op.error.code
    assert_equal ERR_MSG, op.error.message
    assert_nil op.response
  end

  # Testing errored-out object for boolean status
  def test_errored_operation_boolean
    op = create_op MockOperation.new(status: true, err_code: ERR_CODE, err_msg: ERR_MSG)
    assert op.done?
    assert op.error?
    refute op.response?
    assert_equal ERR_CODE, op.results.code
    assert_equal ERR_MSG, op.results.message
    assert_equal ERR_CODE, op.error.code
    assert_equal ERR_MSG, op.error.message
    assert_nil op.response
  end

  # Testing errored-out object for message-type error
  def test_errored_operation
    error = OpenStruct.new(code: ERR_CODE, message: ERR_MSG)
    op = create_op MockOperation.new(status: :DONE, err: error), err_field: "err"
    assert op.done?
    assert op.error?
    refute op.response?
    assert_equal error, op.results
    assert_equal error, op.error
    assert_nil op.response
  end

  # Testing done object for symbol status
  def test_done_operation
    op = create_op MockOperation.new(status: :DONE, name: NAME)
    assert op.done?
    refute op.error?
    assert op.response?
    assert_nil op.error
    assert_equal NAME, op.name
    refute_nil op.response
  end

  # Testing done object for boolean status
  def test_done_operation_boolean
    op = create_op MockOperation.new(status: true, name: NAME)
    assert op.done?
    refute op.error?
    assert op.response?
    assert_nil op.error
    assert_equal NAME, op.name
    refute_nil op.response
  end

  # Reload calls the get_operation of the client
  def test_reload
    called = false

    get_method = proc do |operation_name:, region:, options:|
      called = true
      assert_equal NAME, operation_name
      assert_kind_of Gapic::CallOptions, options

      MockOperation.new(status: :DONE, name: NAME)
    end

    mock_client = MockLroClient.new get_method: get_method
    op = create_op MockOperation.new(status: :NOTDONE, name: NAME), client: mock_client

    refute called
    op.reload!
    assert called
  end

  # Reload uses options
  def test_reload_options
    called = false
    opts = Gapic::CallOptions.new timeout: 1, metadata: {foo: "bar"}

    get_method = proc do |operation_name:, region:, options:|
      called = true
      assert_equal NAME, operation_name
      assert_equal opts.to_h, options.to_h

      MockOperation.new(status: :DONE, name: NAME)
    end

    mock_client = MockLroClient.new get_method: get_method
    op = create_op MockOperation.new(status: :NOTDONE, name: NAME), client: mock_client

    refute called

    op.reload! options: opts
    assert called
  end

  # Reload uses the request values
  def test_reload_request_values
    called = false
    opts = Gapic::CallOptions.new timeout: 1, metadata: {foo: "bar"}

    get_method = proc do |operation_name:, region:, options:|
      called = true
      assert_equal NAME, operation_name
      assert_equal REGION, region
      assert_equal opts.to_h, options.to_h

      MockOperation.new(status: :DONE, name: NAME)
    end

    mock_client = MockLroClient.new get_method: get_method
    op = create_op MockOperation.new(status: :NOTDONE, name: NAME),
                   client: mock_client,
                   request_values: {"region" => REGION}

    refute called

    op.reload! options: opts
    assert called
  end

  # Done callbacks are triggered
  def test_done_callback
    called = false
    op = create_op MockOperation.new(status: :NOTDONE, name: NAME)
    op.on_done do |operation|
      called = true
      # result of the Nonstandard LRO operation is the underlying Operation object
      assert_equal NAME, operation.results.name
    end

    refute called
    refute op.done?
    op.reload!
    assert op.done?
    assert called
  end

  # Multiple done callbacks are triggered in order
  def test_done_multiple_callbacks
    op = create_op MockOperation.new(status: :NOTDONE, name: NAME)
    expected_order = [1, 2, 3]
    called_order = []

    expected_order.each do |i|
      op.on_done do |operation|
        assert_equal NAME, operation.results.name
        called_order.push i
      end
    end

    assert_equal [], called_order
    refute op.done?
    op.reload!
    assert op.done?
    assert_equal expected_order, called_order
  end

  # Reload callback is triggered
  def test_reload_callback
    called = false
    op = create_op MockOperation.new(status: :NOTDONE, name: NAME)
    op.on_reload do |operation|
      called = true
      refute operation.done?
    end

    refute called
    refute op.done?
    op.reload!
    assert op.done?
    assert called
  end

  # Wait until done is retrying until done
  def test_wait_until_done
    to_call = 3
    get_method = proc do
      to_call -= 1
      status = to_call == 0 ? :DONE : :NOT_DONE
      MockOperation.new(status: status, name: NAME)
    end

    mock_client = MockLroClient.new get_method: get_method
    op = create_op MockOperation.new(status: :NOTDONE, name: NAME), client: mock_client

    sleep_counts = [10.0, 13.0, 16.900000000000002]
    sleep_mock = Minitest::Mock.new
    sleep_counts.each do |sleep_count|
      sleep_mock.expect :sleep, nil, [sleep_count]
    end

    sleep_proc = ->(count) do 
      sleep_mock.sleep count 
    end

    Kernel.stub :sleep, sleep_proc do
      time_now = Time.now
      Time.stub :now, time_now do
        op.wait_until_done!
      end
    end

    sleep_mock.verify
    assert_equal 0, to_call
  end

  # Wait until done triggers reload callbacks correctly
  def test_wait_until_done_reload_callbacks
    to_call = 3
    get_method = proc do
      to_call -= 1
      status = to_call == 0 ? :DONE : :NOT_DONE
      MockOperation.new(status: status, name: NAME)
    end

    mock_client = MockLroClient.new get_method: get_method
    op = create_op MockOperation.new(status: :NOTDONE, name: NAME), client: mock_client

    reload_called = 0
    op.on_reload do |operation|
      reload_called += 1
    end

    sleep_counts = [10.0, 13.0, 16.900000000000002]
    sleep_mock = Minitest::Mock.new
    sleep_counts.each do |sleep_count|
      sleep_mock.expect :sleep, nil, [sleep_count]
    end

    sleep_proc = ->(count) do 
      sleep_mock.sleep count 
    end

    Kernel.stub :sleep, sleep_proc do
      time_now = Time.now
      Time.stub :now, time_now do
        op.wait_until_done!
      end
    end

    sleep_mock.verify
    assert_equal 0, to_call
    assert_equal 3, reload_called
  end

  # Terminates correctly on timeout
  def test_time_out
    get_method = proc { create_op MockOperation.new(status: :NOTDONE, name: NAME) }
    mock_client = MockLroClient.new get_method: get_method
    op = create_op MockOperation.new(status: :NOTDONE, name: NAME), client: mock_client

    sleep_counts = [10, 20, 40, 80]
    sleep_mock = Minitest::Mock.new
    sleep_counts.each do |sleep_count|
      sleep_mock.expect :sleep, nil, [sleep_count]
    end
    sleep_proc = ->(count) { sleep_mock.sleep count }

    Kernel.stub :sleep, sleep_proc do
      time_now = Time.now
      incrementing_time = lambda do
        delay = sleep_counts.shift || 160
        time_now += delay
      end
      Time.stub :now, incrementing_time do
        retry_config = { initial_delay: 10, multiplier: 2, max_delay: (5 * 60), timeout: 400 }
        op.wait_until_done! retry_policy: retry_config
        refute op.done?
      end
    end

    sleep_mock.verify
  end

  # Retry options are applied correctly
  def test_exponential_backoff
    call_count = 0
    get_method = proc do
      call_count += 1
      if call_count >= 10
        MockOperation.new(status: :DONE, name: NAME)
      else
        MockOperation.new(status: :NOT_DONE, name: NAME)
      end
    end
    mock_client = MockLroClient.new get_method: get_method
    op = create_op MockOperation.new(status: :NOT_DONE, name: NAME), client: mock_client

    sleep_counts = [10, 20, 40, 80, 160, 300, 300, 300, 300, 300]
    sleep_mock = Minitest::Mock.new
    sleep_counts.each do |sleep_count|
      sleep_mock.expect :sleep, nil, [sleep_count]
    end
    sleep_proc = ->(count) { sleep_mock.sleep count }

    Kernel.stub :sleep, sleep_proc do
      time_now = Time.now
      incrementing_time = lambda do
        delay = sleep_counts.shift || 300
        time_now += delay
      end
      Time.stub :now, incrementing_time do
        retry_config = { initial_delay: 10, multiplier: 2, max_delay: (5 * 60), timeout: (60 * 60) }
        op.wait_until_done! retry_policy: retry_config
        assert op.done?
      end
    end

    sleep_mock.verify
  end

  # On_done callback is triggered if operation is Done before wrapping
  def test_lro_already_done
    op = create_op MockOperation.new(status: :DONE, name: NAME)

    called = false
    op.on_done do |operation|
      assert_equal NAME, operation.results.name
      called = true
    end
    assert called
  end

  private

  class MockOperation
    attr_accessor :status, :name, :err_code, :err_msg, :err
  
    def initialize(status:, name: nil, err: nil, err_code: nil, err_msg: nil)
      @status = status
      @name = name
      @err = err
      @err_code = err_code
      @err_msg = err_msg
    end
  end

  class MockLroClient
    def initialize get_method: nil
      @get_method = get_method
    end
  
    def get_operation request, options = nil
      # `get_operation` is the polling method of the LRO Provider
      # here we simulate that its input message has a field called `operation_name`,
      # and a field called `region`
      result = @get_method.call operation_name: request[:operation_name], region: request[:region], options: options
      GenericLROTest::create_op result, client: self
    end
  end

  DONE_GET_METHOD = proc do
    MockOperation.new(status: :DONE, name: NAME)
  end

  DONE_ON_GET_CLIENT = MockLroClient.new get_method: DONE_GET_METHOD

  def create_op operation, client: nil, request_values: {}, err_field: nil
    GenericLROTest::create_op operation,
                                  client:client,
                                  request_values: request_values,
                                  err_field: err_field
  end

  class << self
    def create_op operation, client: nil, request_values: {}, err_field: nil
      GenericLRO.new(operation, 
        client: (client || DONE_ON_GET_CLIENT),
        polling_method_name: "get_operation",
        operation_status_field: "status",
        # The `request_values` are the values that are saved from the request
        # that kicks off the initial long-running operation, and which
        # need to be added to every request to poll for this operation.
        # E.g. a region, or an organization id.
        request_values: request_values,
        operation_name_field: "name",
        operation_err_field: err_field,
        operation_err_code_field: "err_code",
        operation_err_msg_field: "err_msg",
        # The value of `name` field will be copied to the `operation_name`
        # This simulates the situation when the field in the polling method's request message
        # is named differently from the field in the Operation message
        operation_copy_fields: {"name" => "operation_name"},
        options: nil
      )
    end
  end
end
