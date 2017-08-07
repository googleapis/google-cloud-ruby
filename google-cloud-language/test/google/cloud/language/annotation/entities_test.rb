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

describe Google::Cloud::Language::Annotation::Entities do
  let(:entity_json) do
    %{
      {
        "entities": [{
        "name": "Chris",
        "type": "PERSON",
        "metadata": {},
        "salience": 0.5138337,
        "mentions": [{
          "text": {
            "content": "Chris",
            "beginOffset": -1
          },
          "type": "PROPER"
        }]
      }, {
        "name": "Mike",
        "type": "PERSON",
        "metadata": {},
        "salience": 0.1997266,
        "mentions": [{
          "text": {
            "content": "Mike",
            "beginOffset": -1
          },
          "type": "PROPER"
        }]
      }, {
        "name": "Utah",
        "type": "LOCATION",
        "metadata": {
          "wikipedia_url": "https://en.wikipedia.org/wiki/Utah",
          "mid": "/m/07srw"
        },
        "salience": 0.069791436,
        "mentions": [{
          "text": {
            "content": "Utah",
            "beginOffset": -1
          },
          "type": "PROPER"
        }]
      }],
      "language": "en"
      }
    }
  end
  let(:entities_grpc) { Google::Cloud::Language::V1::AnalyzeEntitiesResponse.decode_json entity_json }
  let(:entities)      { Google::Cloud::Language::Annotation::Entities.from_grpc entities_grpc }

  it "has attributes" do
    entities.language.must_equal "en"

    entities.must_be_kind_of ::Array # Because its a DelegateClass(::Array)
    entities.class.must_equal Google::Cloud::Language::Annotation::Entities
    entities.count.must_equal 3
    entities.unknown.map(&:name).must_equal []
    entities.people.map(&:name).must_equal ["Chris", "Mike"]
    entities.locations.map(&:name).must_equal ["Utah"]
    entities.places.map(&:name).must_equal ["Utah"]
    entities.organizations.map(&:name).must_equal []
    entities.events.map(&:name).must_equal []
    entities.artwork.map(&:name).must_equal []
    entities.goods.map(&:name).must_equal []
    entities.other.map(&:name).must_equal []

    entities.places.first.must_be_kind_of Google::Cloud::Language::Annotation::Entity
    entities.places.first.name.must_equal "Utah"
    entities.places.first.type.must_equal :LOCATION
    entities.places.first.metadata.must_equal({"wikipedia_url"=>"https://en.wikipedia.org/wiki/Utah", "mid"=>"/m/07srw"})
    entities.places.first.wikipedia_url.must_equal "https://en.wikipedia.org/wiki/Utah"
    entities.places.first.mid.must_equal "/m/07srw"
    entities.places.first.salience.must_be_close_to 0.069791436
    entities.places.first.mentions.count.must_equal 1
    entities.places.first.mentions.first.text.must_equal "Utah"
    entities.places.first.mentions.first.offset.must_equal -1
    entities.places.first.mentions.first.must_be :proper?
    entities.places.first.mentions.first.wont_be :common?
    entities.places.first.mentions.first.text_span.text.must_equal "Utah"
    entities.places.first.mentions.first.text_span.offset.must_equal -1
    entities.places.first.mentions.first.type.must_equal :PROPER
  end
end
