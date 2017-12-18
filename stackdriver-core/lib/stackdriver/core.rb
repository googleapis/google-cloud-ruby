# Copyright 2016 Google LLC
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


require "google/cloud/configuration"
require "stackdriver/core/async_actor"
require "stackdriver/core/configuration"
require "stackdriver/core/trace_context"
require "stackdriver/core/version"

module Stackdriver
  ##
  # The Stackdriver::Core module is a namespace for common types and shared
  # utilities used by the Google Stackdriver libraries. Most applications will
  # not need to use these classes directly.
  #
  module Core
  end
end
