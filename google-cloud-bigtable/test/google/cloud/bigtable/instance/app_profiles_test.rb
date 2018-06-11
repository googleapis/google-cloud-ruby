# frozen_string_literal: true

# Copyright 2018 Google LLC
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

describe Google::Cloud::Bigtable::Instance, :app_profiles, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:instance_grpc){
    Google::Bigtable::Admin::V2::Instance.new(name: instance_path(instance_id))
  }
  let(:instance) {
    Google::Cloud::Bigtable::Instance.from_grpc(instance_grpc, bigtable.service)
  }
  let(:first_page) do
    h = app_profiles_hash(instance_id)
    h[:next_page_token] = "next_page_token"
    Google::Bigtable::Admin::V2::ListAppProfilesResponse.new(h)
  end
  let(:second_page) do
    h = app_profiles_hash(instance_id, start_id: 10)
    h[:next_page_token] = "second_page_token"
    Google::Bigtable::Admin::V2::ListAppProfilesResponse.new(h)
  end
  let(:last_page) do
    h = app_profiles_hash(instance_id, start_id: 20)
    h[:app_profiles].pop
    Google::Bigtable::Admin::V2::ListAppProfilesResponse.new(h)
  end

  it "list app profiles" do
    get_res =  MockPagedEnumerable.new([first_page])
    mock = Minitest::Mock.new
    mock.expect :list_app_profiles, get_res, [instance_path(instance_id)]
    bigtable.service.mocked_instances = mock

    app_profiles = instance.app_profiles

    mock.verify

    app_profiles.size.must_equal 3
  end

  it "paginates app profiles with next? and next" do
    get_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_app_profiles, get_res, [instance_path(instance_id)]

    bigtable.service.mocked_instances = mock

    list = instance.app_profiles

    mock.verify

    list.size.must_equal 3
    list.next?.must_equal true
    list.next.size.must_equal 2
    list.next?.must_equal false
  end

  it "paginates app profiles with all" do
    get_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_app_profiles, get_res, [instance_path(instance_id)]
    bigtable.service.mocked_instances = mock

    app_profiles = instance.app_profiles.all.to_a

    mock.verify

    app_profiles.size.must_equal 5
  end

  it "iterates app profiles with all using Enumerator" do
    get_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_app_profiles, get_res, [instance_path(instance_id)]
    bigtable.service.mocked_instances = mock

    app_profiles = instance.app_profiles.all.take(5)

    mock.verify

    app_profiles.size.must_equal 5
  end
end
