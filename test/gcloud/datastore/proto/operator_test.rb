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

describe "Proto Operator methods" do
  describe "Property Filter Operators" do
    it "can convert strings" do
      assert_prop_filter_op "<"   , Gcloud::Datastore::Proto::PropertyFilter::Operator::LESS_THAN
      assert_prop_filter_op "lt"  , Gcloud::Datastore::Proto::PropertyFilter::Operator::LESS_THAN
      assert_prop_filter_op "<="  , Gcloud::Datastore::Proto::PropertyFilter::Operator::LESS_THAN_OR_EQUAL
      assert_prop_filter_op "lte" , Gcloud::Datastore::Proto::PropertyFilter::Operator::LESS_THAN_OR_EQUAL
      assert_prop_filter_op ">"   , Gcloud::Datastore::Proto::PropertyFilter::Operator::GREATER_THAN
      assert_prop_filter_op "gt"  , Gcloud::Datastore::Proto::PropertyFilter::Operator::GREATER_THAN
      assert_prop_filter_op ">="  , Gcloud::Datastore::Proto::PropertyFilter::Operator::GREATER_THAN_OR_EQUAL
      assert_prop_filter_op "gte" , Gcloud::Datastore::Proto::PropertyFilter::Operator::GREATER_THAN_OR_EQUAL
      assert_prop_filter_op "="   , Gcloud::Datastore::Proto::PropertyFilter::Operator::EQUAL
      assert_prop_filter_op "eq"  , Gcloud::Datastore::Proto::PropertyFilter::Operator::EQUAL
      assert_prop_filter_op "eql" , Gcloud::Datastore::Proto::PropertyFilter::Operator::EQUAL
      assert_prop_filter_op "~"            , Gcloud::Datastore::Proto::PropertyFilter::Operator::HAS_ANCESTOR
      assert_prop_filter_op "~>"           , Gcloud::Datastore::Proto::PropertyFilter::Operator::HAS_ANCESTOR
      assert_prop_filter_op "ancestor"     , Gcloud::Datastore::Proto::PropertyFilter::Operator::HAS_ANCESTOR
      assert_prop_filter_op "has_ancestor" , Gcloud::Datastore::Proto::PropertyFilter::Operator::HAS_ANCESTOR
      assert_prop_filter_op "has ancestor" , Gcloud::Datastore::Proto::PropertyFilter::Operator::HAS_ANCESTOR
    end

    it "can convert symbols" do
      assert_prop_filter_op :<   , Gcloud::Datastore::Proto::PropertyFilter::Operator::LESS_THAN
      assert_prop_filter_op :lt  , Gcloud::Datastore::Proto::PropertyFilter::Operator::LESS_THAN
      assert_prop_filter_op :<=  , Gcloud::Datastore::Proto::PropertyFilter::Operator::LESS_THAN_OR_EQUAL
      assert_prop_filter_op :lte , Gcloud::Datastore::Proto::PropertyFilter::Operator::LESS_THAN_OR_EQUAL
      assert_prop_filter_op :>   , Gcloud::Datastore::Proto::PropertyFilter::Operator::GREATER_THAN
      assert_prop_filter_op :gt  , Gcloud::Datastore::Proto::PropertyFilter::Operator::GREATER_THAN
      assert_prop_filter_op :>=  , Gcloud::Datastore::Proto::PropertyFilter::Operator::GREATER_THAN_OR_EQUAL
      assert_prop_filter_op :gte , Gcloud::Datastore::Proto::PropertyFilter::Operator::GREATER_THAN_OR_EQUAL
      #               := is not a valid symbol
      assert_prop_filter_op :"=" , Gcloud::Datastore::Proto::PropertyFilter::Operator::EQUAL
      assert_prop_filter_op :eq  , Gcloud::Datastore::Proto::PropertyFilter::Operator::EQUAL
      assert_prop_filter_op :eql , Gcloud::Datastore::Proto::PropertyFilter::Operator::EQUAL
      assert_prop_filter_op :~            , Gcloud::Datastore::Proto::PropertyFilter::Operator::HAS_ANCESTOR
      #               :~> is not a valid symbol
      assert_prop_filter_op :"~>"         , Gcloud::Datastore::Proto::PropertyFilter::Operator::HAS_ANCESTOR
      assert_prop_filter_op :ancestor     , Gcloud::Datastore::Proto::PropertyFilter::Operator::HAS_ANCESTOR
      assert_prop_filter_op :has_ancestor , Gcloud::Datastore::Proto::PropertyFilter::Operator::HAS_ANCESTOR
    end

    it "can handle unexpected values" do
      assert_prop_filter_op nil   , Gcloud::Datastore::Proto::PropertyFilter::Operator::EQUAL
      assert_prop_filter_op ""    , Gcloud::Datastore::Proto::PropertyFilter::Operator::EQUAL
      assert_prop_filter_op "foo" , Gcloud::Datastore::Proto::PropertyFilter::Operator::EQUAL
    end

    def assert_prop_filter_op string, proto
      op = Gcloud::Datastore::Proto.to_prop_filter_op string
      op.must_equal proto
    end
  end
end
