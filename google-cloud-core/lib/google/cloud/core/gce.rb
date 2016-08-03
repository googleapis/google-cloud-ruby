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
      # Represents the Google Compute Engine environment.
      module GCE
        CHECK_URI = "http://169.254.169.254"
        PROJECT_URI = "#{CHECK_URI}/computeMetadata/v1/project/project-id"

        def self.gce? options = {}
          conn = options[:connection] || Faraday.default_connection
          resp = conn.get CHECK_URI do |req|
            req.options.timeout = 0.1
          end
          return false unless resp.status == 200
          return false unless resp.headers.key? "Metadata-Flavor"
          return resp.headers["Metadata-Flavor"] == "Google"
        rescue Faraday::TimeoutError, Faraday::ConnectionFailed
          return false
        end

        def self.project_id options = {}
          @gce ||= {}
          return @gce[:project_id] if @gce.key? :project_id
          conn = options[:connection] || Faraday.default_connection
          conn.headers = { "Metadata-Flavor" => "Google" }
          resp = conn.get PROJECT_URI do |req|
            req.options.timeout = 0.1
          end
          if resp.status == 200
            @gce[:project_id] = resp.body
          else
            @gce[:project_id] = nil
          end
        rescue Faraday::TimeoutError, Faraday::ConnectionFailed
          @gce ||= {}
          @gce[:project_id] = nil
        end
      end
    end
  end
end
