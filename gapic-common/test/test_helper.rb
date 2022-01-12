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

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"

require "gapic/common"
require "gapic/rest"
require "google/protobuf/any_pb"
require_relative "./fixtures/fixture_pb"

class FakeCodeError < StandardError
  attr_reader :code

  def initialize msg, code
    super msg
    @code = code
  end
end

class OperationStub
  def initialize &block
    @block = block
  end

  def execute
    @block.call
  end
end

class FakeGapicStub
  def initialize *responses
    @responses = responses
    @count = 0
  end

  def call_rpc *args
    result = @responses.shift
    @count += 1
    fake_operation = "fake_operation_#{@count}".to_sym
    yield result, fake_operation if block_given?
    result
  end
end

class FakeReGapicServiceStub
  def initialize *responses
    @responses = responses
    @count = 0
  end

  def call_rest *args
    result = @responses.shift
    @count += 1
    yield result, result if block_given?
    result
  end
end
