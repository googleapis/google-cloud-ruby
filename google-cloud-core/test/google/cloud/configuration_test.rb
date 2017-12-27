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


require "helper"
require "google/cloud/configuration"

describe Google::Cloud::Configuration do
  let(:nested_categories) { [:k1, {k2: [:k3]}] }
  let(:configuration) { Google::Cloud::Configuration.new nested_categories }

  describe "#initialize" do
    it "works with no parameters" do
      config = Google::Cloud::Configuration.new

      config.must_be_kind_of Google::Cloud::Configuration
    end

    it "accepts empty fields array" do
      config = Google::Cloud::Configuration.new []

      config.must_be_kind_of Google::Cloud::Configuration
    end

    it "initializes options to nil" do
      configuration.opt1.must_be_nil
      configuration.opt2.must_be_nil
    end

    it "initializes nested Google::Cloud::Configuration" do
      configuration.k1.must_be_kind_of Google::Cloud::Configuration
      configuration.k2.must_be_kind_of Google::Cloud::Configuration
      configuration.k2.k3.must_be_kind_of Google::Cloud::Configuration
    end

    it "accepts hash too" do
      config = Google::Cloud::Configuration.new k1: {k2: [:k3]}

      config.k1.must_be_kind_of Google::Cloud::Configuration
      config.k1.k2.must_be_kind_of Google::Cloud::Configuration
      config.k1.k2.k3.must_be_kind_of Google::Cloud::Configuration
    end
  end

  describe "#add_options" do
    it "introduces new nested categories" do
      configuration.k4.must_be_nil

      configuration.add_options [:k4, {k5: [:k6]}]

      configuration.k4.must_be_kind_of Google::Cloud::Configuration
      configuration.k5.must_be_kind_of Google::Cloud::Configuration
      configuration.k5.k6.must_be_kind_of Google::Cloud::Configuration
    end

    it "accepts simple hash with one symbol" do
      configuration.k4.must_be_nil

      configuration.add_options k4: :k5

      configuration.k4.must_be_kind_of Google::Cloud::Configuration
      configuration.k4.k5.must_be_kind_of Google::Cloud::Configuration
    end
  end

  describe "#option?" do
    it "returns true if configuration has that option" do
      configuration.option?(:opt1).must_equal false
      configuration.opt1 = true
      configuration.option?(:opt1).must_equal true
    end

    it "returns true even if the key is a sub configuration group" do
      configuration.k2.must_be_kind_of Google::Cloud::Configuration
      configuration.option?(:k2).must_equal true
    end

    it "returns false if configuration doesn't have that option" do
      configuration.option?(:k7).must_equal false
    end
  end

  describe "#clear" do
    it "removes existing options" do
      configuration.option?(:foo).must_equal false
      configuration.foo = true
      configuration.option?(:foo).must_equal true
      configuration.clear
      configuration.option?(:foo).must_equal false
    end

    it "returns true even if the key is a sub configuration group" do
      configuration.k2.must_be_kind_of Google::Cloud::Configuration
      configuration.option?(:k2).must_equal true
    end

    it "returns false if configuration doesn't have that option" do
      configuration.option?(:k7).must_equal false
    end
  end

  describe "#method_missing" do
    it "any keys are allowed" do
      configuration.total_non_sense.must_be_nil
    end

    it "sets and get a valid option" do
      configuration.opt1.must_be_nil
      configuration.opt1 = "test value"
      configuration.opt1.must_equal "test value"
    end

    it "gets a valid nested option" do
      configuration.k1.opt4.must_be_nil
    end

    it "sets a valid nested option" do
      configuration.k2.k3 = "test value"

      configuration.k2.k3.must_equal "test value"
    end
  end
end
