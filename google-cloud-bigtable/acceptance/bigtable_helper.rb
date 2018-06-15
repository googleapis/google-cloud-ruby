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

gem "minitest"
require "minitest/autorun"

require "google/cloud/bigtable"
require "google/cloud/bigtable/client"
require "google/cloud/bigtable/config"
require "google/cloud/bigtable/cluster"

$bigtable_config = Google::Cloud::Bigtable::Config.new ENV["BIGTABLE_PROJECT"]
$bigtable = Google::Cloud::Bigtable::Client.new $bigtable_config

##
# Test class to run Bigtable tests.
#
class BigtableTest < Minitest::Test
  attr_accessor :bigtable, :config

  extend Minitest::Spec::DSL

  def setup
    @bigtable = $bigtable
    @config = $bigtable_config
    super
  end

  register_spec_type(self) do |desc, *addl|
    addl.include? :bigtable
  end
end
