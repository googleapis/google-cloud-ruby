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

describe Google::Cloud::Language::Annotation::Token do
  let(:token_hash) do
    {
      text: {
        content: "Hello",
        beginOffset: -1
      },
      partOfSpeech: {
        tag: "X",
        aspect: "PERFECTIVE",
        case: "INSTRUMENTAL",
        form: "GERUND",
        gender: "NEUTER",
        mood: "SUBJUNCTIVE",
        number: "SINGULAR",
        person: "FIRST",
        proper: "NOT_PROPER",
        reciprocity: "RECIPROCAL",
        tense: "IMPERFECT",
        voice: "ACTIVE"
      },
      dependencyEdge: {
        label: "ROOT"
      },
      lemma: "Hello"
    }
  end
  let(:token_json) { token_hash.to_json }
  let(:token_grpc) { Google::Cloud::Language::V1::Token.decode_json  token_json }
  let(:token)      { Google::Cloud::Language::Annotation::Token.from_grpc token_grpc }

  it "has attributes" do
    token.must_be_kind_of Google::Cloud::Language::Annotation::Token

    token.text.must_equal "Hello"

    token.part_of_speech.tag.must_equal :X
    token.part_of_speech.aspect.must_equal :PERFECTIVE
    token.part_of_speech.case.must_equal :INSTRUMENTAL
    token.part_of_speech.form.must_equal :GERUND
    token.part_of_speech.gender.must_equal :NEUTER
    token.part_of_speech.mood.must_equal :SUBJUNCTIVE
    token.part_of_speech.number.must_equal :SINGULAR
    token.part_of_speech.person.must_equal :FIRST
    token.part_of_speech.proper.must_equal :NOT_PROPER
    token.part_of_speech.reciprocity.must_equal :RECIPROCAL
    token.part_of_speech.tense.must_equal :IMPERFECT
    token.part_of_speech.voice.must_equal :ACTIVE

    token.head_token_index.must_equal 0
    token.label.must_equal :ROOT
    token.lemma.must_equal "Hello"
  end
end
