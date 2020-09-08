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
require "google/cloud/dns"

describe Google::Cloud do
  describe "#dns" do
    it "calls out to Google::Cloud.dns" do
      gcloud = Google::Cloud.new
      stubbed_dns = ->(project, keyfile, scope: nil, retries: nil, timeout: nil, host: nil) {
        _(project).must_be :nil?
        _(keyfile).must_be :nil?
        _(scope).must_be :nil?
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        "dns-project-object-empty"
      }
      Google::Cloud.stub :dns, stubbed_dns do
        project = gcloud.dns
        _(project).must_equal "dns-project-object-empty"
      end
    end

    it "passes project and keyfile to Google::Cloud.dns" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_dns = ->(project, keyfile, scope: nil, retries: nil, timeout: nil, host: nil) {
        _(project).must_equal "project-id"
        _(keyfile).must_equal "keyfile-path"
        _(scope).must_be :nil?
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        "dns-project-object"
      }
      Google::Cloud.stub :dns, stubbed_dns do
        project = gcloud.dns
        _(project).must_equal "dns-project-object"
      end
    end

    it "passes project and keyfile and options to Google::Cloud.dns" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_dns = ->(project, keyfile, scope: nil, retries: nil, timeout: nil, host: nil) {
        _(project).must_equal "project-id"
        _(keyfile).must_equal "keyfile-path"
        _(scope).must_equal "http://example.com/scope"
        _(retries).must_equal 5
        _(timeout).must_equal 60
        _(host).must_be :nil?
        "dns-project-object-scoped"
      }
      Google::Cloud.stub :dns, stubbed_dns do
        project = gcloud.dns scope: "http://example.com/scope", retries: 5, timeout: 60
        _(project).must_equal "dns-project-object-scoped"
      end
    end
  end

  describe ".dns" do
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
          Google::Cloud::Dns::Credentials.stub :default, default_credentials do
            dns = Google::Cloud.dns
            _(dns).must_be_kind_of Google::Cloud::Dns::Project
            _(dns.project).must_equal "project-id"
            _(dns.service.credentials).must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        "dns-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, host: nil, quota_project: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "dns-credentials"
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Dns::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Dns::Service.stub :new, stubbed_service do
                dns = Google::Cloud.dns "project-id", "path/to/keyfile.json"
                _(dns).must_be_kind_of Google::Cloud::Dns::Project
                _(dns.project).must_equal "project-id"
                _(dns.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end

  describe "Dns.new" do
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
          Google::Cloud::Dns::Credentials.stub :default, default_credentials do
            dns = Google::Cloud::Dns.new
            _(dns).must_be_kind_of Google::Cloud::Dns::Project
            _(dns.project).must_equal "project-id"
            _(dns.service.credentials).must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        "dns-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, host: nil, quota_project: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "dns-credentials"
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Dns::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Dns::Service.stub :new, stubbed_service do
                dns = Google::Cloud::Dns.new project_id: "project-id", credentials: "path/to/keyfile.json"
                _(dns).must_be_kind_of Google::Cloud::Dns::Project
                _(dns.project).must_equal "project-id"
                _(dns.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses provided project and keyfile aliases" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        "dns-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, host: nil, quota_project: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "dns-credentials"
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Dns::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Dns::Service.stub :new, stubbed_service do
                dns = Google::Cloud::Dns.new project: "project-id", keyfile: "path/to/keyfile.json"
                _(dns).must_be_kind_of Google::Cloud::Dns::Project
                _(dns.project).must_equal "project-id"
                _(dns.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "gets project_id from credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        OpenStruct.new project_id: "project-id"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, host: nil, quota_project: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_be_kind_of OpenStruct
        _(credentials.project_id).must_equal "project-id"
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        OpenStruct.new project: project
      }
      empty_env = OpenStruct.new

      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud.stub :env, empty_env do
          File.stub :file?, true, ["path/to/keyfile.json"] do
            File.stub :read, found_credentials, ["path/to/keyfile.json"] do
              Google::Cloud::Dns::Credentials.stub :new, stubbed_credentials do
                Google::Cloud::Dns::Service.stub :new, stubbed_service do
                  dns = Google::Cloud::Dns.new credentials: "path/to/keyfile.json"
                  _(dns).must_be_kind_of Google::Cloud::Dns::Project
                  _(dns.project).must_equal "project-id"
                  _(dns.service).must_be_kind_of OpenStruct
                end
              end
            end
          end
        end
      end
    end

    it "uses provided endpoint" do
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, host: nil, quota_project: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal default_credentials
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_equal "dns-endpoint2.example.com"
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Dns::Service.stub :new, stubbed_service do
            dns = Google::Cloud::Dns.new credentials: default_credentials, endpoint: "dns-endpoint2.example.com"
            _(dns).must_be_kind_of Google::Cloud::Dns::Project
            _(dns.project).must_equal "project-id"
            _(dns.service).must_be_kind_of OpenStruct
          end
        end
      end
    end
  end

  describe "Dns.configure" do
    let(:found_credentials) { "{}" }

    after do
      Google::Cloud.configure.reset!
    end

    it "uses shared config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        "dns-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, host: nil, quota_project: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "dns-credentials"
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
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
            Google::Cloud::Dns::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Dns::Service.stub :new, stubbed_service do
                dns = Google::Cloud::Dns.new
                _(dns).must_be_kind_of Google::Cloud::Dns::Project
                _(dns.project).must_equal "project-id"
                _(dns.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses shared config for project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        "dns-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, host: nil, quota_project: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "dns-credentials"
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configurations
        Google::Cloud.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Dns::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Dns::Service.stub :new, stubbed_service do
                dns = Google::Cloud::Dns.new
                _(dns).must_be_kind_of Google::Cloud::Dns::Project
                _(dns.project).must_equal "project-id"
                _(dns.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses dns config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        "dns-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, host: nil, quota_project: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "dns-credentials"
        _(retries).must_equal 3
        _(timeout).must_equal 42
        _(host).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Dns.configure do |config|
          config.project = "project-id"
          config.keyfile = "path/to/keyfile.json"
          config.retries = 3
          config.timeout = 42
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Dns::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Dns::Service.stub :new, stubbed_service do
                dns = Google::Cloud::Dns.new
                _(dns).must_be_kind_of Google::Cloud::Dns::Project
                _(dns.project).must_equal "project-id"
                _(dns.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses dns config for project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        "dns-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, host: nil, quota_project: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "dns-credentials"
        _(retries).must_equal 3
        _(timeout).must_equal 42
        _(host).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configurations
        Google::Cloud::Dns.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.retries = 3
          config.timeout = 42
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Dns::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Dns::Service.stub :new, stubbed_service do
                dns = Google::Cloud::Dns.new
                _(dns).must_be_kind_of Google::Cloud::Dns::Project
                _(dns.project).must_equal "project-id"
                _(dns.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses dns config for endpoint" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        "dns-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, host: nil, quota_project: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "dns-credentials"
        _(retries).must_equal 3
        _(timeout).must_equal 42
        _(host).must_equal "dns-endpoint2.example.com"
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configurations
        Google::Cloud::Dns.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.retries = 3
          config.timeout = 42
          config.endpoint = "dns-endpoint2.example.com"
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Dns::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Dns::Service.stub :new, stubbed_service do
                dns = Google::Cloud::Dns.new
                _(dns).must_be_kind_of Google::Cloud::Dns::Project
                _(dns.project).must_equal "project-id"
                _(dns.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses dns config for quota project" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        "dns-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, host: nil, quota_project: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "dns-credentials"
        _(retries).must_equal 3
        _(timeout).must_equal 42
        _(quota_project).must_equal "project-id-2"
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configurations
        Google::Cloud::Dns.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.retries = 3
          config.timeout = 42
          config.quota_project = "project-id-2"
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Dns::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Dns::Service.stub :new, stubbed_service do
                dns = Google::Cloud::Dns.new
                _(dns).must_be_kind_of Google::Cloud::Dns::Project
                _(dns.project).must_equal "project-id"
                _(dns.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end
end
