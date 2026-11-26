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

class SmokeTest < Minitest::Test
  SMOKE_LOCATION = "us-east1"

  SMOKE_CASES = [
    [:dataset_service, :list_datasets],
    [:endpoint_service, :list_endpoints],
    [:job_service, :list_batch_prediction_jobs],
    [:job_service, :list_custom_jobs],
    [:job_service, :list_hyperparameter_tuning_jobs],
    [:migration_service, :search_migratable_resources],
    [:model_service, :list_models],
    [:pipeline_service, :list_training_pipelines]
  ].freeze

  SMOKE_CASES.each do |service, rpc|
    [:grpc, :rest].each do |transport|
      define_method "test_#{service}_#{rpc}_#{transport}" do
        client = AcceptanceHelper.client service, location: SMOKE_LOCATION, transport: transport
        parent = "projects/#{AcceptanceHelper.project_id}/locations/#{SMOKE_LOCATION}"
        response = client.public_send rpc, parent: parent, page_size: 1
        expected_class = transport == :rest ? Gapic::Rest::PagedEnumerable : Gapic::PagedEnumerable
        assert_kind_of expected_class, response
        refute_nil response.response
      end
    end
  end
end
