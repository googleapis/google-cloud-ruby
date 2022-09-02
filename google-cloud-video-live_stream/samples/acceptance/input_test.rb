# Copyright 2022 Google, Inc
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
require_relative "../create_input"
require_relative "../update_input"
require_relative "../get_input"
require_relative "../delete_input"
require_relative "../list_inputs"

describe "Livestream Snippets" do
  let(:client) { Google::Cloud::Video::LiveStream.livestream_service }
  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT") }
  let(:location_id) { "us-central1" }
  let(:input_id) { "my-input-test-#{SecureRandom.hex 4}".downcase }

  # CREATE OPERATIONS

  describe "create an input" do
    before do
      delete_input(project_id: project_id, location: location_id,
                   input_id: input_id)
    rescue Google::Cloud::NotFoundError
      # Do nothing
    end

    it "creates an input" do
      expect {
        input = create_input(project_id: project_id, location: location_id,
                             input_id: input_id)
        expect(input).wont_be_nil
        expect(input.name).must_include(project_id)
        expect(input.name).must_include(input_id)
      }.must_output(%r{Input:(.*\s)*projects/#{project_id}/locations/#{location_id}/inputs/#{input_id}})
    end

    after do
      delete_input(project_id: project_id, location: location_id,
                   input_id: input_id)
    end
  end

  # GET AND LIST OPERATIONS

  describe "list, update, and get an input" do
    before do
      input = create_input(project_id: project_id, location: location_id,
                           input_id: input_id)
      expect(input).wont_be_nil
    end

    it "lists a input" do
      expect {
        list_inputs(project_id: project_id, location: location_id)
      }.must_output(%r{Inputs:(.*\s)*projects/#{project_id}/locations/#{location_id}/inputs/#{input_id}})
    end

    it "updates an input" do
      expect {
        input = update_input(project_id: project_id, location: location_id,
                             input_id: input_id)
        expect(input).wont_be_nil
        expect(input.name).must_include(project_id)
        expect(input.preprocessing_config.crop.top_pixels).must_equal 5
      }.must_output(%r{Updated input:(.*\s)*projects/#{project_id}/locations/#{location_id}/inputs/#{input_id}})
    end

    it "gets an input" do
      expect {
        input = get_input(project_id: project_id, location: location_id,
                          input_id: input_id)
        expect(input).wont_be_nil
        expect(input.name).must_include(project_id)
      }.must_output(%r{Input:(.*\s)*projects/#{project_id}/locations/#{location_id}/inputs/#{input_id}})
    end

    after do
      delete_input(project_id: project_id, location: location_id,
                   input_id: input_id)
    end
  end

  # # DELETE OPERATION

  describe "delete an input" do
    before do
      input = create_input(project_id: project_id, location: location_id,
                           input_id: input_id)
      expect(input).wont_be_nil
    end

    it "deletes an input" do
      expect {
        delete_input(project_id: project_id, location: location_id,
                     input_id: input_id)
      }.must_output(/Deleted input/)
    end
  end
end
