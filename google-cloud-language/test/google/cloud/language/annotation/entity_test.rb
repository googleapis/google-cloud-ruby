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

describe Google::Cloud::Language::Annotation::Entity do
  let(:entity_hash) do
    { name: "Utah",
      type: "LOCATION",
      metadata: { wikipedia_url: "https://en.wikipedia.org/wiki/Utah", mid: "/m/07srw" },
      salience: 0.069791436,
      mentions: [{ text: { content: "Utah", beginOffset: -1 }, type: "PROPER" }]
    }
  end
  let(:entity_json) { entity_hash.to_json }
  let(:entity_grpc) { Google::Cloud::Language::V1::Entity.decode_json  entity_json }
  let(:entity)      { Google::Cloud::Language::Annotation::Entity.from_grpc entity_grpc }

  it "has attributes" do
    entity.must_be_kind_of Google::Cloud::Language::Annotation::Entity
    entity.name.must_equal "Utah"
    entity.type.must_equal :LOCATION
    entity.metadata.must_be_kind_of Hash
    entity.wikipedia_url.must_equal "https://en.wikipedia.org/wiki/Utah"
    entity.mid.must_equal "/m/07srw"
    entity.salience.must_be_close_to 0.069791436
    entity.mentions.must_be_kind_of Array
    entity.mentions.count.must_equal 1
    entity.mentions.first.must_be_kind_of Google::Cloud::Language::Annotation::Entity::Mention
    entity.mentions.first.text.must_equal "Utah"
    entity.mentions.first.offset.must_equal -1
    entity.mentions.first.must_be :proper?
    entity.mentions.first.wont_be :common?
    entity.mentions.first.text_span.must_be_kind_of Google::Cloud::Language::Annotation::TextSpan
    entity.mentions.first.text_span.text.must_equal "Utah"
    entity.mentions.first.text_span.offset.must_equal -1
    entity.mentions.first.type.must_equal :PROPER
  end

  it "has helper methods" do
    entity.must_be :location?
    entity.must_be :place?

    entity.wont_be :unknown?
    entity.wont_be :person?
    entity.wont_be :organization?
    entity.wont_be :event?
    entity.wont_be :artwork?
    entity.wont_be :good?
    entity.wont_be :other?
  end
end
