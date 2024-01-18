# Copyright 2016 Google LLC
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
require "google/cloud/pubsub"

describe Google::Cloud do
  let(:default_host) { "pubsub.googleapis.com" }
  let(:default_scopes) { ["https://www.googleapis.com/auth/cloud-platform", "https://www.googleapis.com/auth/pubsub"] }
  let(:default_credentials) do
    creds = OpenStruct.new empty: true
    def creds.is_a? target
      target == Google::Auth::Credentials
    end
    creds
  end

  describe "#pubsub" do
    it "calls out to Google::Cloud.pubsub" do
      gcloud = Google::Cloud.new
      stubbed_pubsub = ->(project, keyfile, scope: nil, timeout: nil) {
        _(project).must_be :nil?
        _(keyfile).must_be :nil?
        _(scope).must_be :nil?
        _(timeout).must_be :nil?
        "pubsub-project-object-empty"
      }
      Google::Cloud.stub :pubsub, stubbed_pubsub do
        project = gcloud.pubsub
        _(project).must_equal "pubsub-project-object-empty"
      end
    end

    it "passes project and keyfile to Google::Cloud.pubsub" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_pubsub = ->(project, keyfile, scope: nil, timeout: nil) {
        _(project).must_equal "project-id"
        _(keyfile).must_equal "keyfile-path"
        _(scope).must_be :nil?
        _(timeout).must_be :nil?
        "pubsub-project-object"
      }
      Google::Cloud.stub :pubsub, stubbed_pubsub do
        project = gcloud.pubsub
        _(project).must_equal "pubsub-project-object"
      end
    end

    it "passes project and keyfile and options to Google::Cloud.pubsub" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_pubsub = ->(project, keyfile, scope: nil, timeout: nil) {
        _(project).must_equal "project-id"
        _(keyfile).must_equal "keyfile-path"
        _(scope).must_equal "http://example.com/scope"
        _(timeout).must_equal 60.0
        "pubsub-project-object-scoped"
      }
      Google::Cloud.stub :pubsub, stubbed_pubsub do
        project = gcloud.pubsub scope: "http://example.com/scope", timeout: 60.0
        _(project).must_equal "pubsub-project-object-scoped"
      end
    end
  end

  describe ".pubsub" do
    let(:found_credentials) { "{}" }

    it "gets defaults for project_id and keyfile" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::PubSub::Credentials.stub :default, default_credentials do
            pubsub = Google::Cloud.pubsub
            _(pubsub).must_be_kind_of Google::Cloud::PubSub::Project
            _(pubsub.project).must_equal "project-id"
            _(pubsub.service.credentials).must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scopes
        "pubsub-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "pubsub-credentials"
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        _(universe_domain).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::PubSub::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::PubSub::Service.stub :new, stubbed_service do
                pubsub = Google::Cloud.pubsub "project-id", "path/to/keyfile.json"
                _(pubsub).must_be_kind_of Google::Cloud::PubSub::Project
                _(pubsub.project).must_equal "project-id"
                _(pubsub.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end

  describe "PubSub.new" do
    let(:found_credentials) { "{}" }

    after do
      Google::Cloud.configure.reset!
    end

    it "gets defaults for project_id and credentials" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::PubSub::Credentials.stub :default, default_credentials do
            pubsub = Google::Cloud::PubSub.new
            _(pubsub).must_be_kind_of Google::Cloud::PubSub::Project
            _(pubsub.project).must_equal "project-id"
            _(pubsub.service.credentials).must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scopes
        "pubsub-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "pubsub-credentials"
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        _(universe_domain).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::PubSub::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::PubSub::Service.stub :new, stubbed_service do
                pubsub = Google::Cloud::PubSub.new project_id: "project-id", credentials: "path/to/keyfile.json"
                _(pubsub).must_be_kind_of Google::Cloud::PubSub::Project
                _(pubsub.project).must_equal "project-id"
                _(pubsub.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses provided project and keyfile aliases" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scopes
        "pubsub-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "pubsub-credentials"
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        _(universe_domain).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::PubSub::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::PubSub::Service.stub :new, stubbed_service do
                pubsub = Google::Cloud::PubSub.new project: "project-id", keyfile: "path/to/keyfile.json"
                _(pubsub).must_be_kind_of Google::Cloud::PubSub::Project
                _(pubsub.project).must_equal "project-id"
                _(pubsub.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses PUBSUB_EMULATOR_HOST environment variable" do
      emulator_host = "localhost:4567"
      emulator_check = ->(name) { (name == "PUBSUB_EMULATOR_HOST") ? emulator_host : nil }
      # Clear all environment variables, except PUBSUB_EMULATOR_HOST
      ENV.stub :[], emulator_check do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::PubSub::Credentials.stub :default, default_credentials do
            pubsub = Google::Cloud::PubSub.new
            _(pubsub).must_be_kind_of Google::Cloud::PubSub::Project
            _(pubsub.project).must_equal "project-id"
            _(pubsub.service.credentials).must_equal :this_channel_is_insecure
            _(pubsub.service.host).must_equal emulator_host
          end
        end
      end
    end

    it "allows timeout to be set" do
      timeout = 123.4

      stubbed_service = ->(project, credentials, timeout: nil, host: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal default_credentials
        _(timeout).must_equal timeout
        _(host).must_be :nil?
        _(universe_domain).must_be :nil?
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::PubSub::Credentials.stub :default, default_credentials do
            Google::Cloud::PubSub::Service.stub :new, stubbed_service do
              pubsub = Google::Cloud::PubSub.new timeout: timeout
            end
          end
        end
      end
    end

    it "allows endpoint to be set" do
      endpoint = "localhost:4567"

      stubbed_service = ->(project, credentials, timeout: nil, host: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal default_credentials
        _(timeout).must_be :nil?
        _(host).must_equal endpoint
        _(universe_domain).must_be :nil?
        OpenStruct.new project: project, credentials: credentials
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::PubSub::Credentials.stub :default, default_credentials do
            Google::Cloud::PubSub::Service.stub :new, stubbed_service do
              pubsub = Google::Cloud::PubSub.new endpoint: endpoint
              _(pubsub).must_be_kind_of Google::Cloud::PubSub::Project
              _(pubsub.project).must_equal "project-id"
              _(pubsub.service.credentials).must_equal default_credentials
            end
          end
        end
      end
    end

    it "allows universe_domain to be set" do
      actual_universe_domain = "myuniverse.com"

      stubbed_service = ->(project, credentials, timeout: nil, host: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal default_credentials
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        _(universe_domain).must_equal actual_universe_domain
        OpenStruct.new project: project, credentials: credentials
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::PubSub::Credentials.stub :default, default_credentials do
            Google::Cloud::PubSub::Service.stub :new, stubbed_service do
              pubsub = Google::Cloud::PubSub.new universe_domain: actual_universe_domain
              _(pubsub).must_be_kind_of Google::Cloud::PubSub::Project
              _(pubsub.project).must_equal "project-id"
              _(pubsub.service.credentials).must_equal default_credentials
            end
          end
        end
      end
    end

    it "allows emulator_host to be set" do
      emulator_host = "localhost:4567"
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::PubSub::Credentials.stub :default, default_credentials do
            pubsub = Google::Cloud::PubSub.new emulator_host: emulator_host
            _(pubsub).must_be_kind_of Google::Cloud::PubSub::Project
            _(pubsub.project).must_equal "project-id"
            _(pubsub.service.credentials).must_equal :this_channel_is_insecure
            _(pubsub.service.host).must_equal emulator_host
          end
        end
      end
    end

    it "gets project_id from credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scopes
        OpenStruct.new project_id: "project-id"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_be_kind_of OpenStruct
        _(credentials.project_id).must_equal "project-id"
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        _(universe_domain).must_be :nil?
        OpenStruct.new project: project
      }
      empty_env = OpenStruct.new

      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud.stub :env, empty_env do
          File.stub :file?, true, ["path/to/keyfile.json"] do
            File.stub :read, found_credentials, ["path/to/keyfile.json"] do
              Google::Cloud::PubSub::Credentials.stub :new, stubbed_credentials do
                Google::Cloud::PubSub::Service.stub :new, stubbed_service do
                  pubsub = Google::Cloud::PubSub.new credentials: "path/to/keyfile.json"
                  _(pubsub).must_be_kind_of Google::Cloud::PubSub::Project
                  _(pubsub.project).must_equal "project-id"
                  _(pubsub.service).must_be_kind_of OpenStruct
                end
              end
            end
          end
        end
      end
    end
  end

  describe "PubSub.configure" do
    let(:found_credentials) { "{}" }

    after do
      Google::Cloud.configure.reset!
    end

    it "uses shared config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scopes
        "pubsub-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "pubsub-credentials"
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        _(universe_domain).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud.configure do |config|
          config.project = "project-id"
          config.keyfile = "path/to/keyfile.json"
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::PubSub::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::PubSub::Service.stub :new, stubbed_service do
                pubsub = Google::Cloud::PubSub.new
                _(pubsub).must_be_kind_of Google::Cloud::PubSub::Project
                _(pubsub.project).must_equal "project-id"
                _(pubsub.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses shared config for project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scopes
        "pubsub-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "pubsub-credentials"
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        _(universe_domain).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::PubSub::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::PubSub::Service.stub :new, stubbed_service do
                pubsub = Google::Cloud::PubSub.new
                _(pubsub).must_be_kind_of Google::Cloud::PubSub::Project
                _(pubsub.project).must_equal "project-id"
                _(pubsub.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses pubsub config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scopes
        "pubsub-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "pubsub-credentials"
        _(timeout).must_equal 42.0
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::PubSub.configure do |config|
          config.project = "project-id"
          config.keyfile = "path/to/keyfile.json"
          config.timeout = 42.0
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::PubSub::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::PubSub::Service.stub :new, stubbed_service do
                pubsub = Google::Cloud::PubSub.new
                _(pubsub).must_be_kind_of Google::Cloud::PubSub::Project
                _(pubsub.project).must_equal "project-id"
                _(pubsub.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses pubsub config for project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scopes
        "pubsub-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "pubsub-credentials"
        _(timeout).must_equal 42.0
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::PubSub.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.timeout = 42.0
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::PubSub::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::PubSub::Service.stub :new, stubbed_service do
                pubsub = Google::Cloud::PubSub.new
                _(pubsub).must_be_kind_of Google::Cloud::PubSub::Project
                _(pubsub.project).must_equal "project-id"
                _(pubsub.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses pubsub config for endpoint and universe_domain" do
      actual_endpoint = "myendpoint.com"
      actual_universe_domain = "mydomain.com"

      stubbed_service = ->(project, credentials, timeout: nil, host: nil, universe_domain: nil) {
        _(host).must_equal actual_endpoint
        _(universe_domain).must_equal actual_universe_domain
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::PubSub.configure do |config|
          config.project_id = "project-id"
          config.endpoint = actual_endpoint
          config.universe_domain = actual_universe_domain
        end

        Google::Cloud::PubSub::Credentials.stub :default, default_credentials do
          Google::Cloud::PubSub::Service.stub :new, stubbed_service do
            pubsub = Google::Cloud::PubSub.new
            _(pubsub).must_be_kind_of Google::Cloud::PubSub::Project
          end
        end
      end
    end

    it "uses pubsub config for emulator_host" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::PubSub.configure do |config|
          config.project_id = "project-id"
          config.emulator_host = "localhost:4567"
        end

        pubsub = Google::Cloud::PubSub.new
        _(pubsub).must_be_kind_of Google::Cloud::PubSub::Project
        _(pubsub.project).must_equal "project-id"
        _(pubsub.service.credentials).must_equal :this_channel_is_insecure
        _(pubsub.service.host).must_equal "localhost:4567"
      end
    end
  end
end
