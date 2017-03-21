# Copyright 2017 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Spanner::Pool, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:default_options) { Google::Gax::CallOptions.new kwargs: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  let(:client) { spanner.client instance_id, database_id, min: 0, max: 4 }
  let(:default_options) { Google::Gax::CallOptions.new kwargs: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  let(:pool) do
    p = client.instance_variable_get :@pool
    p.pool = [session]
    p.queue = [session]
    p
  end

  after do
    # Close the client and release the keepalive thread
    client.instance_variable_get(:@pool).pool = []
    client.close
  end

  it "can checkout and checkin a session" do
    pool.pool.size.must_equal 1
    pool.queue.size.must_equal 1

    s = pool.checkout

    pool.pool.size.must_equal 1
    pool.queue.size.must_equal 0

    pool.checkin s

    pool.pool.size.must_equal 1
    pool.queue.size.must_equal 1
  end

  it "creates new sessions when needed" do
    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), options: default_options]
    spanner.service.mocked_service = mock

    pool.pool.size.must_equal 1
    pool.queue.size.must_equal 1

    s1 = pool.checkout
    s2 = pool.checkout

    pool.pool.size.must_equal 2
    pool.queue.size.must_equal 0

    pool.checkin s1
    pool.checkin s2

    pool.pool.size.must_equal 2
    pool.queue.size.must_equal 2

    mock.verify
  end

  it "raises when checking out more than MAX sessions" do
    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), options: default_options]
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), options: default_options]
    mock.expect :create_session, session_grpc, [database_path(instance_id, database_id), options: default_options]
    spanner.service.mocked_service = mock

    pool.pool.size.must_equal 1
    pool.queue.size.must_equal 1

    s1 = pool.checkout
    s2 = pool.checkout
    s3 = pool.checkout
    s4 = pool.checkout

    checkout_error = assert_raises RuntimeError do
      pool.checkout
    end
    checkout_error.message.must_equal "No available sessions"

    pool.pool.size.must_equal 4
    pool.queue.size.must_equal 0

    pool.checkin s1
    pool.checkin s2
    pool.checkin s3
    pool.checkin s4

    pool.pool.size.must_equal 4
    pool.queue.size.must_equal 4

    mock.verify
  end

  it "raises when checking in a session that does not belong" do
    outside_session = Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service

    checkin_error = assert_raises RuntimeError do
      pool.checkin outside_session
    end
    checkin_error.message.must_equal "Cannot checkin session"
  end
end
