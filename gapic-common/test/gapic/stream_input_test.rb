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

class StreamInputTest < Minitest::Test
  def test_blocks_until_closed
    closed = false
    stream_request_count = 0

    input = Gapic::StreamInput.new

    stream_check_thread = Thread.new do
      input.to_enum { |r| stream_request_count += 1 }
      closed = true
    end

    assert_equal 0, stream_request_count
    refute closed

    input << :foo
    sleep 0.01

    wait_until { 1 == stream_request_count }
    refute closed

    input.push :bar
    sleep 0.01

    wait_until { 2 == stream_request_count }
    refute closed

    input.append :baz
    sleep 0.01

    wait_until { 3 == stream_request_count }
    refute closed

    input.close
    stream_check_thread.join

    assert_equal 3, stream_request_count
    assert closed
  end

  ##
  # This is an ugly way to block on concurrent criteria, but it works...
  def wait_until iterations = 100
    count = 0
    loop do
      raise "criteria not met" if count >= iterations
      break if yield
      sleep 0.0001
      count += 1
    end
  end
end
