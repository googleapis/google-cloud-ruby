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
require "google/cloud/config"

class CoreConfig
  extend Gapic::Config

  config_attr :str, "default str", String
  config_attr :str_nil, nil, String, nil
  config_attr :bool, true, true, false
  config_attr :bool_nil, nil, true, false, nil
  config_attr :enum, :one, :one, :two, :three
  config_attr :opt_regex, "hi", /^[a-z]+$/
  config_attr :opt_class, "hi", String, Symbol

  def initialize parent_config = nil
    @parent_config = parent_config unless parent_config == nil
    yield self if block_given?
  end
end

class CoreConfigTest < Minitest::Spec
  def setup
    @parent_config = Google::Cloud::Config.create do |c1|
      c1.add_field! :str, "default str", match: String
      c1.add_field! :str_nil, nil, match: String, allow_nil: true
      c1.add_field! :bool, true
      c1.add_field! :bool_nil, true, allow_nil: true
      c1.add_field! :enum, :one, enum: [:one, :two, :three]
      c1.add_field! :opt_regex, "hi", match: /^[a-z]+$/
      c1.add_field! :opt_class, "hi", match: [String, Symbol]
    end

    @parent_config.str = "updated str"
    @parent_config.bool = false
    @parent_config.enum = :two
    @parent_config.opt_regex = "hello"
    @parent_config.opt_class = :hi
  end

  def test_str
    config = CoreConfig.new @parent_config
    assert_equal "updated str", config.str

    config.str = "FooBar"
    assert_equal "FooBar", config.str

    config.str = nil
    assert_equal "updated str", config.str # reset to parent

    @parent_config.str = "updated again str"
    assert_equal "updated again str", config.str # use parent
  end

  def test_str_validation
    config = CoreConfig.new @parent_config

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

  def test_bool
    config = CoreConfig.new @parent_config
    assert_equal false, config.bool

    config.bool = true
    assert_equal true, config.bool

    config.bool = nil
    assert_equal false, config.bool # reset to parent

    @parent_config.bool = true
    assert_equal true, config.bool # use parent
  end

  def test_bool_validation
    config = CoreConfig.new @parent_config

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
    config = CoreConfig.new @parent_config
    assert_equal :two, config.enum

    config.enum = :one
    assert_equal :one, config.enum

    config.enum = :three
    assert_equal :three, config.enum

    config.enum = nil
    assert_equal :two, config.enum # reset to parent

    @parent_config.enum = :one
    assert_equal :one, config.enum # use parent
  end

  def test_enum_validation
    config = CoreConfig.new @parent_config

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
    config = CoreConfig.new @parent_config
    assert_equal "hello", config.opt_regex

    config.opt_regex = "world"
    assert_equal "world", config.opt_regex

    config.opt_regex = nil
    assert_equal "hello", config.opt_regex # reset to parent

    @parent_config.opt_regex = "hi"
    assert_equal "hi", config.opt_regex # use parent
  end

  def test_opt_regex_validation
    config = CoreConfig.new @parent_config

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
    config = CoreConfig.new @parent_config
    assert_equal :hi, config.opt_class

    config.opt_class = "Hello World!"
    assert_equal "Hello World!", config.opt_class

    config.opt_class = nil
    assert_equal :hi, config.opt_class # reset to parent

    @parent_config.opt_class = "hi"
    assert_equal "hi", config.opt_class # use parent
  end

  def test_opt_class_validation
    config = CoreConfig.new @parent_config

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
