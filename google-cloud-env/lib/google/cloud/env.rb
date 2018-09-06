# Copyright 2017 Google LLC
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


require "faraday"
require "json"


module Google
  module Cloud
    ##
    # # Google Cloud hosting environment
    #
    # This library provides access to information about the application's
    # hosting environment if it is running on Google Cloud Platform. You may
    # use this library to determine which Google Cloud product is hosting your
    # application (e.g. App Engine, Kubernetes Engine), information about the
    # Google Cloud project hosting the application, information about the
    # virtual machine instance, authentication information, and so forth.
    #
    # ## Usage
    #
    # Obtain an instance of the environment info with:
    #
    # ```ruby
    # require "google/cloud/env"
    # env = Google::Cloud.env
    # ```
    #
    # Then you can interrogate any fields using methods on the object.
    #
    # ```ruby
    # if env.app_engine?
    #   # App engine specific logic
    # end
    # ```
    #
    # Any item that does not apply to the current environment will return nil.
    # For example:
    #
    # ```ruby
    # unless env.app_engine?
    #   service = env.app_engine_service_id  # => nil
    # end
    # ```
    #
    class Env
      # @private Base (host) URL for the metadata server.
      METADATA_HOST = "http://169.254.169.254".freeze

      # @private URL path for v1 of the metadata service.
      METADATA_PATH_BASE = "/computeMetadata/v1".freeze

      # @private URL path for metadata server root.
      METADATA_ROOT_PATH = "/".freeze

      ##
      # Create a new instance of the environment information.
      # Most client should not need to call this directly. Obtain a singleton
      # instance of the information from `Google::Cloud.env`. This constructor
      # is provided for internal testing and allows mocking of the data.
      #
      # @param [Hash] env Mock environment variables.
      # @param [Faraday::Connection] connection Faraday connection to use.
      # @param [Hash] metadata_cache Mock cache.
      #
      def initialize env: nil, connection: nil, metadata_cache: nil
        @metadata_cache = metadata_cache || {}
        @env = env || ::ENV
        @connection = connection ||
                      ::Faraday.new(url: METADATA_HOST,
                                    request: { timeout: 0.1 })
      end

      ##
      # Determine whether the application is running on Google App Engine.
      #
      # @return [Boolean]
      #
      def app_engine?
        env["GAE_INSTANCE"] ? true : false
      end

      ##
      # Determine whether the application is running on Google Kubernetes
      # Engine (GKE).
      #
      # @return [Boolean]
      #
      def kubernetes_engine?
        kubernetes_engine_cluster_name ? true : false
      end
      alias container_engine? kubernetes_engine?

      ##
      # Determine whether the application is running on Google Cloud Shell.
      #
      # @return [Boolean]
      #
      def cloud_shell?
        env["DEVSHELL_GCLOUD_CONFIG"] ? true : false
      end

      ##
      # Determine whether the application is running on Google Compute Engine.
      #
      # Note that most other products (e.g. App Engine, Kubernetes Engine,
      # Cloud Shell) themselves use Compute Engine under the hood, so this
      # method will return true for all the above products. If you want to
      # determine whether the application is running on a "raw" Compute Engine
      # VM without using a higher level hosting product, use
      # {Env#raw_compute_engine?}.
      #
      # @return [Boolean]
      #
      def compute_engine?
        metadata?
      end

      ##
      # Determine whether the application is running on "raw" Google Compute
      # Engine without using a higher level hosting product such as App
      # Engine or Kubernetes Engine.
      #
      # @return [Boolean]
      #
      def raw_compute_engine?
        !app_engine? && !cloud_shell? && metadata? && !kubernetes_engine?
      end

      ##
      # Returns the unique string ID of the project hosting the application,
      # or `nil` if the application is not running on Google Cloud.
      #
      # @return [String,nil]
      #
      def project_id
        env["GCLOUD_PROJECT"] || env["DEVSHELL_PROJECT_ID"] ||
          lookup_metadata("project", "project-id")
      end

      ##
      # Returns the unique numeric ID of the project hosting the application,
      # or `nil` if the application is not running on Google Cloud.
      #
      # Caveat: this method does not work and returns `nil` on CloudShell.
      #
      # @return [Integer,nil]
      #
      def numeric_project_id
        # CloudShell's metadata server seems to run in a dummy project.
        # We can get the user's normal project ID via environment variables,
        # but the numeric ID from the metadata service is not correct. So
        # disable this for CloudShell to avoid confusion.
        return nil if cloud_shell?

        result = lookup_metadata "project", "numeric-project-id"
        result.nil? ? nil : result.to_i
      end

      ##
      # Returns the name of the VM instance hosting the application, or `nil`
      # if the application is not running on Google Cloud.
      #
      # @return [String,nil]
      #
      def instance_name
        env["GAE_INSTANCE"] || lookup_metadata("instance", "name")
      end

      ##
      # Returns the description field (which may be the empty string) of the
      # VM instance hosting the application, or `nil` if the application is
      # not running on Google Cloud.
      #
      # @return [String,nil]
      #
      def instance_description
        lookup_metadata "instance", "description"
      end

      ##
      # Returns the zone (for example "`us-central1-c`") in which the instance
      # hosting the application lives. Returns `nil` if the application is
      # not running on Google Cloud.
      #
      # @return [String,nil]
      #
      def instance_zone
        result = lookup_metadata "instance", "zone"
        result.nil? ? nil : result.split("/").last
      end

      ##
      # Returns the machine type of the VM instance hosting the application,
      # or `nil` if the application is not running on Google Cloud.
      #
      # @return [String,nil]
      #
      def instance_machine_type
        result = lookup_metadata "instance", "machine-type"
        result.nil? ? nil : result.split("/").last
      end

      ##
      # Returns an array (which may be empty) of all tags set on the VM
      # instance hosting the  application, or `nil` if the application is not
      # running on Google Cloud.
      #
      # @return [Array<String>,nil]
      #
      def instance_tags
        result = lookup_metadata "instance", "tags"
        result.nil? ? nil : JSON.parse(result)
      end

      ##
      # Returns an array (which may be empty) of all attribute keys present
      # for the VM instance hosting the  application, or `nil` if the
      # application is not running on Google Cloud.
      #
      # @return [Array<String>,nil]
      #
      def instance_attribute_keys
        result = lookup_metadata "instance", "attributes/"
        result.nil? ? nil : result.split
      end

      ##
      # Returns the value of the given instance attribute for the VM instance
      # hosting the application, or `nil` if the given key does not exist or
      # application is not running on Google Cloud.
      #
      # @param [String] key Attribute key to look up.
      # @return [String,nil]
      #
      def instance_attribute key
        lookup_metadata "instance", "attributes/#{key}"
      end

      ##
      # Returns the name of the running App Engine service, or `nil` if the
      # current code is not running in App Engine.
      #
      # @return [String,nil]
      #
      def app_engine_service_id
        env["GAE_SERVICE"]
      end

      ##
      # Returns the version of the running App Engine service, or `nil` if the
      # current code is not running in App Engine.
      #
      # @return [String,nil]
      #
      def app_engine_service_version
        env["GAE_VERSION"]
      end

      ##
      # Returns the amount of memory reserved for the current App Engine
      # instance, or `nil` if the current code is not running in App Engine.
      #
      # @return [Integer,nil]
      #
      def app_engine_memory_mb
        result = env["GAE_MEMORY_MB"]
        result.nil? ? nil : result.to_i
      end

      ##
      # Returns the name of the Kubernetes Engine cluster hosting the
      # application, or `nil` if the current code is not running in
      # Kubernetes Engine.
      #
      # @return [String,nil]
      #
      def kubernetes_engine_cluster_name
        instance_attribute "cluster-name"
      end
      alias container_engine_cluster_name kubernetes_engine_cluster_name

      ##
      # Returns the name of the Kubernetes Engine namespace hosting the
      # application, or `nil` if the current code is not running in
      # Kubernetes Engine.
      #
      # @return [String,nil]
      #
      def kubernetes_engine_namespace_id
        # The Kubernetes namespace is difficult to obtain without help from
        # the application using the Downward API. The environment variable
        # below is set in some older versions of GKE, and the file below is
        # present in Kubernetes as of version 1.9, but it is possible that
        # alternatives will need to be found in the future.
        env["GKE_NAMESPACE_ID"] ||
          ::IO.read("/var/run/secrets/kubernetes.io/serviceaccount/namespace")
      rescue SystemCallError
        nil
      end
      alias container_engine_namespace_id kubernetes_engine_namespace_id

      ##
      # Determine whether the Google Compute Engine Metadata Service is running.
      #
      # @return [Boolean]
      #
      def metadata?
        unless metadata_cache.include?(METADATA_ROOT_PATH)
          begin
            resp = connection.get METADATA_ROOT_PATH
            metadata_cache[METADATA_ROOT_PATH] = \
              resp.status == 200 && resp.headers["Metadata-Flavor"] == "Google"
          rescue ::Faraday::TimeoutError, ::Faraday::ConnectionFailed,
                 Errno::EHOSTDOWN
            metadata_cache[METADATA_ROOT_PATH] = false
          end
        end
        metadata_cache[METADATA_ROOT_PATH]
      end

      ##
      # Retrieve info from the Google Compute Engine Metadata Service.
      # Returns `nil` if the Metadata Service is not running or the given
      # data is not present.
      #
      # @param [String] type Type of metadata to look up. Currently supported
      #     values are "project" and "instance".
      # @param [String] entry Metadata entry path to look up.
      # @return [String,nil]
      #
      def lookup_metadata type, entry
        path = "#{METADATA_PATH_BASE}/#{type}/#{entry}"
        if !metadata_cache.include?(path) && metadata?
          begin
            resp = connection.get path do |req|
              req.headers = { "Metadata-Flavor" => "Google" }
            end
            metadata_cache[path] = resp.status == 200 ? resp.body.strip : nil
          rescue ::Faraday::TimeoutError, ::Faraday::ConnectionFailed,
                 Errno::EHOSTDOWN
            metadata_cache[path] = nil
          end
        end
        metadata_cache[path]
      end

      ##
      # Returns the global instance of {Google::Cloud::Env}.
      #
      # @return [Google::Cloud::Env]
      #
      def self.get
        ::Google::Cloud.env
      end

      private

      attr_reader :connection
      attr_reader :env
      attr_reader :metadata_cache
    end

    @env = Env.new

    ##
    # Returns the global instance of {Google::Cloud::Env}.
    #
    # @return [Google::Cloud::Env]
    #
    def self.env
      @env
    end
  end
end
