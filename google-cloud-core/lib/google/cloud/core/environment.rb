# Copyright 2015 Google Inc. All rights reserved.
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


require "faraday"

module Google
  module Cloud
    module Core
      ##
      # @private
      # Represents the Google Cloud Platform environments.
      module Environment
        CHECK_URI = "http://169.254.169.254"
        PROJECT_URI = "#{CHECK_URI}/computeMetadata/v1/project"
        INSTANCE_METADATA_URI = "#{CHECK_URI}/computeMetadata/v1/instance"

        ##
        # Check if running from a gce vm, which actually hosts GCE, GKE, and
        # GAE environments.
        def self.gce_vm? connection: nil
          @metadata ||= {}
          return @metadata[:gce_vm] if @metadata.key? :gce_vm

          conn = connection || Faraday.default_connection
          resp = conn.get CHECK_URI do |req|
            req.options.timeout = 0.1
          end
          @metadata[:gce_vm] = if resp.status != 200 ||
                                  !resp.headers.key?("Metadata-Flavor")
                                 false
                               else
                                 resp.headers["Metadata-Flavor"] == "Google"
                               end
        rescue Faraday::TimeoutError, Faraday::ConnectionFailed
          @metadata ||= {}
          @metadata[:gce_vm] = false
        end

        ##
        # Check if running from Google Compute Engine, and not using GAE or GKE
        #
        # @return [Boolean] True if running from GCE and not GAE or GKE
        def self.gce?
          gce_vm? && !gae? && !gke?
        end

        ##
        # Check if running from Google Container Engine by querying for
        # GKE cluster name and VM instance_zone
        #
        # @return [Boolean] True if self.gke_cluster_name() and
        # self.instance_zone() both return true values
        def self.gke?
          gke_cluster_name && instance_zone
        end

        ##
        # Check if running from Google App Engine by checking existance of
        # GAE_VM, GAE_MODULE_NAME, GAE_MODULE_VERSION environment variables.
        #
        # @return [Boolean] True if all three GAE environment variables are
        #   defined
        def self.gae?
          ENV["GAE_VM"] && gae_module_id && gae_module_version
        end

        def self.project_id
          uri = "#{PROJECT_URI}/project-id"
          get_metadata_attribute uri, :project_id
        end

        ##
        # Retrieve GAE module name
        def self.gae_module_id
          ENV["GAE_MODULE_NAME"]
        end

        ##
        # Retrieve GAE module version
        def self.gae_module_version
          ENV["GAE_MODULE_VERSION"]
        end

        ##
        # Retrieve GKE cluster name
        def self.gke_cluster_name
          uri = "#{INSTANCE_METADATA_URI}/attributes/cluster-name"
          get_metadata_attribute uri, :cluster_name
        end

        ##
        # Retrieve GKE namespace id
        def self.gke_namespace_id
          ENV["GKE_NAMESPACE_ID"]
        end

        ##
        # Retrieve GCE VM zone
        def self.instance_zone
          uri = "#{INSTANCE_METADATA_URI}/zone"
          full_zone = get_metadata_attribute uri, :zone
          full_zone.nil? ? nil : full_zone.split(%r{/}).last
        end

        ##
        # Retrieve GCE VM instance_id
        def self.instance_id
          uri = "#{INSTANCE_METADATA_URI}/id"
          get_metadata_attribute uri, :instance_id
        end

        ##
        # Helper method to send HTTP request to GCP metadata service and
        # retrieve environment information
        def self.get_metadata_attribute uri, attr_name, connection: nil
          @metadata ||= {}
          return @metadata[attr_name] if @metadata.key? attr_name

          conn = connection || Faraday.default_connection
          conn.headers = { "Metadata-Flavor" => "Google" }
          resp = conn.get uri do |req|
            req.options.timeout = 0.1
          end

          @metadata[attr_name] = resp.status == 200 ? resp.body : nil
        rescue Faraday::TimeoutError, Faraday::ConnectionFailed
          @metadata ||= {}
          @metadata[attr_name] = nil
        end
      end
    end
  end
end
