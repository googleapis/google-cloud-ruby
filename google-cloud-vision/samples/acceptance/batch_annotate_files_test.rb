# Copyright 2020 Google LLC
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

require_relative "helper"

require_relative "../batch_annotate_files"

describe "Batch annotate files" do
  it "batch detects text from a local file" do
    assert_output(/Gregor's back was also more elastic than he had thought/) do
      sample_batch_annotate_files image_path("kafka.pdf")
    end
  end
end
