# Copyright 2016 Google Inc. All rights reserved.
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

describe Google::Cloud::Language::Annotation::Entity::Mention do
  let(:mention_hash) do
    {
      text: {
        content: "Ernest",
        beginOffset: -1
      },
      type: :PROPER
    }
  end
  let(:mention_json) { mention_hash.to_json }
  let(:mention_grpc) { Google::Cloud::Language::V1::EntityMention.decode_json  mention_json }
  let(:mention)      { Google::Cloud::Language::Annotation::Entity::Mention.from_grpc mention_grpc }

  it "has attributes" do
    mention.must_be_kind_of Google::Cloud::Language::Annotation::Entity::Mention

    mention.text_span.content.must_equal "Ernest"
    mention.text_span.offset.must_equal       -1
    mention.text_span.begin_offset.must_equal -1
    mention.text.must_equal "Ernest"
    mention.type.must_equal :PROPER
    mention.offset.must_equal       -1
    mention.begin_offset.must_equal -1
    mention.must_be :proper?
    mention.wont_be :common?
  end
end
