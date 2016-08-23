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

describe Google::Cloud::Language::Annotation::Sentiment do
  let(:sentiment_hash) do
    {
      documentSentiment: { polarity: 1, magnitude: 2.0999999 },
      language: "en"
    }
  end
  let(:sentiment_json) { sentiment_hash.to_json }
  let(:sentiment_grpc) { Google::Cloud::Language::V1beta1::AnalyzeSentimentResponse.decode_json sentiment_json }
  let(:sentiment)      { Google::Cloud::Language::Annotation::Sentiment.from_grpc sentiment_grpc }

  it "has attributes" do
    sentiment.must_be_kind_of Google::Cloud::Language::Annotation::Sentiment

    sentiment.language.must_equal "en"
    sentiment.polarity.must_equal 1.0
    sentiment.magnitude.must_equal 2.0999999046325684
  end
end
