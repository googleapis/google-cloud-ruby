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

require "test_helper"

require "gapic/config"

class NestedConfig
  extend Gapic::Config

  config_attr :str, "default str", String
  config_attr :str_nil, nil, String
  config_attr :bool, true, true, false
  config_attr :bool_nil, nil, true, false, nil
  config_attr :enum, :one, :one, :two, :three
  config_attr :opt_regex, "hi", /^[a-z]+$/
  config_attr :opt_class, "hi", String, Symbol

  def initialize parent_config = nil
    @parent_config = parent_config unless parent_config.nil?
    yield self if block_given?
  end
end

class NestedConfigTest < Minitest::Spec
  def setup
    @parent_config = NestedConfig.new do |config|
      config.str = "updated str"
      config.bool = false
      config.enum = :two
      config.opt_regex = "hello"
      config.opt_class = :hi
    end
  end

  def test_str
    config = NestedConfig.new @parent_config
    assert_equal "updated str", config.str

    config.str = "FooBar"
    assert_equal "FooBar", config.str

    config.str = nil
    assert_equal "updated str", config.str # reset to parent

    @parent_config.str = nil
    assert_equal "default str", config.str # reset to default
  end

  def test_str_validation
    config = NestedConfig.new @parent_config

    assert_raises ArgumentError do
      config.str = 1
    end

    assert_raises ArgumentError do
      config.str = true
    end

    assert_raises ArgumentError do
      config.str = :one
    end

    assert_raises ArgumentError do
      config.str = { hello: :world }
    end
  end

  def test_str_nil
    config = NestedConfig.new @parent_config
    assert_nil config.str_nil

    config.str_nil = "FooBar"
    assert_equal "FooBar", config.str_nil

    config.str_nil = nil
    assert_nil config.str_nil
  end

  def test_bool
    config = NestedConfig.new @parent_config
    assert_equal false, config.bool

    config.bool = true
    assert_equal true, config.bool

    config.bool = nil
    assert_equal false, config.bool # reset to parent

    @parent_config.bool = nil
    assert_equal true, config.bool # reset to default
  end

  def test_bool_validation
    config = NestedConfig.new @parent_config

    assert_raises ArgumentError do
      config.bool = 1
    end

    assert_raises ArgumentError do
      config.bool = "hi"
    end

    assert_raises ArgumentError do
      config.bool = :one
    end

    assert_raises ArgumentError do
      config.bool = { hello: :world }
    end
  end

  def test_enum
    config = NestedConfig.new @parent_config
    assert_equal :two, config.enum

    config.enum = :one
    assert_equal :one, config.enum

    config.enum = :three
    assert_equal :three, config.enum

    config.enum = nil
    assert_equal :two, config.enum # reset to parent

    @parent_config.enum = nil
    assert_equal :one, config.enum # reset to default
  end

  def test_enum_validation
    config = NestedConfig.new @parent_config

    assert_raises ArgumentError do
      config.enum = 1
    end

    assert_raises ArgumentError do
      config.enum = "hi"
    end

    assert_raises ArgumentError do
      config.enum = true
    end

    assert_raises ArgumentError do
      config.enum = { hello: :world }
    end
  end

  def test_opt_regex
    config = NestedConfig.new @parent_config
    assert_equal "hello", config.opt_regex

    config.opt_regex = "world"
    assert_equal "world", config.opt_regex

    config.opt_regex = nil
    assert_equal "hello", config.opt_regex # reset to parent

    @parent_config.opt_regex = nil
    assert_equal "hi", config.opt_regex # reset to default
  end

  def test_opt_regex_validation
    config = NestedConfig.new @parent_config

    assert_raises ArgumentError do
      config.opt_regex = "hello world"
    end

    assert_raises ArgumentError do
      config.opt_regex = "Hi"
    end

    assert_raises ArgumentError do
      config.opt_regex = "hi!"
    end

    assert_raises ArgumentError do
      config.enum = 1
    end

    assert_raises ArgumentError do
      config.enum = true
    end

    assert_raises ArgumentError do
      config.opt_regex = { hello: :world }
    end
  end

  def test_opt_class
    config = NestedConfig.new @parent_config
    assert_equal :hi, config.opt_class

    config.opt_class = "Hello World!"
    assert_equal "Hello World!", config.opt_class

    config.opt_class = nil
    assert_equal :hi, config.opt_class # reset to parent

    @parent_config.opt_class = nil
    assert_equal "hi", config.opt_class # reset to default
  end

  def test_opt_class_validation
    config = NestedConfig.new @parent_config

    assert_raises ArgumentError do
      config.enum = 1
    end

    assert_raises ArgumentError do
      config.enum = true
    end

    assert_raises ArgumentError do
      config.opt_class = { hello: :world }
    end
  end
end
