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

describe Google::Cloud do
  describe "#spanner" do
    it "calls out to Google::Cloud.spanner" do
      gcloud = Google::Cloud.new
      stubbed_spanner = ->(project, keyfile, scope: nil, timeout: nil, host: nil, lib_name: nil, lib_version: nil) {
        _(project).must_be :nil?
        _(keyfile).must_be :nil?
        _(scope).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        _(lib_name).must_be :nil?
        _(lib_version).must_be :nil?
        "spanner-project-object-empty"
      }
      Google::Cloud.stub :spanner, stubbed_spanner do
        project = gcloud.spanner
        _(project).must_equal "spanner-project-object-empty"
      end
    end

    it "passes project and keyfile to Google::Cloud.spanner" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_spanner = ->(project, keyfile, scope: nil, timeout: nil, host: nil, lib_name: nil, lib_version: nil) {
        _(project).must_equal "project-id"
        _(keyfile).must_equal "keyfile-path"
        _(scope).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        _(lib_name).must_be :nil?
        _(lib_version).must_be :nil?
        "spanner-project-object"
      }
      Google::Cloud.stub :spanner, stubbed_spanner do
        project = gcloud.spanner
        _(project).must_equal "spanner-project-object"
      end
    end

    it "passes project and keyfile and options to Google::Cloud.spanner" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_spanner = ->(project, keyfile, scope: nil, timeout: nil, host: nil, lib_name: nil, lib_version: nil) {
        _(project).must_equal "project-id"
        _(keyfile).must_equal "keyfile-path"
        _(scope).must_equal "http://example.com/scope"
        _(timeout).must_equal 60
        _(host).must_be :nil?
        _(lib_name).must_be :nil?
        _(lib_version).must_be :nil?
        "spanner-project-object-scoped"
      }
      Google::Cloud.stub :spanner, stubbed_spanner do
        project = gcloud.spanner scope: "http://example.com/scope", timeout: 60
        _(project).must_equal "spanner-project-object-scoped"
      end
    end

    it "passes lib name and version to Google::Cloud.spanner" do
      gcloud = Google::Cloud.new
      stubbed_spanner = ->(project, keyfile, scope: nil, timeout: nil, host: nil, lib_name: nil, lib_version: nil) {
        _(project).must_be :nil?
        _(keyfile).must_be :nil?
        _(scope).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        _(lib_name).must_equal "spanner-ruby"
        _(lib_version).must_equal "1.0.0"
        "spanner-project-object-with-lib-version-name"
      }
      Google::Cloud.stub :spanner, stubbed_spanner do
        project = gcloud.spanner lib_name: "spanner-ruby", lib_version: "1.0.0"
        _(project).must_equal "spanner-project-object-with-lib-version-name"
      end
    end
  end

  describe ".spanner" do
    let(:default_credentials) do
      creds = OpenStruct.new empty: true
      def creds.is_a? target
        target == Google::Auth::Credentials
      end
      creds
    end
    let(:found_credentials) { "{}" }

    it "gets defaults for project_id and keyfile" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Spanner::Credentials.stub :default, default_credentials do
            spanner = Google::Cloud.spanner
            _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
            _(spanner.project).must_equal "project-id"
            _(spanner.service.credentials).must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and keyfile" do
      default_scope = [
        "https://www.googleapis.com/auth/cloud-platform",
        "https://www.googleapis.com/auth/spanner.admin",
        "https://www.googleapis.com/auth/spanner.data"
      ]
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        "spanner-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil, **keyword_args) {

        _(project).must_equal "project-id"
        _(credentials).must_equal "spanner-credentials"
        _(timeout).must_be :nil?
        _(host).must_equal "spanner.googleapis.com"
        _(keyword_args.key?(:lib_name)).must_equal true
        _(keyword_args.key?(:lib_version)).must_equal true
        _(keyword_args[:lib_name]).must_be :nil?
        _(keyword_args[:lib_version]).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Spanner::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Spanner::Service.stub :new, stubbed_service do
                spanner = Google::Cloud.spanner "project-id", "path/to/keyfile.json"
                _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
                _(spanner.project).must_equal "project-id"
                _(spanner.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end

  describe "Spanner.new" do
    let(:default_credentials) do
      creds = OpenStruct.new empty: true
      def creds.is_a? target
        target == Google::Auth::Credentials
      end
      creds
    end
    let(:found_credentials) { "{}" }

    it "gets defaults for project_id, keyfile, lib_name and lib_version" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Spanner::Credentials.stub :default, default_credentials do
            spanner = Google::Cloud::Spanner.new
            _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
            _(spanner.project).must_equal "project-id"
            _(spanner.service.credentials).must_equal default_credentials
            _(spanner.service.lib_name).must_be :nil?
            _(spanner.service.lib_version).must_be :nil?
            _(spanner.service.send(:lib_name_with_prefix)).must_equal "gccl"
          end
        end
      end
    end

    it "uses provided project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).wont_be :nil?
        "spanner-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil, **keyword_args) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "spanner-credentials"
        _(timeout).must_be :nil?
        _(host).wont_be :nil?
        _(keyword_args.key?(:lib_name)).must_equal true
        _(keyword_args.key?(:lib_version)).must_equal true
        _(keyword_args[:lib_name]).must_be :nil?
        _(keyword_args[:lib_version]).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Spanner::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Spanner::Service.stub :new, stubbed_service do
                spanner = Google::Cloud::Spanner.new project_id: "project-id", credentials: "path/to/keyfile.json"
                _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
                _(spanner.project).must_equal "project-id"
                _(spanner.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses provided endpoint" do
      endpoint = "spanner-endpoint2.example.com"
      stubbed_service = ->(project, credentials, timeout: nil, host: nil, **keyword_args) {
        _(project).must_equal "project-id"
        _(credentials).must_equal default_credentials
        _(timeout).must_be :nil?
        _(host).must_equal endpoint
        _(keyword_args.key?(:lib_name)).must_equal true
        _(keyword_args.key?(:lib_version)).must_equal true
        _(keyword_args[:lib_name]).must_be :nil?
        _(keyword_args[:lib_version]).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud::Spanner::Service.stub :new, stubbed_service do
          spanner = Google::Cloud::Spanner.new project: "project-id", credentials: default_credentials, endpoint: endpoint
          _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
          _(spanner.project).must_equal "project-id"
          _(spanner.service).must_be_kind_of OpenStruct
        end
      end
    end

    it "uses quota_project from config" do
      stubbed_service = ->(project, credentials, quota_project: nil, timeout: nil, **keyword_args) {
        _(project).must_equal "project-id"
        _(credentials).must_equal default_credentials
        _(timeout).must_be :nil?
        _(quota_project).must_equal "quota_project"
        _(keyword_args.key?(:lib_name)).must_equal true
        _(keyword_args.key?(:lib_version)).must_equal true
        _(keyword_args[:lib_name]).must_be :nil?
        _(keyword_args[:lib_version]).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud::Spanner::Service.stub :new, stubbed_service do
          Google::Cloud::Spanner.configure do |config|
              config.quota_project  = "quota_project"
          end
          spanner = Google::Cloud::Spanner.new project: "project-id", credentials: default_credentials
          _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
          _(spanner.project).must_equal "project-id"
          _(spanner.service).must_be_kind_of OpenStruct
        end
      end
    end

    it "uses quota_project from credentials" do
      stubbed_service = ->(project, credentials, quota_project: nil, timeout: nil, **keyword_args) {
        _(project).must_equal "project-id"
        _(credentials).must_be_kind_of OpenStruct
        _(timeout).must_be :nil?
        _(credentials.quota_project_id).must_equal "quota_project_id"
        _(keyword_args.key?(:lib_name)).must_equal true
        _(keyword_args.key?(:lib_version)).must_equal true
        _(keyword_args[:lib_name]).must_be :nil?
        _(keyword_args[:lib_version]).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud::Spanner::Service.stub :new, stubbed_service do
          quota_project_credentials = OpenStruct.new(quota_project_id: "quota_project_id")
          def quota_project_credentials.is_a? target
              target == Google::Auth::Credentials
          end
          spanner = Google::Cloud::Spanner.new project: "project-id", credentials: quota_project_credentials
          _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
          _(spanner.project).must_equal "project-id"
          _(spanner.service).must_be_kind_of OpenStruct
        end
      end
    end

    it "uses provided project and keyfile aliases" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).wont_be :nil?
        "spanner-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil, **keyword_args) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "spanner-credentials"
        _(timeout).must_be :nil?
        _(host).wont_be :nil?
        _(keyword_args.key?(:lib_name)).must_equal true
        _(keyword_args.key?(:lib_version)).must_equal true
        _(keyword_args[:lib_name]).must_be :nil?
        _(keyword_args[:lib_version]).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Spanner::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Spanner::Service.stub :new, stubbed_service do
                spanner = Google::Cloud::Spanner.new project: "project-id", keyfile: "path/to/keyfile.json"
                _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
                _(spanner.project).must_equal "project-id"
                _(spanner.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "gets project_id from credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).wont_be :nil?
        OpenStruct.new project_id: "project-id"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil, **keyword_args) {
        _(project).must_equal "project-id"
        _(credentials).must_be_kind_of OpenStruct
        _(credentials.project_id).must_equal "project-id"
        _(timeout).must_be :nil?
        _(host).wont_be :nil?
        _(keyword_args.key?(:lib_name)).must_equal true
        _(keyword_args.key?(:lib_version)).must_equal true
        _(keyword_args[:lib_name]).must_be :nil?
        _(keyword_args[:lib_version]).must_be :nil?
        OpenStruct.new project: project
      }
      empty_env = OpenStruct.new

      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud.stub :env, empty_env do
          File.stub :file?, true, ["path/to/keyfile.json"] do
            File.stub :read, found_credentials, ["path/to/keyfile.json"] do
              Google::Cloud::Spanner::Credentials.stub :new, stubbed_credentials do
                Google::Cloud::Spanner::Service.stub :new, stubbed_service do
                  spanner = Google::Cloud::Spanner.new credentials: "path/to/keyfile.json"
                  _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
                  _(spanner.project).must_equal "project-id"
                  _(spanner.service).must_be_kind_of OpenStruct
                end
              end
            end
          end
        end
      end
    end

    it "uses SPANNER_EMULATOR_HOST environment variable" do
      emulator_host = "localhost:4567"
      emulator_check = ->(name) { (name == "SPANNER_EMULATOR_HOST") ? emulator_host : nil }
      # Clear all environment variables, except SPANNER_EMULATOR_HOST
      ENV.stub :[], emulator_check do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Spanner::Credentials.stub :default, default_credentials do
            spanner = Google::Cloud::Spanner.new
            _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
            _(spanner.project).must_equal "project-id"
            _(spanner.service.credentials).must_equal :this_channel_is_insecure
            _(spanner.service.host).must_equal emulator_host
          end
        end
      end
    end

    it "can create a new client with query options (client-level)" do
      expect_query_options = { optimizer_version: "2", optimizer_statistics_package: "auto_20191128_14_47_22UTC" }
      Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
        Google::Cloud::Spanner::Credentials.stub :default, default_credentials do
          credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
          new_spanner = Google::Cloud::Spanner.new
          new_client = new_spanner.client "instance-id", "database-id", pool: { min: 0 }, query_options: expect_query_options
          _(new_client.query_options).must_equal expect_query_options
        end
      end
    end

    it "can create a new client with query options that environment variables should merge over client-level configs" do
      expect_query_options = { optimizer_version: "2", optimizer_statistics_package: "auto_20191128_14_47_22UTC" }
      optimizer_version_check = ->(name) { (name == "SPANNER_OPTIMIZER_VERSION") ? "2" : nil }
      # Clear all environment variables, except SPANNER_OPTIMIZER_VERSION
      ENV.stub :[], optimizer_version_check do
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Spanner::Credentials.stub :default, default_credentials do
            credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
            new_spanner = Google::Cloud::Spanner.new
            new_client = new_spanner.client "instance-id", "database-id", pool: { min: 0 }, query_options: { optimizer_version: "1", optimizer_statistics_package: "auto_20191128_14_47_22UTC" }
            _(new_client.query_options).must_equal expect_query_options
          end
        end
      end
    end

    it "allows emulator_host to be set with emulator_host and implicit default_project_id" do
      emulator_host = "localhost:4567"
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          spanner = Google::Cloud::Spanner.new emulator_host: emulator_host
          _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
          _(spanner.project).must_equal "project-id"
          _(spanner.service.credentials).must_equal :this_channel_is_insecure
          _(spanner.service.host).must_equal emulator_host
        end
      end
    end

    it 'allows emulator_host to be set with emulator_host and project_id' do
      emulator_host = "localhost:4567"
      project_id = "arbitrary-string"
      ENV.stub :[], nil do
        spanner = Google::Cloud::Spanner.new project_id: project_id, emulator_host: emulator_host
        _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
        _(spanner.project).must_equal project_id
        _(spanner.service.credentials).must_equal :this_channel_is_insecure
        _(spanner.service.host).must_equal emulator_host
      end
    end

    it "uses provided lib name and lib version" do
      lib_name = "spanner-ruby"
      lib_version = "1.0.0"

      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Spanner::Credentials.stub :default, default_credentials do
            spanner = Google::Cloud::Spanner.new lib_name: lib_name, lib_version: lib_version
            _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
            _(spanner.project).must_equal "project-id"
            _(spanner.service.lib_name).must_equal lib_name
            _(spanner.service.lib_version).must_equal lib_version
            _(spanner.service.send(:lib_name_with_prefix)).must_equal "#{lib_name}/#{lib_version} gccl"
          end
        end
      end
    end

    it "uses SPANNER_OPTIMIZER_VERSION environment variable" do
      optimizer_version = "4"
      optimizer_version_check = ->(name) { (name == "SPANNER_OPTIMIZER_VERSION") ? optimizer_version : nil }
      # Clear all environment variables, except SPANNER_OPTIMIZER_VERSION
      ENV.stub :[], optimizer_version_check do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Spanner::Credentials.stub :default, default_credentials do
            spanner = Google::Cloud::Spanner.new
            query_options = {optimizer_version: optimizer_version}
            _(spanner.query_options).must_equal query_options
          end
        end
      end
    end

    it "uses SPANNER_OPTIMIZER_STATISTICS_PACKAGE environment variable" do
      optimizer_statistics_package = "auto_20191128_14_47_22UTC"
      check = ->(name) { (name == "SPANNER_OPTIMIZER_STATISTICS_PACKAGE") ? optimizer_statistics_package : nil }
      # Clear all environment variables, except SPANNER_OPTIMIZER_STATISTICS_PACKAGE
      ENV.stub :[], check do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Spanner::Credentials.stub :default, default_credentials do
            spanner = Google::Cloud::Spanner.new
            query_options = {optimizer_statistics_package: optimizer_statistics_package}
            _(spanner.query_options).must_equal query_options
          end
        end
      end
    end

    it "uses provided lib name only" do
      lib_name = "spanner-ruby"

      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Spanner::Credentials.stub :default, default_credentials do
            spanner = Google::Cloud::Spanner.new lib_name: lib_name
            _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
            _(spanner.project).must_equal "project-id"
            _(spanner.service.lib_name).must_equal lib_name
            _(spanner.service.lib_version).must_be :nil?
            _(spanner.service.send(:lib_name_with_prefix)).must_equal "#{lib_name} gccl"
          end
        end
      end
    end
  end

  describe "Spanner.configure" do
    let(:default_credentials) do
      ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).wont_be :nil?
        "spanner-credentials"
      }
    end
    let(:found_credentials) { "{}" }

    after do
      Google::Cloud.configure.reset!
    end

    it "uses shared config for project and keyfile" do
      stubbed_service = ->(project, credentials, timeout: nil, host: nil, **keyword_args) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "spanner-credentials"
        _(timeout).must_be :nil?
        _(host).wont_be :nil?
        _(keyword_args.key?(:lib_name)).must_equal true
        _(keyword_args.key?(:lib_version)).must_equal true
        _(keyword_args[:lib_name]).must_be :nil?
        _(keyword_args[:lib_version]).must_be :nil?
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
            Google::Cloud::Spanner::Credentials.stub :new, default_credentials do
              Google::Cloud::Spanner::Service.stub :new, stubbed_service do
                spanner = Google::Cloud::Spanner.new
                _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
                _(spanner.project).must_equal "project-id"
                _(spanner.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses shared config for project_id and credentials" do
      stubbed_service = ->(project, credentials, timeout: nil, host: nil, **keyword_args) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "spanner-credentials"
        _(timeout).must_be :nil?
        _(host).wont_be :nil?
        _(keyword_args.key?(:lib_name)).must_equal true
        _(keyword_args.key?(:lib_version)).must_equal true
        _(keyword_args[:lib_name]).must_be :nil?
        _(keyword_args[:lib_version]).must_be :nil?
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
            Google::Cloud::Spanner::Credentials.stub :new, default_credentials do
              Google::Cloud::Spanner::Service.stub :new, stubbed_service do
                spanner = Google::Cloud::Spanner.new
                _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
                _(spanner.project).must_equal "project-id"
                _(spanner.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses spanner config for project and keyfile" do
      stubbed_service = ->(project, credentials, timeout: nil, host: nil, **keyword_args) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "spanner-credentials"
        _(timeout).must_equal 42
        _(host).wont_be :nil?
        _(keyword_args.key?(:lib_name)).must_equal true
        _(keyword_args.key?(:lib_version)).must_equal true
        _(keyword_args[:lib_name]).must_be :nil?
        _(keyword_args[:lib_version]).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Spanner.configure do |config|
          config.project = "project-id"
          config.keyfile = "path/to/keyfile.json"
          config.timeout = 42
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Spanner::Credentials.stub :new, default_credentials do
              Google::Cloud::Spanner::Service.stub :new, stubbed_service do
                spanner = Google::Cloud::Spanner.new
                _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
                _(spanner.project).must_equal "project-id"
                _(spanner.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses spanner config for project_id and credentials" do
      stubbed_service = ->(project, credentials, timeout: nil, host: nil, **keyword_args) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "spanner-credentials"
        _(timeout).must_equal 42
        _(host).wont_be :nil?
        _(keyword_args.key?(:lib_name)).must_equal true
        _(keyword_args.key?(:lib_version)).must_equal true
        _(keyword_args[:lib_name]).must_be :nil?
        _(keyword_args[:lib_version]).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Spanner.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.timeout = 42
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Spanner::Credentials.stub :new, default_credentials do
              Google::Cloud::Spanner::Service.stub :new, stubbed_service do
                spanner = Google::Cloud::Spanner.new
                _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
                _(spanner.project).must_equal "project-id"
                _(spanner.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses spanner config for endpoint" do
      endpoint = "spanner-endpoint2.example.com"
      stubbed_service = ->(project, credentials, timeout: nil, host: nil, **keyword_args) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "spanner-credentials"
        _(timeout).must_be :nil?
        _(host).must_equal endpoint
        _(keyword_args.key?(:lib_name)).must_equal true
        _(keyword_args.key?(:lib_version)).must_equal true
        _(keyword_args[:lib_name]).must_be :nil?
        _(keyword_args[:lib_version]).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Spanner.configure do |config|
          config.project = "project-id"
          config.keyfile = "path/to/keyfile.json"
          config.endpoint = endpoint
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Spanner::Credentials.stub :new, default_credentials do
              Google::Cloud::Spanner::Service.stub :new, stubbed_service do
                spanner = Google::Cloud::Spanner.new
                _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
                _(spanner.project).must_equal "project-id"
                _(spanner.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses spanner config for emulator_host" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Spanner.configure do |config|
          config.project_id = "project-id"
          config.keyfile = "path/to/keyfile.json"
          config.emulator_host = "localhost:4567"
        end

        spanner = Google::Cloud::Spanner.new
        _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
        _(spanner.project).must_equal "project-id"
        _(spanner.service.credentials).must_equal :this_channel_is_insecure
        _(spanner.service.host).must_equal "localhost:4567"
      end
    end

    it "uses spanner config for custom lib name and version" do
      custom_lib_name = "spanner-ruby"
      custom_lib_version = "1.0.0"

      stubbed_credentials = ->(keyfile, scope: nil) {
        _(scope).wont_be :nil?
        "spanner-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil, **keyword_args) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "spanner-credentials"
        _(timeout).must_be :nil?
        _(host).wont_be :nil?
        _(keyword_args[:lib_name]).must_equal custom_lib_name
        _(keyword_args[:lib_version]).must_equal custom_lib_version
        OpenStruct.new project: project, lib_name: keyword_args[:lib_name], lib_version: keyword_args[:lib_version]
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Spanner.configure do |config|
          config.project = "project-id"
          config.keyfile = "path/to/keyfile.json"
          config.lib_name = custom_lib_name
          config.lib_version = custom_lib_version
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Spanner::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Spanner::Service.stub :new, stubbed_service do
                spanner = Google::Cloud::Spanner.new
                _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
                _(spanner.project).must_equal "project-id"
                _(spanner.service).must_be_kind_of OpenStruct
                _(spanner.service.lib_name).must_equal custom_lib_name
                _(spanner.service.lib_version).must_equal custom_lib_version
              end
            end
          end
        end
      end
    end

    it "uses spanner config for query_options" do
      query_options = {optimizer_version: "4", optimizer_statistics_package: "auto_20191128_14_47_22UTC"}
      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Spanner.configure do |config|
          config.project_id = "project-id"
          config.keyfile = "path/to/keyfile.json"
          config.query_options = query_options
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Spanner::Credentials.stub :new, default_credentials do
              spanner = Google::Cloud::Spanner.new
              _(spanner.project).must_equal "project-id"
              _(spanner.query_options).must_equal query_options
            end
          end
        end
      end
    end
  end
end
