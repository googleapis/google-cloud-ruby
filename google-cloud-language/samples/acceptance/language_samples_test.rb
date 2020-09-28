# Copyright 2020 Google, LLC
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

require_relative "helper"
require_relative "../language_samples.rb"

describe "Language Snippets" do
  parallelize_me!

  describe "sentiment_from_text" do
    it "puts the overall document sentiment" do
      assert_output(/Overall document sentiment: \(\d\.\d+\)$/) do
        sentiment_from_text text_content: positive_text
      end

      assert_output(/Overall document sentiment: \(-\d\.\d+\)$/) do
        sentiment_from_text text_content: negative_text
      end
    end

    it "puts the sentence level document sentiment" do
      assert_output(/Happy love it.: \(\d\.\d+\)$/) do
        sentiment_from_text text_content: positive_text
      end

      assert_output(/I hate it.: \(-\d\.\d+\)$/) do
        sentiment_from_text text_content: negative_text
      end
    end
  end

  describe "sentiment_from_cloud_storage_file" do
    it "puts the overall document sentiment" do
      assert_output(/Overall document sentiment: \(\d\.\d+\)$/) do
        sentiment_from_cloud_storage_file storage_path: "gs://#{bucket_name}/positive.txt"
      end

      assert_output(/Overall document sentiment: \(-\d\.\d+\)$/) do
        sentiment_from_cloud_storage_file storage_path: "gs://#{bucket_name}/negative.txt"
      end
    end

    it "puts the sentence level document sentiment" do
      assert_output(/Happy love it.: \(\d\.\d+\)$/) do
        sentiment_from_cloud_storage_file storage_path: "gs://#{bucket_name}/positive.txt"
      end

      assert_output(/I hate it.: \(-\d\.\d+\)$/) do
        sentiment_from_cloud_storage_file storage_path: "gs://#{bucket_name}/negative.txt"
      end
    end
  end

  describe "entities_from_text" do
    it "correctly labels people within a text" do
      out, _err = capture_io do
        entities_from_text text_content: entities_text
      end
      assert_includes out, "Alice PERSON"
      assert_includes out, "Bob PERSON"
    end

    it "puts the sentence level document sentiment" do
      out, _err = capture_io do
        entities_from_text text_content: "William Shakespeare is great."
      end
      assert_includes out, "William Shakespeare PERSON"
      assert_match %r{wikipedia.org/wiki/.*Shakespeare}, out
    end
  end

  describe "entities_from_cloud_storage_file" do
    it "correctly labels people within a cloud storage file" do
      out, _err = capture_io do
        entities_from_cloud_storage_file storage_path: "gs://#{bucket_name}/entities.txt"
      end
      assert_includes out, "Alice PERSON"
      assert_includes out, "Bob PERSON"
    end
  end

  describe "syntax_from_text" do
    it "identifies the syntax of a text" do
      out, _err = capture_io do
        syntax_from_text text_content: syntax_text
      end

      assert_includes out, "Sentences: 2"
      assert_includes out, "Tokens: 12"
      assert_includes out, "PRON I"
      assert_includes out, "VERB am"
      assert_includes out, "NOUN Fox"
    end
  end

  describe "syntax_from_cloud_storage_file" do
    it "identifies the syntax of a cloud storage file" do
      out, _err = capture_io do
        syntax_from_cloud_storage_file storage_path: "gs://#{bucket_name}/syntax.txt"
      end

      assert_includes out, "Sentences: 2"
      assert_includes out, "Tokens: 12"
      assert_includes out, "PRON I"
      assert_includes out, "VERB am"
      assert_includes out, "NOUN Fox"
    end
  end

  describe "classify_text" do
    it "classifies a text" do
      out, _err = capture_io do
        classify_text text_content: classification_text
      end

      assert_includes out, "Computers & Electronics"
    end
  end

  describe "classify_text_from_cloud_storage_file" do
    it "classifies the content of a cloud storage file" do
      out, _err = capture_io do
        classify_text_from_cloud_storage_file storage_path: "gs://#{bucket_name}/classify.txt"
      end

      assert_includes out, "Computers & Electronics"
    end
  end

  describe "analyze_entity_sentiment" do
    it "analyzes the sentiment for each entity in a text" do
      out, _err = capture_io do
        analyze_entity_sentiment text_content: entities_sentiment_text
      end
      assert_match(/Entity: Plums Sentiment: \d\.\d+/, out)
      assert_match(/Entity: Prunes Sentiment: -\d\.\d+/, out)
    end
  end

  describe "analyze_entity_sentiment_from_storage_file" do
    it "analyzes the sentiment for each entity in a storage file" do
      out, _err = capture_io do
        analyze_entity_sentiment_from_storage_file storage_path: "gs://#{bucket_name}/entity_sentiment.txt"
      end
      assert_match(/Entity: Plums Sentiment: \d\.\d+/, out)
      assert_match(/Entity: Prunes Sentiment: -\d\.\d+/, out)
    end
  end
end
