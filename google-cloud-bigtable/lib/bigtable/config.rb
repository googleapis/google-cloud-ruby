# Copyright 2018 Google LLC
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

module Bigtable
  class Config
    attr_reader :project_id

    def initialize project_id, options = {}
      @project_id = project_id
      @options = options
    end

    # builds and returns credentials if present
    # @returns [Hash]
    #   returns the options to create an admin client
    def admin_credentials
      @admin_creds = @options.clone if @admin_creds.nil?
      if @admin_creds[:credentials].is_a?(String)
        @admin_creds[:credentials] =
          Google::Cloud::Bigtable::Admin::Credentials.new(
            options[:credentials],
            scopes: options[:scopes]
          )
      end
      @admin_creds
    end

    # Creates formatted project path
    # @return [String]
    #   Formatted project path
    #   +projects/<project>+
    def project_path
      Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient
        .project_path(project_id)
    end

    # Created formatted instance path
    # @param instance_id [String]
    # @return [String]
    #   Formatted instance path
    #   +projects/<project>/instances/[a-z][a-z0-9\\-]+[a-z0-9]+.
    def instance_path instance_id
      Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient
        .instance_path project_id, instance_id
    end
  end
end
