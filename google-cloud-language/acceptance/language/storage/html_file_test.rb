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

describe "Language (HTML/Storage File)", :language do
  let(:hello)   { "Hello from Chris and Mike!" }
  let(:sayhi)   { "If you find yourself in <strong>Utah</strong>, come say hi!" }
  let(:ruby)    { "We <em>love</em> ruby and writing code." }
  let(:content) { "<html><head><title>#{hello}</title></head>" + \
                  "<body><h1>#{sayhi}</h1><p>#{ruby}</p></body></html>" }

  let(:storage) { Google::Cloud.storage }
  let(:bucket)  { storage.bucket($lang_prefix) || storage.create_bucket($lang_prefix) }
  let(:file_io) { t = Tempfile.new(["language", ".html"]); t.write content.encode("UTF-8"); t.rewind; t }
  let(:file)    { bucket.file("language.html") || bucket.create_file(file_io, "language.html") }
  let(:url)     { file.to_gs_url }

  describe "annotation" do
    it "works without creating a document" do
      annotation = language.annotate file, format: :html

      annotation.language.must_equal "en"

      annotation.sentiment.language.must_equal "en"
      annotation.sentiment.polarity.must_be_close_to 1.0
      annotation.sentiment.magnitude.must_be_close_to 1.899999976158142

      annotation.entities.count.must_equal 2
      annotation.entities.language.must_equal "en"
      annotation.entities.unknown.map(&:name).must_equal []
      annotation.entities.people.map(&:name).must_equal ["chris"]
      annotation.entities.locations.map(&:name).must_equal ["utah"]
      annotation.entities.places.map(&:name).must_equal ["utah"]
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

    it "works with creating a document" do
      doc = language.document file
      doc.must_be :html?
      doc.wont_be :text?

      annotation = language.annotate doc

      annotation.language.must_equal "en"

      annotation.sentiment.language.must_equal "en"
      annotation.sentiment.polarity.must_be_close_to 1.0
      annotation.sentiment.magnitude.must_be_close_to 1.899999976158142

      annotation.entities.count.must_equal 2
      annotation.entities.language.must_equal "en"
      annotation.entities.unknown.map(&:name).must_equal []
      annotation.entities.people.map(&:name).must_equal ["chris"]
      annotation.entities.locations.map(&:name).must_equal ["utah"]
      annotation.entities.places.map(&:name).must_equal ["utah"]
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

    it "works with creating a document with format and language options" do
      doc = language.document file, format: :html, language: :en
      doc.must_be :html?
      doc.wont_be :text?

      annotation = language.annotate doc

      annotation.language.must_equal "en"

      annotation.sentiment.language.must_equal "en"
      annotation.sentiment.polarity.must_be_close_to 1.0
      annotation.sentiment.magnitude.must_be_close_to 1.899999976158142

      annotation.entities.count.must_equal 2
      annotation.entities.language.must_equal "en"
      annotation.entities.unknown.map(&:name).must_equal []
      annotation.entities.people.map(&:name).must_equal ["chris"]
      annotation.entities.locations.map(&:name).must_equal ["utah"]
      annotation.entities.places.map(&:name).must_equal ["utah"]
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

    it "works with creating a document using #text helper method" do
      doc = language.html file
      doc.must_be :html?
      doc.wont_be :text?

      annotation = language.annotate doc

      annotation.language.must_equal "en"

      annotation.sentiment.language.must_equal "en"
      annotation.sentiment.polarity.must_be_close_to 1.0
      annotation.sentiment.magnitude.must_be_close_to 1.899999976158142

      annotation.entities.count.must_equal 2
      annotation.entities.language.must_equal "en"
      annotation.entities.unknown.map(&:name).must_equal []
      annotation.entities.people.map(&:name).must_equal ["chris"]
      annotation.entities.locations.map(&:name).must_equal ["utah"]
      annotation.entities.places.map(&:name).must_equal ["utah"]
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

    it "runs only the text feature" do
      doc = language.document file, format: :text
      doc.html!
      doc.must_be :html?
      doc.wont_be :text?

      annotation = doc.annotate text: true

      annotation.language.must_equal "en"

      annotation.sentiment.must_be :nil?

      annotation.entities.must_be :empty?

      annotation.sentences.map(&:text).must_equal [hello, sayhi, ruby]
      annotation.tokens.count.must_equal 24
      token = annotation.tokens.first
      token.text.must_equal "Hello"
      token.part_of_speech.must_equal :X
      token.head_token_index.must_equal 0
      token.label.must_equal :ROOT
      token.lemma.must_equal "Hello"
    end

    it "runs only the sentiment feature" do
      doc = language.document file, format: :text
      doc.format = :html
      doc.must_be :html?
      doc.wont_be :text?

      annotation = doc.annotate sentiment: true

      annotation.language.must_equal "en"

      annotation.sentiment.language.must_equal "en"
      annotation.sentiment.polarity.must_be_close_to 1.0
      annotation.sentiment.magnitude.must_be_close_to 1.899999976158142

      annotation.entities.must_be :empty?

      annotation.sentences.must_be :empty?
      annotation.tokens.must_be :empty?
    end

    it "runs only the entities feature" do
      doc = language.document file, format: :html
      doc.must_be :html?
      doc.wont_be :text?

      annotation = doc.annotate entities: true

      annotation.language.must_equal "en"

      annotation.sentiment.must_be :nil?

      annotation.entities.count.must_equal 2
      annotation.entities.language.must_equal "en"
      annotation.entities.unknown.map(&:name).must_equal []
      annotation.entities.people.map(&:name).must_equal ["chris"]
      annotation.entities.locations.map(&:name).must_equal ["utah"]
      annotation.entities.places.map(&:name).must_equal ["utah"]
      annotation.entities.organizations.map(&:name).must_equal []
      annotation.entities.events.map(&:name).must_equal []
      annotation.entities.artwork.map(&:name).must_equal []
      annotation.entities.goods.map(&:name).must_equal []
      annotation.entities.other.map(&:name).must_equal []

      annotation.sentences.must_be :empty?
      annotation.tokens.must_be :empty?
    end
  end

  describe "entities" do
    it "works without creating a document" do
      entities = language.entities file, format: :html

      entities.language.must_equal "en"

      entities.count.must_equal 2
      entities.language.must_equal "en"
      entities.unknown.map(&:name).must_equal []
      entities.people.map(&:name).must_equal ["chris"]
      entities.locations.map(&:name).must_equal ["utah"]
      entities.places.map(&:name).must_equal ["utah"]
      entities.organizations.map(&:name).must_equal []
      entities.events.map(&:name).must_equal []
      entities.artwork.map(&:name).must_equal []
      entities.goods.map(&:name).must_equal []
      entities.other.map(&:name).must_equal []
    end

    it "works with creating a document" do
      doc = language.document file
      doc.must_be :html?
      doc.wont_be :text?

      entities = doc.entities

      entities.language.must_equal "en"

      entities.count.must_equal 2
      entities.language.must_equal "en"
      entities.unknown.map(&:name).must_equal []
      entities.people.map(&:name).must_equal ["chris"]
      entities.locations.map(&:name).must_equal ["utah"]
      entities.places.map(&:name).must_equal ["utah"]
      entities.organizations.map(&:name).must_equal []
      entities.events.map(&:name).must_equal []
      entities.artwork.map(&:name).must_equal []
      entities.goods.map(&:name).must_equal []
      entities.other.map(&:name).must_equal []

      entities.places.first.name.must_equal "utah"
      entities.places.first.type.must_equal :LOCATION
      entities.places.first.metadata.must_equal({"wikipedia_url"=>"http://en.wikipedia.org/wiki/Utah"})
      entities.places.first.wikipedia_url.must_equal "http://en.wikipedia.org/wiki/Utah"
      entities.places.first.salience.must_be_close_to 0.06173757091164589
      entities.places.first.mentions.count.must_equal 1
      entities.places.first.mentions.first.text.must_equal "Utah"
      entities.places.first.mentions.first.offset.must_equal 102
    end
  end

  describe "sentiment" do
    it "works without creating a document" do
      sentiment = language.sentiment file, format: :html

      sentiment.language.must_equal "en"

      sentiment.polarity.must_be_close_to 1.0
      sentiment.magnitude.must_be_close_to 1.899999976158142
    end

    it "works with creating a document" do
      doc = language.document file
      doc.must_be :html?
      doc.wont_be :text?

      sentiment = doc.sentiment

      sentiment.language.must_equal "en"

      sentiment.polarity.must_be_close_to 1.0
      sentiment.magnitude.must_be_close_to 1.899999976158142
    end
  end
end
