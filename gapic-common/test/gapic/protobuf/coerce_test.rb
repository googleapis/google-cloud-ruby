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
require "google/protobuf/any_pb"
require "google/protobuf/timestamp_pb"
require "stringio"

class ProtobufCoerceTest < Minitest::Spec
  REQUEST_NAME = "path/to/ernest".freeze
  USER_NAME = "Ernest".freeze
  USER_TYPE = :ADMINISTRATOR
  POST_TEXT = "This is a test post.".freeze
  MAP = {
    "key1" => "val1",
    "key2" => "val2"
  }.freeze

  it "creates a protobuf message from a simple hash" do
    hash = { name: USER_NAME, type: USER_TYPE }
    user = Gapic::Protobuf.coerce hash, to: Gapic::Examples::User
    _(user).must_be_kind_of Gapic::Examples::User
    _(user.name).must_equal USER_NAME
    _(user.type).must_equal USER_TYPE
  end

  it "creates a protobuf message from a hash with a nested message" do
    request_hash = { name: REQUEST_NAME, user: Gapic::Examples::User.new(name: USER_NAME, type: USER_TYPE) }
    request = Gapic::Protobuf.coerce request_hash, to: Gapic::Examples::Request
    _(request).must_be_kind_of Gapic::Examples::Request
    _(request.name).must_equal REQUEST_NAME
    _(request.user).must_be_kind_of Gapic::Examples::User
    _(request.user.name).must_equal USER_NAME
    _(request.user.type).must_equal USER_TYPE
  end

  it "creates a protobuf message from a hash with a nested hash" do
    request_hash = { name: REQUEST_NAME, user: { name: USER_NAME, type: USER_TYPE } }
    request = Gapic::Protobuf.coerce request_hash, to: Gapic::Examples::Request
    _(request).must_be_kind_of Gapic::Examples::Request
    _(request.name).must_equal REQUEST_NAME
    _(request.user).must_be_kind_of Gapic::Examples::User
    _(request.user.name).must_equal USER_NAME
    _(request.user.type).must_equal USER_TYPE
  end

  it "handles nested arrays of both messages and hashes" do
    user_hash = {
      name:  USER_NAME,
      type:  USER_TYPE,
      posts: [
        { text: POST_TEXT },
        Gapic::Examples::Post.new(text: POST_TEXT)
      ]
    }
    user = Gapic::Protobuf.coerce user_hash, to: Gapic::Examples::User
    _(user).must_be_kind_of Gapic::Examples::User
    _(user.name).must_equal USER_NAME
    _(user.type).must_equal USER_TYPE
    _(user.posts).must_be_kind_of Google::Protobuf::RepeatedField
    user.posts.each do |post|
      _(post).must_be_kind_of Gapic::Examples::Post
      _(post.text).must_equal POST_TEXT
    end
  end

  it "handles maps" do
    request_hash = { name: USER_NAME, map_field: MAP }
    user = Gapic::Protobuf.coerce request_hash, to: Gapic::Examples::User
    _(user).must_be_kind_of Gapic::Examples::User
    _(user.name).must_equal USER_NAME
    _(user.map_field).must_be_kind_of Google::Protobuf::Map
    user.map_field.each do |k, v|
      _(MAP[k]).must_equal v
    end
  end

  it "handles IO instances" do
    file = File.new "test/fixtures/fixture_file.txt"
    request_hash = { bytes_field: file }
    user = Gapic::Protobuf.coerce request_hash, to: Gapic::Examples::User
    _(user.bytes_field).must_equal "This is a text file.\n"
  end

  it "handles StringIO instances" do
    expected = "This is a StringIO."
    string_io = StringIO.new expected
    request_hash = { bytes_field: string_io }
    user = Gapic::Protobuf.coerce request_hash, to: Gapic::Examples::User
    _(user.bytes_field).must_equal expected
  end

  it "auto-coerces Time" do
    seconds = 271_828_182
    nanos = 845_904_523
    # Fixnum, not float, for precision
    sometime = seconds + nanos * 10**-9
    request_hash = { timestamp: Time.at(sometime) }
    user = Gapic::Protobuf.coerce request_hash, to: Gapic::Examples::User
    expected = Google::Protobuf::Timestamp.new seconds: seconds, nanos: nanos
    _(user.timestamp).must_equal expected
  end

  it "fails if a key does not exist in the target message type" do
    user_hash = { name: USER_NAME, fake_key: "fake data" }
    expect do
      Gapic::Protobuf.coerce user_hash, to: Gapic::Examples::User
    end.must_raise(ArgumentError)
  end

  it "handles proto messages" do
    user_message = Gapic::Examples::User.new( name: USER_NAME, type: USER_TYPE )
    user = Gapic::Protobuf.coerce user_message, to: Gapic::Examples::User
    _(user).must_equal user_message
  end

  it "fails if proto message has unexpected type" do
    user_message = Google::Protobuf::Any
    expect do
      Gapic::Protobuf.coerce user_message, Gapic::Examples::User
    end.must_raise(ArgumentError)
  end
end
