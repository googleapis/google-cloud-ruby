# frozen_string_literal: true

# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../../../../helper"

class PredictionServiceSmokeTest < Minitest::Test
  GENERATE_MODEL = "gemini-3.1-flash-lite"
  GENERATE_LOCATION = "global"
  EMBED_MODEL = "gemini-embedding-001"
  EMBED_LOCATION = "us-central1"

  [:grpc, :rest].each do |transport|
    define_method "test_generate_content_#{transport}" do
      verify_generate_content transport
    end

    define_method "test_stream_generate_content_#{transport}" do
      verify_stream_generate_content transport
    end

    define_method "test_embed_content_#{transport}" do
      verify_embed_content transport
    end
  end

  private

  def verify_generate_content transport
    client = AcceptanceHelper.client :prediction_service, location: GENERATE_LOCATION, transport: transport
    model = client.endpoint_path(
      project: AcceptanceHelper.project_id,
      location: GENERATE_LOCATION,
      publisher: "google",
      model: GENERATE_MODEL
    )

    response = client.generate_content(
      model: model,
      contents: [{ role: "user", parts: [{ text: "Reply with the single word: pong" }] }],
      generation_config: { max_output_tokens: 256 }
    )

    refute_empty response.candidates
    text = extract_text [response]
    refute_empty text.strip
  end

  def verify_stream_generate_content transport
    client = AcceptanceHelper.client :prediction_service, location: GENERATE_LOCATION, transport: transport
    model = client.endpoint_path(
      project: AcceptanceHelper.project_id,
      location: GENERATE_LOCATION,
      publisher: "google",
      model: GENERATE_MODEL
    )

    chunks = client.stream_generate_content(
      model: model,
      contents: [{ role: "user", parts: [{ text: "Reply with the single word: ok" }] }],
      generation_config: { max_output_tokens: 256 }
    ).to_a

    refute_empty chunks
    text = extract_text chunks
    refute_empty text.strip
  end

  def verify_embed_content transport
    client = AcceptanceHelper.client :prediction_service, location: EMBED_LOCATION, transport: transport
    model = client.endpoint_path(
      project: AcceptanceHelper.project_id,
      location: EMBED_LOCATION,
      publisher: "google",
      model: EMBED_MODEL
    )

    response = client.embed_content(
      model: model,
      content: { parts: [{ text: "Hello, world!" }] }
    )

    refute_nil response.embedding
    refute_empty response.embedding.values
  end

  def extract_text responses
    responses.flat_map do |response|
      response.candidates.flat_map do |candidate|
        candidate.content&.parts&.filter_map(&:text) || []
      end
    end.join
  end
end
