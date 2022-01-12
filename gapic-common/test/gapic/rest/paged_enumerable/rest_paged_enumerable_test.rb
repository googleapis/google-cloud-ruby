# frozen_string_literal: true

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

##
# Tests for the REST paged enumerables
#
class RestPagedEnumerableTest < Minitest::Test
  ##
  # Tests that a `PagedEnumerable` can enumerate all pages via `each_page`
  #
  def test_enumerates_all_pages
    api_responses = [
      Gapic::Examples::GoodPagedResponse.new(
        users: [
          Gapic::Examples::User.new(name: "baz"),
          Gapic::Examples::User.new(name: "bif")
        ]
      )
    ]

    fake_service_stub = FakeReGapicServiceStub.new(*api_responses)
    request = Gapic::Examples::GoodPagedRequest.new
    response = Gapic::Examples::GoodPagedResponse.new(
      users:           [
        Gapic::Examples::User.new(name: "foo"),
        Gapic::Examples::User.new(name: "bar")
      ],
      next_page_token: "next"
    )

    options = {}

    rest_paged_enum = Gapic::Rest::PagedEnumerable.new(
      fake_service_stub, :call_rest, "users", request, response, options
    )

    assert_equal [["foo", "bar"], ["baz", "bif"]], rest_paged_enum.each_page.map { |page| page.map(&:name) }
  end

  ##
  # Tests that a `PagedEnumerable` can enumerate all resources via `each`
  #
  def test_enumerates_all_resources
    api_responses = [
      Gapic::Examples::GoodPagedResponse.new(
        users: [
          Gapic::Examples::User.new(name: "baz"),
          Gapic::Examples::User.new(name: "bif")
        ]
      )
    ]

    fake_service_stub = FakeReGapicServiceStub.new(*api_responses)
    request = Gapic::Examples::GoodPagedRequest.new
    response = Gapic::Examples::GoodPagedResponse.new(
      users:           [
        Gapic::Examples::User.new(name: "foo"),
        Gapic::Examples::User.new(name: "bar")
      ],
      next_page_token: "next"
    )

    options = {}

    rest_paged_enum = Gapic::Rest::PagedEnumerable.new(
      fake_service_stub, :call_rest, "users", request, response, options
    )

    assert_equal %w[foo bar baz bif], rest_paged_enum.each.map(&:name)
  end

  ##
  # Tests that a `PagedEnumerable` can enumerate all resources via `each`
  #
  def test_enumerates_formats_all_resources
    api_responses = [
      Gapic::Examples::GoodPagedResponse.new(
        users: [
          Gapic::Examples::User.new(name: "baz"),
          Gapic::Examples::User.new(name: "bif")
        ]
      )
    ]

    fake_service_stub = FakeReGapicServiceStub.new(*api_responses)
    request = Gapic::Examples::GoodPagedRequest.new
    response = Gapic::Examples::GoodPagedResponse.new(
      users:           [
        Gapic::Examples::User.new(name: "foo"),
        Gapic::Examples::User.new(name: "bar")
      ],
      next_page_token: "next"
    )

    options = {}
    upcase_user = ->(user) { user.name.upcase }

    rest_paged_enum = Gapic::Rest::PagedEnumerable.new(
      fake_service_stub, :call_rest, "users", request, response, options, format_resource: upcase_user
    )

    assert_equal %w[FOO BAR BAZ BIF], rest_paged_enum.each.to_a
  end

  ##
  # Tests that a `PagedEnumerable` wrapping a map field can enumerate all items
  # via a 1-variable block in each: `paged_enumerable.each { |key_value_pair| p key_value_pair }`
  #
  def test_enumerates_all_map_pairs_1varblock
    api_responses = [
      Gapic::Examples::GoodMappedPagedResponse.new(
        items: {
          "foo" => Gapic::Examples::UsersScopedInfo.new(scoped_info: "hoge"),
          "bar" => Gapic::Examples::UsersScopedInfo.new(scoped_info: "piyo"),
        },
      )
    ]

    fake_service_stub = FakeReGapicServiceStub.new(*api_responses)
    request = Gapic::Examples::GoodPagedRequest.new
    response = Gapic::Examples::GoodMappedPagedResponse.new(
      items: {
        "foo" => Gapic::Examples::UsersScopedInfo.new(scoped_info: "baz"),
        "bar" => Gapic::Examples::UsersScopedInfo.new(scoped_info: "bif"),
      },
      next_page_token: "next"
    )

    options = {}

    result = Gapic::Rest::PagedEnumerable.new(
      fake_service_stub, :call_rest, "items", request, response, options
    )
    kvp_list = result.map { |kvp| [kvp[0], kvp[1].scoped_info] }
    assert_equal [["foo", "baz"], ["bar", "bif"], ["foo", "hoge"], ["bar", "piyo"]].to_set, kvp_list.to_set
  end

  ##
  # Tests that a `PagedEnumerable` wrapping a map field can enumerate all items
  # via a 2-variable block in each: `paged_enumerable.each { |key, value| p key.to_s + value.to_s }`
  #
  def test_enumerates_all_map_pairs_2varblock
    api_responses = [
      Gapic::Examples::GoodMappedPagedResponse.new(
        items: {
          "foo" => Gapic::Examples::UsersScopedInfo.new(scoped_info: "hoge"),
          "bar" => Gapic::Examples::UsersScopedInfo.new(scoped_info: "piyo"),
        },
        )
    ]

    fake_service_stub = FakeReGapicServiceStub.new(*api_responses)
    request = Gapic::Examples::GoodPagedRequest.new
    response = Gapic::Examples::GoodMappedPagedResponse.new(
      items: {
        "foo" => Gapic::Examples::UsersScopedInfo.new(scoped_info: "baz"),
        "bar" => Gapic::Examples::UsersScopedInfo.new(scoped_info: "bif"),
      },
      next_page_token: "next"
    )

    options = {}

    result = Gapic::Rest::PagedEnumerable.new(
      fake_service_stub, :call_rest, "items", request, response, options
    )
    kvp_list = []
    result.each do |key, value|
      kvp_list << [key, value.scoped_info]
    end

    assert_equal [["foo", "baz"], ["bar", "bif"], ["foo", "hoge"], ["bar", "piyo"]].to_set, kvp_list.to_set
  end
end
