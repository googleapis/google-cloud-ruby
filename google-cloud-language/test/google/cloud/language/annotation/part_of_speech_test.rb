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

describe Google::Cloud::Language::Annotation::PartOfSpeech do
  let(:pos_hash) do
    {
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
    }
  end
  let(:pos_json) { pos_hash.to_json }
  let(:pos_grpc) { Google::Cloud::Language::V1::PartOfSpeech.decode_json pos_json }
  let(:part_of_speech) { Google::Cloud::Language::Annotation::PartOfSpeech.from_grpc pos_grpc }

  it "has attributes" do
    part_of_speech.must_be_kind_of Google::Cloud::Language::Annotation::PartOfSpeech

    part_of_speech.tag.must_equal :X
    part_of_speech.aspect.must_equal :PERFECTIVE
    part_of_speech.case.must_equal :INSTRUMENTAL
    part_of_speech.form.must_equal :GERUND
    part_of_speech.gender.must_equal :NEUTER
    part_of_speech.mood.must_equal :SUBJUNCTIVE
    part_of_speech.number.must_equal :SINGULAR
    part_of_speech.person.must_equal :FIRST
    part_of_speech.proper.must_equal :NOT_PROPER
    part_of_speech.reciprocity.must_equal :RECIPROCAL
    part_of_speech.tense.must_equal :IMPERFECT
    part_of_speech.voice.must_equal :ACTIVE
  end
end
