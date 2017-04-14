# Copyright 2017 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0oud
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"
require "stackdriver/core/configuration"

describe Stackdriver::Core::Configuration do
  let(:options) { [:k1, :k2, {k3: [:k4, :k5]}, :k6] }
  let(:configuration) { Stackdriver::Core::Configuration.new options: options }

  describe "#initialize" do
    it "accepts no parameters" do
      config = Stackdriver::Core::Configuration.new

      config.must_be_kind_of Stackdriver::Core::Configuration
    end

    it "accepts empty fields array" do
      config = Stackdriver::Core::Configuration.new options: []

      config.must_be_kind_of Stackdriver::Core::Configuration
    end

    it "initializes options to nil" do
      configs = configuration.instance_variable_get :@configs

      configs[:k1].must_be_nil
      configs[:k6].must_be_nil
    end

    it "initalizes all the option keys" do
      configs = configuration.instance_variable_get :@configs

      [:k1, :k2, :k3, :k6].all? { |k| configs.key? k }.must_equal true
    end

    it "initializes nested Stackdriver::Core::Configuration" do
      configs = configuration.instance_variable_get :@configs

      nested_configuration = configs[:k3]
      nested_configs = nested_configuration.instance_variable_get :@configs

      nested_configuration.must_be_kind_of Stackdriver::Core::Configuration
      nested_configs.key?(:k4).must_equal true
      nested_configs.key?(:k5).must_equal true
    end
  end

  describe "#method_missing" do
    it "gets a valid option" do
      configuration.k1.must_be_nil
    end

    it "sets a valid option" do
      configuration.k1 = "test value"

      configuration.k1.must_equal "test value"

      configs = configuration.instance_variable_get :@configs

      configs[:k1].must_equal "test value"
    end

    it "gets a valid nested option" do
      configuration.k3.k4.must_be_nil
    end

    it "sets a valid nested option" do
      configuration.k3.k4 = "test value"

      configuration.k3.k4.must_equal "test value"
    end

    it "raises exception if setting a nested category" do
      configuration.k3.k4 = "test value"

      e = assert_raises RuntimeError do
        configuration.k3 = "test value 2"
      end

      configuration.k3.k4.must_equal "test value"
      e.message.must_match "is not a configuration option"
    end

    it "raises exception if setting a non-valid option" do
      e = assert_raises RuntimeError do
        configuration.foo = "test value"
      end
      e.message.must_match "Unrecognized Option: foo"
    end

    it "raises exception if setting a non-valid nested option" do
      e = assert_raises RuntimeError do
        configuration.k3.foo = "test value"
      end
      e.message.must_match "Unrecognized Option: foo"
    end
  end
end
