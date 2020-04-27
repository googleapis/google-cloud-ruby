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

describe Google::Cloud::Logging::Project, :async_writer, :mock_logging do
  it "creates an async writer object" do
    async = logging.async_writer
    _(async).must_be_kind_of Google::Cloud::Logging::AsyncWriter
    _(async.logging).must_be_same_as logging
    _(async.max_count).must_equal 10000
    _(async.max_bytes).must_equal 10000000
    _(async.max_queue).must_equal 100
    _(async.interval).must_equal 5
    _(async.threads).must_equal 10
    _(async).must_be :started?
  end

  it "creates an async writer object with custom options" do
    async = logging.async_writer max_batch_count: 42, max_batch_bytes: 5000000, max_queue_size: 123, interval:10, threads: 1
    _(async).must_be_kind_of Google::Cloud::Logging::AsyncWriter
    _(async.logging).must_be_same_as logging
    _(async.max_count).must_equal 42
    _(async.max_bytes).must_equal 5000000
    _(async.max_queue).must_equal 123
    _(async.interval).must_equal 10
    _(async.threads).must_equal 1
    _(async).must_be :started?
  end
end
