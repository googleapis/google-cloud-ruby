# Copyright 2025 Google, Inc
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

require "uri"

require_relative "helper"

describe "#view_secret_annotations", :secret_manager_snippet do
  it "view the secret annotations" do
    sample = SampleLoader.load "view_secret_annotations.rb"

    refute_nil secret

    out, _err = capture_io do
      sample.run project_id: project_id, secret_id: secret_id
    end

    assert_match(/Secret/, out)
    assert_match(/Annotation Key: #{Regexp.escape annotation_key}, Annotation Value: #{Regexp.escape annotation_value}/, out)
  end
end
