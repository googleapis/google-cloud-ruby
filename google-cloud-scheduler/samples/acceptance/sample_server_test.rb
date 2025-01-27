# frozen_string_literal: true

# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../app"

require "minitest/autorun"
require "minitest/focus"
require "rack/test"

# Test the Sinatra server for the Cloud Scheduler sample.
class SchedulerSampleServerTest < Minitest::Test
  include Rack::Test::Methods

  parallelize_me!

  def app
    Sinatra::Application
  end

  def test_returns_hello_world
    get "/"
    assert_match "Hello World!", last_response.body
  end

  def test_posts_to_log_payload
    post "/log_payload", "Hello"
    assert_match "Printed job payload", last_response.body
  end
end
