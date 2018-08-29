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


module Google
  module Devtools
    module Cloudtrace
      module V2
        # The request message for the +BatchWriteSpans+ method.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The name of the project where the spans belong. The format is
        #     +projects/[PROJECT_ID]+.
        # @!attribute [rw] spans
        #   @return [Array<Google::Devtools::Cloudtrace::V2::Span>]
        #     A list of new spans. The span names must not match existing
        #     spans, or the results are undefined.
        class BatchWriteSpansRequest; end
      end
    end
  end
end