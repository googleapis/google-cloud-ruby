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

require "helper"

describe Google::Cloud::PubSub::Project, :snapshots, :mock_pubsub do
  let(:snapshots_with_token) do
    response = Google::Cloud::PubSub::V1::ListSnapshotsResponse.new snapshots_hash("fake-topic", 3, "next_page_token")
    paged_enum_struct response
  end
  let(:snapshots_without_token) do
    response = Google::Cloud::PubSub::V1::ListSnapshotsResponse.new snapshots_hash("fake-topic", 2)
    paged_enum_struct response
  end
  let(:snapshots_with_token_2) do
    response = Google::Cloud::PubSub::V1::ListSnapshotsResponse.new snapshots_hash("fake-topic", 3, "second_page_token")
    paged_enum_struct response
  end

  it "lists snapshots" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, project: "projects/#{project}", page_size: nil, page_token: nil 
    pubsub.service.mocked_subscriber = mock

    snapshots = pubsub.snapshots

    mock.verify

    _(snapshots.count).must_equal 3
    snapshots.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end
  end

  it "lists snapshots with find_snapshots alias" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, project: "projects/#{project}", page_size: nil, page_token: nil 
    pubsub.service.mocked_subscriber = mock

    snapshots = pubsub.find_snapshots

    mock.verify

    _(snapshots.count).must_equal 3
    snapshots.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end
  end

  it "lists snapshots with list_snapshots alias" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, project: "projects/#{project}", page_size: nil, page_token: nil 
    pubsub.service.mocked_subscriber = mock

    snapshots = pubsub.list_snapshots

    mock.verify

    _(snapshots.count).must_equal 3
    snapshots.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end
  end

  it "paginates snapshots" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, project: "projects/#{project}", page_size: nil, page_token: nil 
    mock.expect :list_snapshots, snapshots_without_token, project: "projects/#{project}", page_size: nil, page_token: "next_page_token" 
    pubsub.service.mocked_subscriber = mock

    first_subs = pubsub.snapshots
    second_subs = pubsub.snapshots token: first_subs.token

    mock.verify

    _(first_subs.count).must_equal 3
    token = first_subs.token
    _(token).wont_be :nil?
    _(token).must_equal "next_page_token"

    _(second_subs.count).must_equal 2
    _(second_subs.token).must_be :nil?
  end

  it "paginates snapshots with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, project: "projects/#{project}", page_size: 3, page_token: nil 
    pubsub.service.mocked_subscriber = mock

    snapshots = pubsub.snapshots max: 3

    mock.verify

    _(snapshots.count).must_equal 3
    token = snapshots.token
    _(token).wont_be :nil?
    _(token).must_equal "next_page_token"
  end

  it "paginates snapshots with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, project: "projects/#{project}", page_size: nil, page_token: nil 
    mock.expect :list_snapshots, snapshots_without_token, project: "projects/#{project}", page_size: nil, page_token: "next_page_token" 
    pubsub.service.mocked_subscriber = mock

    first_subs = pubsub.snapshots
    second_subs = first_subs.next

    mock.verify

    _(first_subs.count).must_equal 3
    _(first_subs.next?).must_equal true
    first_subs.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end

    _(second_subs.count).must_equal 2
    _(second_subs.next?).must_equal false
    second_subs.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end
  end

  it "paginates snapshots with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, project: "projects/#{project}", page_size: 3, page_token: nil 
    mock.expect :list_snapshots, snapshots_without_token, project: "projects/#{project}", page_size: 3, page_token: "next_page_token" 
    pubsub.service.mocked_subscriber = mock

    first_subs = pubsub.snapshots max: 3
    second_subs = first_subs.next

    mock.verify

    _(first_subs.count).must_equal 3
    _(first_subs.next?).must_equal true
    first_subs.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end

    _(second_subs.count).must_equal 2
    _(second_subs.next?).must_equal false
    second_subs.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end
  end

  it "paginates snapshots with all" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, project: "projects/#{project}", page_size: nil, page_token: nil 
    mock.expect :list_snapshots, snapshots_without_token, project: "projects/#{project}", page_size: nil, page_token: "next_page_token" 
    pubsub.service.mocked_subscriber = mock

    snapshots = pubsub.snapshots.all.to_a

    mock.verify

    _(snapshots.count).must_equal 5
    snapshots.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end
  end

  it "paginates snapshots with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, project: "projects/#{project}", page_size: 3, page_token: nil 
    mock.expect :list_snapshots, snapshots_without_token, project: "projects/#{project}", page_size: 3, page_token: "next_page_token" 
    pubsub.service.mocked_subscriber = mock

    snapshots = pubsub.snapshots(max: 3).all.to_a

    mock.verify

    _(snapshots.count).must_equal 5
    snapshots.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end
  end

  it "iterates snapshots with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, project: "projects/#{project}", page_size: nil, page_token: nil 
    mock.expect :list_snapshots, snapshots_with_token_2, project: "projects/#{project}", page_size: nil, page_token: "next_page_token" 
    pubsub.service.mocked_subscriber = mock

    snapshots = pubsub.snapshots.all.take(5)

    mock.verify

    _(snapshots.count).must_equal 5
    snapshots.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end
  end

  it "iterates snapshots with all and request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_snapshots, snapshots_with_token, project: "projects/#{project}", page_size: nil, page_token: nil 
    mock.expect :list_snapshots, snapshots_with_token_2, project: "projects/#{project}", page_size: nil, page_token: "next_page_token" 
    pubsub.service.mocked_subscriber = mock

    snapshots = pubsub.snapshots.all(request_limit: 1).to_a

    mock.verify

    _(snapshots.count).must_equal 6
    snapshots.each do |snapshot|
      _(snapshot).must_be_kind_of Google::Cloud::PubSub::Snapshot
    end
  end
end
