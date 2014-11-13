# Copyright 2014 Google Inc. All rights reserved.
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
require "gcloud/datastore/entity"
require "gcloud/datastore/key"

##
# These tests are not part of the public API.
# These tests are testing the implementation.
# Similar to testing private methods.

describe "Proto Direction methods" do
  describe "PropertyOrder Direction" do
    it "defaults to ascending" do
      assert_ascending nil
      assert_ascending ""
      assert_ascending 123
    end

    it "is ascending when ascending" do
      assert_ascending "asc"
      assert_ascending "ascending"
      assert_ascending :asc
      assert_ascending :ascending
      assert_ascending "ASC"
      assert_ascending "ASCENDING"
    end

    it "is descending when given 'd' direction" do
      assert_descending "desc"
      assert_descending "descending"
      assert_descending :desc
      assert_descending :descending
      assert_descending "DESC"
      assert_descending "DESCENDING"
    end

    def assert_ascending direction
      assert_equal Gcloud::Datastore::Proto::PropertyOrder::Direction::ASCENDING,
                   Gcloud::Datastore::Proto.to_prop_order_direction(direction)
    end

    def assert_descending direction
      assert_equal Gcloud::Datastore::Proto::PropertyOrder::Direction::DESCENDING,
                   Gcloud::Datastore::Proto.to_prop_order_direction(direction)
    end
  end
end
