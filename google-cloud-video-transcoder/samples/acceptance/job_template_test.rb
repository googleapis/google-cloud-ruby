# Copyright 2021 Google, Inc
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
require_relative "../create_job_template"
require_relative "../get_job_template"
require_relative "../list_job_templates"
require_relative "../delete_job_template"

describe "Transcoder Snippets" do
  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT") }
  let(:project_number) { ENV["GOOGLE_CLOUD_PROJECT_NUMBER"] || raise("missing GOOGLE_CLOUD_PROJECT_NUMBER") }
  let(:location_id) { "us-central1" }
  let(:template_id) { "my-template-test-template-#{SecureRandom.hex 4}".downcase }

  describe "create a job template" do
    before do
      delete_job_template(project_id: project_id, location: location_id,
                          template_id: template_id)
    rescue Google::Cloud::NotFoundError
      # Do nothing
    end

    it "creates a job template" do
      expect {
        job_template = create_job_template(project_id: project_id, location: location_id,
                                           template_id: template_id)
        expect(job_template).wont_be_nil
        expect(job_template.name).must_include(project_number)
        expect(job_template.name).must_include(template_id)
      }.must_output(%r{Job template:(.*\s)*projects/#{project_number}/locations/#{location_id}/jobTemplates/#{template_id}})
    end

    after do
      delete_job_template(project_id: project_id, location: location_id,
                          template_id: template_id)
    end
  end

  describe "get a job template" do
    before do
      create_job_template(project_id: project_id, location: location_id,
                          template_id: template_id)
    end

    it "gets a job template" do
      expect {
        job_template = get_job_template(project_id: project_id, location: location_id,
                                        template_id: template_id)
        expect(job_template).wont_be_nil
        expect(job_template.name).must_include(project_number)
        expect(job_template.name).must_include(template_id)
      }.must_output(%r{Job template:(.*\s)*projects/#{project_number}/locations/#{location_id}/jobTemplates/#{template_id}})
    end

    after do
      delete_job_template(project_id: project_id, location: location_id,
                          template_id: template_id)
    end
  end

  describe "list job templates" do
    before do
      create_job_template(project_id: project_id, location: location_id,
                          template_id: template_id)
    end

    it "lists the job templates" do
      expect {
        list_job_templates(project_id: project_id, location: location_id)
      }.must_output(%r{Job templates:(.*\s)*projects/#{project_number}/locations/#{location_id}/jobTemplates/#{template_id}})
    end

    after do
      delete_job_template(project_id: project_id, location: location_id,
                          template_id: template_id)
    end
  end

  describe "delete a job template" do
    before do
      create_job_template(project_id: project_id, location: location_id,
                          template_id: template_id)
    end

    it "deletes a job template" do
      expect {
        delete_job_template(project_id: project_id, location: location_id,
                            template_id: template_id)
      }.must_output(/Deleted job template/)
    end
  end
end
