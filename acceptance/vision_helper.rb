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

require "helper"
require "google/cloud/vision"

# Create shared vision object so we don't create new for each test
$vision = Google::Cloud.vision

module Acceptance
  ##
  # Test class for running against a Vision instance.
  # Ensures that there is an active connection for the tests to use.
  #
  # This class can be used with the spec DSL.
  # To do so, add :vision to describe:
  #
  #   describe "My Vision Test", :vision do
  #     it "does a thing" do
  #       your.code.must_be :thing?
  #     end
  #   end
  class VisionTest < Minitest::Test
    attr_accessor :vision

    ##
    # Setup project based on available ENV variables
    def setup
      @vision = $vision

      refute_nil @vision, "You do not have an active vision to run the tests."

      super
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    # Register this spec type for when :vision is used.
    register_spec_type(self) do |desc, *addl|
      addl.include? :vision
    end
  end

  def self.run_one_method klass, method_name, reporter
    result = nil
    (1..3).each do |try|
      result = Minitest.run_one_method(klass, method_name)
      break if (result.passed? || result.skipped?)
      puts "Retrying #{klass}##{method_name} (#{try})"
    end
    reporter.record result
  end
end
