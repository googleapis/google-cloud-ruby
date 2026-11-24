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
require "google/cloud/translate/v2"

describe Google::Cloud::Translate::V2 do
  before do
    @original_env_universe = ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"]
    ENV.delete "GOOGLE_CLOUD_UNIVERSE_DOMAIN"
    Google::Cloud.configure.reset!
  end

  after do
    if @original_env_universe.nil?
      ENV.delete "GOOGLE_CLOUD_UNIVERSE_DOMAIN"
    else
      ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = @original_env_universe
    end
    Google::Cloud.configure.reset!
  end

  describe ".new" do
    let(:default_credentials) do
      creds = OpenStruct.new empty: true
      def creds.is_a? target
        target == Google::Auth::Credentials
      end
      creds
    end
    let(:found_credentials) { "{}" }

    it "gets defaults for api key" do
      stubbed_env = ->(name) {
        "found-api-key" if name == "GOOGLE_CLOUD_KEY"
      }
      stubbed_service = ->(project_id, credentials, retries: nil, timeout: nil, host: nil, key: nil, universe_domain: nil) {
        _(key).must_equal "found-api-key"
        _(project_id).must_be :empty?
        _(credentials).must_be :nil?
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        _(universe_domain).must_be :nil?
        OpenStruct.new key: key
      }

      # Prevent return of actual project in any environment including GCE, etc.
      Google::Cloud::Translate::V2.stub :default_project_id, nil do
        # Clear all environment variables
        ENV.stub :[], stubbed_env do
          Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
            translate = Google::Cloud::Translate::V2.new
            _(translate).must_be_kind_of Google::Cloud::Translate::V2::Api
            _(translate.service).must_be_kind_of OpenStruct
            _(translate.service.key).must_equal "found-api-key"
          end
        end
      end
    end

    it "uses provided api key" do
      stubbed_service = ->(project_id, credentials, retries: nil, timeout: nil, host: nil, key: nil, universe_domain: nil) {
        _(key).must_equal "my-api-key"
        _(project_id).must_be :empty?
        _(credentials).must_be :nil?
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        _(universe_domain).must_be :nil?
        OpenStruct.new key: key
      }

      # Prevent return of actual project in any environment including GCE, etc.
      Google::Cloud::Translate::V2.stub :default_project_id, nil do
        # Clear all environment variables
        ENV.stub :[], nil do
          Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
            translate = Google::Cloud::Translate::V2.new key: "my-api-key"
            _(translate).must_be_kind_of Google::Cloud::Translate::V2::Api
            _(translate.service).must_be_kind_of OpenStruct
            _(translate.service.key).must_equal "my-api-key"
          end
        end
      end
    end

    it "passes universe_domain when using api key" do
      stubbed_service = ->(project_id, credentials, retries: nil, timeout: nil, host: nil, key: nil, universe_domain: nil) {
        _(key).must_equal "my-api-key"
        _(project_id).must_be :empty?
        _(credentials).must_be :nil?
        _(universe_domain).must_equal "myuniverse.com"
        OpenStruct.new key: key, universe_domain: universe_domain
      }

      Google::Cloud::Translate::V2.stub :default_project_id, nil do
        ENV.stub :[], nil do
          Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
            translate = Google::Cloud::Translate::V2.new key: "my-api-key", universe_domain: "myuniverse.com"
            _(translate.universe_domain).must_equal "myuniverse.com"
          end
        end
      end
    end

    it "gets defaults for project_id and credentials" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Translate::V2::Credentials.stub :default, default_credentials do
            translate = Google::Cloud::Translate::V2.new
            _(translate).must_be_kind_of Google::Cloud::Translate::V2::Api
            _(translate.project_id).must_equal "project-id"
            _(translate.universe_domain).must_equal "googleapis.com"
            _(translate.service.credentials).must_equal default_credentials
          end
        end
      end
    end

    it "enables self-signed JWT by default when using default endpoint" do
      ENV.stub :[], nil do
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          stubbed_default = ->(options = {}) {
            _(options[:enable_self_signed_jwt]).must_equal true
            default_credentials
          }
          Google::Cloud::Translate::V2::Credentials.stub :default, stubbed_default do
            Google::Cloud::Translate::V2.new
          end
        end
      end
    end

    it "does not enable self-signed JWT when using custom endpoint" do
      ENV.stub :[], nil do
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          stubbed_default = ->(options = {}) {
            _(options[:enable_self_signed_jwt]).must_equal false
            default_credentials
          }
          Google::Cloud::Translate::V2::Credentials.stub :default, stubbed_default do
            Google::Cloud::Translate::V2.new endpoint: "custom-endpoint.com"
          end
        end
      end
    end

    it "computes enable_self_signed_jwt against the resolved universe default host" do
      ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = "myuniverse.com"
      Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
        stubbed_default_true = ->(options = {}) {
          _(options[:enable_self_signed_jwt]).must_equal true
          default_credentials
        }
        Google::Cloud::Translate::V2::Credentials.stub :default, stubbed_default_true do
          Google::Cloud::Translate::V2.new
          Google::Cloud::Translate::V2.new endpoint: "translate.myuniverse.com"
        end

        stubbed_default_false = ->(options = {}) {
          _(options[:enable_self_signed_jwt]).must_equal false
          default_credentials
        }
        Google::Cloud::Translate::V2::Credentials.stub :default, stubbed_default_false do
          Google::Cloud::Translate::V2.new endpoint: "translate.googleapis.com"
        end
      end
    end

    it "uses provided project_id and credentials" do
      stubbed_credentials = ->(keyfile, options = {}) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(options[:scope]).must_be :nil?
        "translate-credentials"
      }
      stubbed_service = ->(project_id, credentials, scope: nil, key: nil, retries: nil, timeout: nil, host: nil, universe_domain: nil) {
        _(project_id).must_equal "project-id"
        _(credentials).must_equal "translate-credentials"
        _(scope).must_be :nil?
        _(key).must_be :nil?
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        _(universe_domain).must_be :nil?
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Translate::V2::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
                translate = Google::Cloud::Translate::V2.new project_id: "project-id", credentials: "path/to/keyfile.json"
                _(translate).must_be_kind_of Google::Cloud::Translate::V2::Api
                _(translate.project_id).must_equal "project-id"
                _(translate.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "gets project_id from credentials" do
      stubbed_credentials = ->(keyfile, options = {}) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(options[:scope]).must_be :nil?
        OpenStruct.new project_id: "project-id"
      }
      stubbed_service = ->(project_id, credentials, scope: nil, key: nil, retries: nil, timeout: nil, host: nil, universe_domain: nil) {
        _(project_id).must_equal "project-id"
        _(credentials).must_be_kind_of OpenStruct
        _(credentials.project_id).must_equal "project-id"
        _(scope).must_be :nil?
        _(key).must_be :nil?
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        _(universe_domain).must_be :nil?
        OpenStruct.new project_id: project_id
      }
      empty_env = OpenStruct.new

      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud.stub :env, empty_env do
          File.stub :file?, true, ["path/to/keyfile.json"] do
            File.stub :read, found_credentials, ["path/to/keyfile.json"] do
              Google::Cloud::Translate::V2::Credentials.stub :new, stubbed_credentials do
                Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
                  translate = Google::Cloud::Translate::V2.new credentials: "path/to/keyfile.json"
                  _(translate).must_be_kind_of Google::Cloud::Translate::V2::Api
                  _(translate.project_id).must_equal "project-id"
                  _(translate.service).must_be_kind_of OpenStruct
                end
              end
            end
          end
        end
      end
    end

    it "uses provided endpoint" do
      stubbed_credentials = ->(keyfile, options = {}) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(options[:scope]).must_be :nil?
        "translate-credentials"
      }
      stubbed_service = ->(project_id, credentials, scope: nil, key: nil, retries: nil, timeout: nil, host: nil, universe_domain: nil) {
        _(project_id).must_equal "project-id"
        _(credentials).must_equal "translate-credentials"
        _(host).must_equal "custom-translate-endpoint.example.com"
        _(scope).must_be :nil?
        _(key).must_be :nil?
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(universe_domain).must_be :nil?
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Translate::V2::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
                translate = Google::Cloud::Translate::V2.new project_id: "project-id", credentials: "path/to/keyfile.json", endpoint: "custom-translate-endpoint.example.com"
                _(translate).must_be_kind_of Google::Cloud::Translate::V2::Api
                _(translate.project_id).must_equal "project-id"
                _(translate.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "resolves universe_domain with precedence: argument > configure > ENV > default" do
      custom_config = Google::Cloud::Config.new do |c|
        c.add_field! :key, nil, match: String
        c.add_field! :retries, nil, match: Integer
        c.add_field! :timeout, nil, match: Numeric
        c.add_field! :endpoint, nil, match: String
        c.add_field! :scope, nil, match: [String, Array]
        c.add_field! :project_id, nil, match: String
        c.add_field! :credentials, nil, match: Object
        c.add_field! :quota_project, nil, match: String
        c.add_field! :universe_domain, nil, match: String
      end

      Google::Cloud::Translate::V2.stub :translation_config, custom_config do
        ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"] = "env-universe.com"
        creds_env = TranslateTestFixtures.build_v2_credentials universe_domain: "env-universe.com"
        translate_env = Google::Cloud::Translate::V2.new project_id: "proj", credentials: creds_env
        _(translate_env.universe_domain).must_equal "env-universe.com"

        custom_config.universe_domain = "cfg-universe.com"
        creds_cfg = TranslateTestFixtures.build_v2_credentials universe_domain: "cfg-universe.com"
        translate_cfg = Google::Cloud::Translate::V2.new project_id: "proj", credentials: creds_cfg
        _(translate_cfg.universe_domain).must_equal "cfg-universe.com"

        creds_arg = TranslateTestFixtures.build_v2_credentials universe_domain: "arg-universe.com"
        translate_arg = Google::Cloud::Translate::V2.new(
          project_id: "proj",
          credentials: creds_arg,
          universe_domain: "arg-universe.com"
        )
        _(translate_arg.universe_domain).must_equal "arg-universe.com"
      end
    end

    it "raises ArgumentError when universe_domain is an empty string" do
      creds = TranslateTestFixtures.build_v2_credentials
      _(proc {
        Google::Cloud::Translate::V2.new project_id: "proj", credentials: creds, universe_domain: ""
      }).must_raise ArgumentError

      _(proc {
        Google::Cloud::Translate::V2.new project_id: "proj", credentials: creds, universe_domain: "   "
      }).must_raise ArgumentError
    end

    it "raises Google::Cloud::Error when credentials universe_domain mismatches client universe_domain" do
      gdu_creds = TranslateTestFixtures.build_v2_credentials universe_domain: "googleapis.com"
      err = _(proc {
        Google::Cloud::Translate::V2.new(
          project_id: "proj",
          credentials: gdu_creds,
          universe_domain: "myuniverse.com"
        )
      }).must_raise Google::Cloud::Error
      _(err.message).must_include "Universe domain is myuniverse.com but credentials are in googleapis.com"
    end
  end
end
