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

class ConfigErrorsTest < Minitest::Test
  def test_invalid_name
    error = assert_raises NameError do
      Class.new do
        extend Gapic::Config

        config_attr "some method", nil, String
      end
    end
    assert_equal "invalid config name some method", error.message
  end

  def test_parent_config
    error = assert_raises NameError do
      Class.new do
        extend Gapic::Config

        config_attr "parent_config", nil, String
      end
    end
    assert_equal "invalid config name parent_config", error.message
  end

  def test_existing_method
    error = assert_raises NameError do
      Class.new do
        extend Gapic::Config

        config_attr "methods", nil, String
      end
    end
    assert_equal "method methods already exists", error.message
  end

  def test_missing_validation
    error = assert_raises ArgumentError do
      Class.new do
        extend Gapic::Config

        config_attr "missing_validation", nil
      end
    end
    assert_equal "validation must be provided", error.message
  end
end
