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
        #     The bytes of the resume file in common format, for example, PDF, TXT.
        #     UTF-8 encoding is required if the resume is text-based, otherwise an error
        #     is thrown.
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
        # @!attribute [rw] options
        #   @return [Google::Cloud::Talent::V4beta1::ParseResumeOptions]
        #     Optional.
        #
        #     Options that change how the resume parse is performed.
        class ParseResumeRequest; end

        # Options that change how the resume parse is performed.
        # @!attribute [rw] enable_ocr
        #   @return [true, false]
        #     Optional.
        #
        #     Controls whether Optical Character Recognition (OCR) is enabled.
        #
        #     OCR is used to decipher pictorial resumes, or resumes that have some
        #     element of pictorial detail (for example, contact information placed within
        #     an image in a pdf). Note that the API call has a higher latency if OCR is
        #     enabled.
        # @!attribute [rw] enable_full_skill_detection
        #   @return [true, false]
        #     Optional.
        #
        #     Controls whether detected skills are included in the parsed profile from
        #     sections of the resume other than just skills sections.
        #
        #     Normally, returned skills are limited to those taken from a resume section
        #     intended to list skills. When enabled, this feature causes detected
        #     skills in other sections to also be included in the returned profile.
        class ParseResumeOptions; end

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