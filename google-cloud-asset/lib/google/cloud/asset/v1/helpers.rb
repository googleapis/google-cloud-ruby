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
# # limitations under the License.

module Google
  module Cloud
    module Asset
      module V1
        class AssetServiceClient

          # Alias for Google::Cloud::Asset::V1::AssetServiceClient.feed_path.
          # @param project [String]
          # @param feed [String]
          # @return [String]
          def feed_path project, feed
            self.class.feed_path project, feed
          end
        end
      end
    end
  end
end
