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
require_relative "../create_job_from_ad_hoc"
require_relative "../create_job_from_preset"
require_relative "../create_job_from_template"
require_relative "../create_job_template"
require_relative "../create_job_with_animated_overlay"
require_relative "../create_job_with_static_overlay"
require_relative "../create_job_with_periodic_images_spritesheet"
require_relative "../create_job_with_set_number_images_spritesheet"
require_relative "../get_job"
require_relative "../get_job_state"
require_relative "../delete_job"
require_relative "../delete_job_template"
require_relative "../list_jobs"

describe "Transcoder Snippets" do
  let(:client) { Google::Cloud::Video::Transcoder.transcoder_service }
  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT") }
  let(:project_number) { ENV["GOOGLE_CLOUD_PROJECT_NUMBER"] || raise("missing GOOGLE_CLOUD_PROJECT_NUMBER") }
  let(:location_id) { "us-central1" }
  let(:bucket_name) { random_bucket_name }
  let(:bucket) { create_bucket_helper bucket_name }
  let(:input_video) { "ChromeCast.mp4" }
  let(:input_overlay) { "overlay.jpg" }
  let :files do
    { input_video: { path: "acceptance/data/#{input_video}" },
      overlay:  { path: "acceptance/data/#{input_overlay}" } }
  end
  let(:input_uri) { "gs://#{bucket_name}/#{input_video}" }
  let(:overlay_uri) { "gs://#{bucket_name}/#{input_overlay}" }
  let(:template_id) { "my-job-test-template-#{SecureRandom.hex 4}".downcase }
  let(:preset) { "preset/web-hd" }
  let(:output_uri_prefix) { "gs://#{bucket_name}" }
  let(:output_uri_for_adhoc) { "#{output_uri_prefix}/test-output-adhoc/" }
  let(:output_uri_for_get_list) { "#{output_uri_prefix}/test-output-get-list/" }
  let(:output_uri_for_delete) { "#{output_uri_prefix}/test-output-delete/" }
  let(:output_uri_for_preset) { "#{output_uri_prefix}/test-output-preset/" }
  let(:output_uri_for_template) { "#{output_uri_prefix}/test-output-template/" }
  let(:job_state_retries) { 4 }
  let(:job_state_succeeded) { "SUCCEEDED" }
  let(:job_state_succeeded_message) { "Job state: #{job_state_succeeded}" }

  before do
    bucket
    original = File.new files[:input_video][:path]
    bucket.create_file original, input_video
    original = File.new files[:overlay][:path]
    bucket.create_file original, input_overlay
  end

  after do
    delete_bucket_helper bucket_name
  end

  # CREATE OPERATIONS

  describe "create a job from an ad-hoc configuration" do
    job_id = ""

    after do
      delete_job project_id: project_id, location: location_id, job_id: job_id
    end

    it "creates an ad-hoc job" do
      expect {
        job = create_job_from_ad_hoc(project_id: project_id, location: location_id,
                                     input_uri: input_uri, output_uri: output_uri_for_adhoc)
        expect(job).wont_be_nil
        expect(job.name).must_include(project_number)
        str_slice = job.name.split "/"
        job_id = str_slice[str_slice.length - 1].rstrip
      }.must_output(%r{Job: projects/#{project_number}/locations/#{location_id}/jobs/})

      state = ""

      job_state_retries.times do
        sleep rand(15..20)
        expect {
          state = get_job_state project_id: project_id, location: location_id, job_id: job_id
        }.must_output(/#{job_state_succeeded_message}/)
        break if state.eql? job_state_succeeded
      end
    end
  end

  describe "create a job from a preset" do
    job_id = ""

    after do
      delete_job project_id: project_id, location: location_id, job_id: job_id
    end

    it "creates a preset job" do
      expect {
        job = create_job_from_preset(project_id: project_id, location: location_id,
                                     input_uri: input_uri, output_uri: output_uri_for_preset, preset: preset)
        expect(job).wont_be_nil
        expect(job.name).must_include(project_number)
        str_slice = job.name.split "/"
        job_id = str_slice[str_slice.length - 1].rstrip
      }.must_output(%r{Job: projects/#{project_number}/locations/#{location_id}/jobs/})

      state = ""

      job_state_retries.times do
        sleep rand(15..20)
        expect {
          state = get_job_state project_id: project_id, location: location_id, job_id: job_id
        }.must_output(/#{job_state_succeeded_message}/)
        break if state.eql? job_state_succeeded
      end
    end
  end

  describe "create a job from a template" do
    job_id = ""

    before do
      delete_job_template(project_id: project_id, location: location_id,
                          template_id: template_id)
    rescue Google::Cloud::NotFoundError
      # Do nothing
      create_job_template(project_id: project_id, location: location_id,
                          template_id: template_id)
    end

    after do
      delete_job project_id: project_id, location: location_id, job_id: job_id
      delete_job_template(project_id: project_id, location: location_id,
                          template_id: template_id)
    end

    it "creates a template job" do
      expect {
        job = create_job_from_template(project_id: project_id, location: location_id,
                                       input_uri: input_uri, output_uri: output_uri_for_template, template_id: template_id)
        expect(job).wont_be_nil
        expect(job.name).must_include(project_number)
        str_slice = job.name.split "/"
        job_id = str_slice[str_slice.length - 1].rstrip
      }.must_output(%r{Job: projects/#{project_number}/locations/#{location_id}/jobs/})

      state = ""

      job_state_retries.times do
        sleep rand(15..20)
        expect {
          state = get_job_state project_id: project_id, location: location_id, job_id: job_id
        }.must_output(/#{job_state_succeeded_message}/)
        break if state.eql? job_state_succeeded
      end
    end
  end

  # GET AND LIST OPERATIONS

  describe "get and list a job" do
    job_id = ""

    before do
      job = create_job_from_ad_hoc(project_id: project_id, location: location_id,
                                   input_uri: input_uri, output_uri: output_uri_for_get_list)
      expect(job).wont_be_nil
      str_slice = job.name.split "/"
      job_id = str_slice[str_slice.length - 1].rstrip
    end

    after do
      delete_job project_id: project_id, location: location_id, job_id: job_id
    end

    it "gets a job" do
      expect {
        job = get_job(project_id: project_id, location: location_id,
                      job_id: job_id)
        expect(job).wont_be_nil
        expect(job.name).must_include(project_number)
      }.must_output(%r{Job:(.*\s)*projects/#{project_number}/locations/#{location_id}/jobs/#{job_id}})
    end

    it "lists a job" do
      expect {
        list_jobs(project_id: project_id, location: location_id)
      }.must_output(%r{Jobs:(.*\s)*projects/#{project_number}/locations/#{location_id}/jobs/#{job_id}})
    end
  end

  # DELETE OPERATION

  describe "delete a job" do
    job_id = ""

    before do
      job = create_job_from_ad_hoc(project_id: project_id, location: location_id,
                                   input_uri: input_uri, output_uri: output_uri_for_delete)
      expect(job).wont_be_nil
      str_slice = job.name.split "/"
      job_id = str_slice[str_slice.length - 1].rstrip
    end

    it "deletes a job" do
      expect {
        delete_job(project_id: project_id, location: location_id,
                   job_id: job_id)
      }.must_output(/Deleted job/)
    end
  end

  # FEATURES

  describe "create a job with an animated overlay" do
    job_id = ""

    after do
      delete_job project_id: project_id, location: location_id, job_id: job_id
    end

    it "creates an animated overlay job" do
      expect {
        job = create_job_with_animated_overlay(project_id: project_id, location: location_id,
                                               input_uri: input_uri, overlay_image_uri: overlay_uri, output_uri: "#{output_uri_prefix}/animated-overlay/")
        expect(job).wont_be_nil
        expect(job.name).must_include(project_number)
        str_slice = job.name.split "/"
        job_id = str_slice[str_slice.length - 1].rstrip
      }.must_output(%r{Job: projects/#{project_number}/locations/#{location_id}/jobs/})

      state = ""

      job_state_retries.times do
        sleep rand(15..20)
        expect {
          state = get_job_state project_id: project_id, location: location_id, job_id: job_id
        }.must_output(/#{job_state_succeeded_message}/)
        break if state.eql? job_state_succeeded
      end
    end
  end

  describe "create a job with a static overlay" do
    job_id = ""

    after do
      delete_job project_id: project_id, location: location_id, job_id: job_id
    end

    it "creates a static overlay job" do
      expect {
        job = create_job_with_static_overlay(project_id: project_id, location: location_id,
                                             input_uri: input_uri, overlay_image_uri: overlay_uri, output_uri: "#{output_uri_prefix}/static-overlay/")
        expect(job).wont_be_nil
        expect(job.name).must_include(project_number)
        str_slice = job.name.split "/"
        job_id = str_slice[str_slice.length - 1].rstrip
      }.must_output(%r{Job: projects/#{project_number}/locations/#{location_id}/jobs/})

      state = ""

      job_state_retries.times do
        sleep rand(15..20)
        expect {
          state = get_job_state project_id: project_id, location: location_id, job_id: job_id
        }.must_output(/#{job_state_succeeded_message}/)
        break if state.eql? job_state_succeeded
      end
    end
  end

  describe "create a job with periodic images spritesheet" do
    job_id = ""

    after do
      delete_job project_id: project_id, location: location_id, job_id: job_id
    end

    it "creates a periodic image spritesheet job" do
      expect {
        job = create_job_with_periodic_images_spritesheet(project_id: project_id, location: location_id,
                                                          input_uri: input_uri, output_uri: "#{output_uri_prefix}/periodic-image-spritesheet/")
        expect(job).wont_be_nil
        expect(job.name).must_include(project_number)
        str_slice = job.name.split "/"
        job_id = str_slice[str_slice.length - 1].rstrip
      }.must_output(%r{Job: projects/#{project_number}/locations/#{location_id}/jobs/})

      state = ""

      job_state_retries.times do
        sleep rand(15..20)
        expect {
          state = get_job_state project_id: project_id, location: location_id, job_id: job_id
        }.must_output(/#{job_state_succeeded_message}/)
        break if state.eql? job_state_succeeded
      end
    end
  end

  describe "create a job with set number of images spritesheet" do
    job_id = ""

    after do
      delete_job project_id: project_id, location: location_id, job_id: job_id
    end

    it "creates a set number image spritesheet job" do
      expect {
        job = create_job_with_set_number_images_spritesheet(project_id: project_id, location: location_id,
                                                            input_uri: input_uri, output_uri: "#{output_uri_prefix}/set-number-image-spritesheet/")
        expect(job).wont_be_nil
        expect(job.name).must_include(project_number)
        str_slice = job.name.split "/"
        job_id = str_slice[str_slice.length - 1].rstrip
      }.must_output(%r{Job: projects/#{project_number}/locations/#{location_id}/jobs/})

      state = ""

      job_state_retries.times do
        sleep rand(15..20)
        expect {
          state = get_job_state project_id: project_id, location: location_id, job_id: job_id
        }.must_output(/#{job_state_succeeded_message}/)
        break if state.eql? job_state_succeeded
      end
    end
  end
end
