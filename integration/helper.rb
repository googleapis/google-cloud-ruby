# Copyright 2016 Google Inc. All rights reserved.
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


require "fileutils"
require "open3"

##
# Keep trying a block of code until the code of block yield a true statement or
# raise error after timeout
def keep_trying_till_true timeout = 30
  t_begin = Time.now
  loop do
    if yield
      break
    elsif (Time.now - t_begin) > timeout
      fail "Timeout after trying for #{timeout} seconds"
    else
      sleep 1
    end
  end
end

##
# Get GCP project id from Gcloud SDK
def gcloud_project_id
  stdout = Open3.capture3("gcloud config list project").first
  stdout.scan(/project = (.*)/).first.first
end
