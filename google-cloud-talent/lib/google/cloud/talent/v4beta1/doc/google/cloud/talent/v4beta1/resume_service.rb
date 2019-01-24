# Copyright 2019 Google LLC
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
  module Cloud
    module Talent
      module V4beta1
        # Parse resume request.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required.
        #
        #     The resource name of the project.
        #
        #     The format is "projects/{project_id}", for example,
        #     "projects/api-test-project".
        # @!attribute [rw] resume
        #   @return [String]
        #     Required.
        #
        #     The bytes of the resume file in common format. Currently the API supports
        #     the following formats:
        #     PDF, TXT, DOC, RTF and DOCX.
        # @!attribute [rw] region_code
        #   @return [String]
        #     Optional.
        #
        #     The region code indicating where the resume is from. Values
        #     are as per the ISO-3166-2 format. For example, US, FR, DE.
        #
        #     This value is optional, but providing this value improves the resume
        #     parsing quality and performance.
        #
        #     An error is thrown if the regionCode is invalid.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Optional.
        #
        #     The language code of contents in the resume.
        #
        #     Language codes must be in BCP-47 format, such as "en-US" or "sr-Latn".
        #     For more information, see
        #     [Tags for Identifying Languages](https://tools.ietf.org/html/bcp47){:
        #     class="external" target="_blank" }.
        class ParseResumeRequest; end

        # Parse resume response.
        # @!attribute [rw] profile
        #   @return [Google::Cloud::Talent::V4beta1::Profile]
        #     The profile parsed from resume.
        # @!attribute [rw] raw_text
        #   @return [String]
        #     Raw text from resume.
        class ParseResumeResponse; end
      end
    end
  end
end