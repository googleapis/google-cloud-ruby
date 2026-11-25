# frozen_string_literal: true

# Copyright 2020 Google LLC
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

require "helper"
require "ostruct"
require "google/cloud/translate"
require "google/cloud/translate/v2"

class Google::Cloud::Translate::HelpersMinitest < Minitest::Test
  def setup
    @original_env_universe = ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"]
    ENV.delete "GOOGLE_CLOUD_UNIVERSE_DOMAIN"
    Google::Cloud.configure.reset!
    # Re-register V2 config fields on reset
    Google::Cloud::Translate.configure do |config|
      config.add_field! :project_id, nil, match: ::String unless config.respond_to? :project_id
      config.add_field! :key,        nil, match: ::String unless config.respond_to? :key
      config.add_field! :retries,    nil, match: ::Integer unless config.respond_to? :retries
    end
  end

  def teardown
    if @original_env_universe.nil?
      ENV.delete "GOOGLE_CLOUD_UNIVERSE_DOMAIN"
    else
      ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = @original_env_universe
    end
    Google::Cloud.configure.reset!
  end

  def dummy_credentials universe_domain: nil
    creds = if universe_domain
              OpenStruct.new empty: true, universe_domain: universe_domain
            else
              OpenStruct.new empty: true
            end
    def creds.is_a? target
      target == Google::Auth::Credentials
    end
    creds
  end

  def test_translation_v2_service
    # Clear all environment variables
    ENV.stub :[], nil do
      # Get project_id from Google Compute Engine
      Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
        Google::Cloud::Translate::V2::Credentials.stub :default, dummy_credentials do
          client = Google::Cloud::Translate.translation_v2_service
          assert_kind_of Google::Cloud::Translate::V2::Api, client
          assert_equal "googleapis.com", client.universe_domain
        end
      end
    end
  end

  def test_translation_v2_service_omits_universe_domain_when_unset_or_blank_env
    ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = "   "
    captured_kwargs = nil
    stubbed_new = ->(**kwargs) {
      captured_kwargs = kwargs
      :fake_api
    }
    Google::Cloud::Translate::V2.stub :new, stubbed_new do
      result = Google::Cloud::Translate.translation_v2_service project_id: "proj"
      assert_equal :fake_api, result
    end
    refute captured_kwargs.key?(:universe_domain)
  end

  def test_translation_v2_service_forwards_universe_domain_precedence
    ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = "env-universe.com"
    env_creds = dummy_credentials universe_domain: "env-universe.com"
    client_env = Google::Cloud::Translate.translation_v2_service project_id: "proj", credentials: env_creds
    assert_equal "env-universe.com", client_env.universe_domain

    Google::Cloud::Translate.configure.universe_domain = "cfg-universe.com"
    cfg_creds = dummy_credentials universe_domain: "cfg-universe.com"
    client_cfg = Google::Cloud::Translate.translation_v2_service project_id: "proj", credentials: cfg_creds
    assert_equal "cfg-universe.com", client_cfg.universe_domain

    arg_creds = dummy_credentials universe_domain: "arg-universe.com"
    client_arg = Google::Cloud::Translate.translation_v2_service(
      project_id: "proj",
      credentials: arg_creds,
      universe_domain: "arg-universe.com"
    )
    assert_equal "arg-universe.com", client_arg.universe_domain
  end

  def test_translation_v2_service_validates_universe_domain_mismatch_and_empty_string
    Google::Cloud::Translate.configure.universe_domain = "cfg-universe.com"
    gdu_creds = dummy_credentials universe_domain: "googleapis.com"
    err = assert_raises Google::Cloud::Error do
      Google::Cloud::Translate.translation_v2_service project_id: "proj", credentials: gdu_creds
    end
    assert_includes err.message, "Universe domain is cfg-universe.com but credentials are in googleapis.com"

    assert_raises ArgumentError do
      Google::Cloud::Translate.translation_v2_service(
        project_id: "proj",
        credentials: gdu_creds,
        universe_domain: ""
      )
    end
  end
end
