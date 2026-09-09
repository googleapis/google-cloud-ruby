# Copyright 2017 Google LLC
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


require "minitest/autorun"
require "minitest/rg"
require "minitest/focus"
require "net/http"
require "google/cloud/trace"
require_relative "../../integration/helper"

$tracer = Google::Cloud::Trace.new project: gcloud_project_id

module Integration
  class TraceTest < Minitest::Test
    ##
    # Setup shared trace client before each test
    def setup
      @tracer = $tracer

      refute_nil @tracer, "You do not have an active trace client to run the tests."
      super
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    # Register this spec type for when :trace is used.
    register_spec_type(self) do |desc, *addl|
      addl.include? :trace
    end
  end
end
