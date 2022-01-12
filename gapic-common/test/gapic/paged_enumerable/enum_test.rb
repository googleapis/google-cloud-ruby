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

describe Gapic::PagedEnumerable, :enumerable do
  it "enumerates all resources" do
    api_responses = [
      Gapic::Examples::GoodPagedResponse.new(
        users: [
          Gapic::Examples::User.new(name: "baz"),
          Gapic::Examples::User.new(name: "bif")
        ]
      )
    ]
    gax_stub = FakeGapicStub.new(*api_responses)
    request = Gapic::Examples::GoodPagedRequest.new
    response = Gapic::Examples::GoodPagedResponse.new(
      users:           [
        Gapic::Examples::User.new(name: "foo"),
        Gapic::Examples::User.new(name: "bar")
      ],
      next_page_token: "next"
    )
    options = Gapic::CallOptions.new
    paged_enum = Gapic::PagedEnumerable.new(
      gax_stub, :method_name, request, response, :fake_operation, options
    )

    assert_equal %w[foo bar baz bif], paged_enum.each.map(&:name)
  end

  it "enumerates all pages" do
    api_responses = [
      Gapic::Examples::GoodPagedResponse.new(
        users: [
          Gapic::Examples::User.new(name: "baz"),
          Gapic::Examples::User.new(name: "bif")
        ]
      )
    ]
    gax_stub = FakeGapicStub.new(*api_responses)
    request = Gapic::Examples::GoodPagedRequest.new
    response = Gapic::Examples::GoodPagedResponse.new(
      users:           [
        Gapic::Examples::User.new(name: "foo"),
        Gapic::Examples::User.new(name: "bar")
      ],
      next_page_token: "next"
    )
    options = Gapic::CallOptions.new
    paged_enum = Gapic::PagedEnumerable.new(
      gax_stub, :method_name, request, response, :fake_operation, options
    )

    assert_equal [["foo", "bar"], ["baz", "bif"]], paged_enum.each_page.map { |page| page.map(&:name) }
  end

  it "enumerates all pages with operations" do
    api_responses = [
      Gapic::Examples::GoodPagedResponse.new(
        users: [
          Gapic::Examples::User.new(name: "baz"),
          Gapic::Examples::User.new(name: "bif")
        ]
      )
    ]
    gax_stub = FakeGapicStub.new(*api_responses)
    request = Gapic::Examples::GoodPagedRequest.new
    response = Gapic::Examples::GoodPagedResponse.new(
      users:           [
        Gapic::Examples::User.new(name: "foo"),
        Gapic::Examples::User.new(name: "bar")
      ],
      next_page_token: "next"
    )
    options = Gapic::CallOptions.new
    paged_enum = Gapic::PagedEnumerable.new(
      gax_stub, :method_name, request, response, :fake_operation, options
    )

    act_res_w_ops = paged_enum.each_page.map do |page|
      [page.map(&:name), page.operation]
    end
    exp_res_w_ops = [[["foo", "bar"], :fake_operation], [["baz", "bif"], :fake_operation_1]]
    assert_equal exp_res_w_ops, act_res_w_ops
  end
end
