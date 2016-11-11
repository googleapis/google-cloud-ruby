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

describe Google::Cloud::Language::Annotation::Syntax do
  let(:syntax_hash) do
    {
      tokens: [{
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
      }],
      language: "en",
      sentences: [{
        text: {
          content: "Hello from Chris and Mike!",
          beginOffset: -1
        }
      }]
    }
  end
  let(:syntax_json) { syntax_hash.to_json }
  let(:syntax_grpc) { Google::Cloud::Language::V1::AnalyzeSyntaxResponse.decode_json syntax_json }
  let(:syntax)      { Google::Cloud::Language::Annotation::Syntax.from_grpc syntax_grpc }

  it "has attributes" do
    syntax.must_be_kind_of Google::Cloud::Language::Annotation::Syntax

    syntax.language.must_equal "en"

    syntax.tokens.count.must_equal 1

    syntax.tokens.first.text.must_equal "Hello"

    syntax.tokens.first.part_of_speech.tag.must_equal :X
    syntax.tokens.first.part_of_speech.aspect.must_equal :PERFECTIVE
    syntax.tokens.first.part_of_speech.case.must_equal :INSTRUMENTAL
    syntax.tokens.first.part_of_speech.form.must_equal :GERUND
    syntax.tokens.first.part_of_speech.gender.must_equal :NEUTER
    syntax.tokens.first.part_of_speech.mood.must_equal :SUBJUNCTIVE
    syntax.tokens.first.part_of_speech.number.must_equal :SINGULAR
    syntax.tokens.first.part_of_speech.person.must_equal :FIRST
    syntax.tokens.first.part_of_speech.proper.must_equal :NOT_PROPER
    syntax.tokens.first.part_of_speech.reciprocity.must_equal :RECIPROCAL
    syntax.tokens.first.part_of_speech.tense.must_equal :IMPERFECT
    syntax.tokens.first.part_of_speech.voice.must_equal :ACTIVE

    syntax.tokens.first.head_token_index.must_equal 0
    syntax.tokens.first.label.must_equal :ROOT
    syntax.tokens.first.lemma.must_equal "Hello"

    syntax.sentences.count.must_equal 1
    syntax.sentences.first.text.must_equal "Hello from Chris and Mike!"
    syntax.sentences.first.offset.must_equal -1
    syntax.sentences.first.wont_be :sentiment?
  end
end
