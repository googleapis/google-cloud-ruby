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

require "language_helper"

describe "Language", :language do
  let(:hello)   { "Hello from Chris and Mike!" }
  let(:sayhi)   { "If you find yourself in Utah, come say hi!" }
  let(:ruby)    { "We love ruby and writing code." }
  let(:content) { "#{hello} #{sayhi} #{ruby}" }

  it "annotation without creating a document" do
    annotation = language.annotate content

    annotation.language.must_equal "en"

    annotation.sentiment.language.must_equal "en"
    annotation.sentiment.polarity.must_equal 1.0
    annotation.sentiment.magnitude.must_equal 2.0999999046325684

    annotation.entities.count.must_equal 3
    annotation.entities.language.must_equal "en"
    annotation.entities.unknown.map(&:name).must_equal []
    annotation.entities.people.map(&:name).must_equal ["Chris", "Mike"]
    annotation.entities.locations.map(&:name).must_equal ["Utah"]
    annotation.entities.places.map(&:name).must_equal ["Utah"]
    annotation.entities.organizations.map(&:name).must_equal []
    annotation.entities.events.map(&:name).must_equal []
    annotation.entities.artwork.map(&:name).must_equal []
    annotation.entities.goods.map(&:name).must_equal []
    annotation.entities.other.map(&:name).must_equal []

    annotation.sentences.map(&:text).must_equal [hello, sayhi, ruby]
    annotation.tokens.count.must_equal 24
    token = annotation.tokens.first
    token.text.must_equal "Hello"
    token.part_of_speech.must_equal :X
    token.head_token_index.must_equal 0
    token.label.must_equal :ROOT
    token.lemma.must_equal "Hello"
  end

  it "annotation with creating a document" do
    doc = language.document content

    annotation = language.annotate doc

    annotation.language.must_equal "en"

    annotation.sentiment.language.must_equal "en"
    annotation.sentiment.polarity.must_be_close_to 1.0
    annotation.sentiment.magnitude.must_be_close_to 2.0999999046325684

    annotation.entities.count.must_equal 3
    annotation.entities.language.must_equal "en"
    annotation.entities.unknown.map(&:name).must_equal []
    annotation.entities.people.map(&:name).must_equal ["Chris", "Mike"]
    annotation.entities.locations.map(&:name).must_equal ["Utah"]
    annotation.entities.places.map(&:name).must_equal ["Utah"]
    annotation.entities.organizations.map(&:name).must_equal []
    annotation.entities.events.map(&:name).must_equal []
    annotation.entities.artwork.map(&:name).must_equal []
    annotation.entities.goods.map(&:name).must_equal []
    annotation.entities.other.map(&:name).must_equal []

    annotation.sentences.map(&:text).must_equal [hello, sayhi, ruby]
    annotation.tokens.count.must_equal 24
    token = annotation.tokens.first
    token.text.must_equal "Hello"
    token.part_of_speech.must_equal :X
    token.head_token_index.must_equal 0
    token.label.must_equal :ROOT
    token.lemma.must_equal "Hello"
  end
end
