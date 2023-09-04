# Copyright 2022 Google LLC
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

require "firestore_helper"

describe "Aggregate Query", :firestore_acceptance do
  let :expected_error_class do
    if Google::Cloud.configure.firestore.transport == :rest
      Gapic::Rest::Error
    else
      GRPC::InvalidArgument
    end
  end

  describe "COUNT" do
    it "returns count for non-zero records" do
      rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
      rand_query_col.add({foo: "a"})
      rand_query_col.add({bar: "b"})
      rand_query_col.add({qux: "c"})

      aq = rand_query_col.aggregate_query
                         .add_count

      snapshot = aq.get.first
      _(snapshot.get).must_equal 3
    end

    it "returns 0 for no records" do
      rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"

      aq = rand_query_col.aggregate_query
                         .add_count

      snapshot = aq.get.first
      _(snapshot.get).must_equal 0
    end

    it "returns count on filter" do
      rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
      rand_query_col.add({foo: "a"})
      rand_query_col.add({bar: "b"})

      query = rand_query_col.where(:foo, :==, :a)

      aq = query.aggregate_query
                .add_count

      snapshot = aq.get.first
      _(snapshot.get).must_equal 1
    end

    it "returns count on limit" do
      rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
      rand_query_col.add({foo: "a"})
      rand_query_col.add({bar: "b"})
      rand_query_col.add({qux: "c"})

      query = rand_query_col.limit 2

      aq = query.aggregate_query
                .add_count

      snapshot = aq.get.first
      _(snapshot.get).must_equal 2
    end

    it "returns count with a custom alias" do
      rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
      rand_query_col.add({foo: "a"})
      rand_query_col.add({bar: "b"})
      rand_query_col.add({qux: "c"})

      aq = rand_query_col.aggregate_query
                         .add_count aggregate_alias: 'one'

      snapshot = aq.get.first
      _(snapshot.get).must_equal 3
      _(snapshot.get('one')).must_equal 3
    end

    it "returns count with multiple custom aliases" do
      rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
      rand_query_col.add({foo: "a"})
      rand_query_col.add({bar: "b"})
      rand_query_col.add({qux: "c"})

      aq = rand_query_col.aggregate_query
                         .add_count(aggregate_alias: 'one')
                         .add_count(aggregate_alias: 'two')

      snapshot = aq.get.first
      _(snapshot.get('one')).must_equal 3
      _(snapshot.get('two')).must_equal 3
    end

    it "returns nil for unspecified alias" do
      rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
      rand_query_col.add({foo: "a"})
      rand_query_col.add({bar: "b"})
      rand_query_col.add({qux: "c"})

      aq = rand_query_col.aggregate_query
                         .add_count

      snapshot = aq.get.first
      _(snapshot.get('unspecified_alias')).must_be :nil?
    end

    it "throws error when custom alias isn't specified for multiple aliases" do
      rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
      rand_query_col.add({foo: "a"})
      rand_query_col.add({bar: "b"})
      rand_query_col.add({qux: "c"})

      aq = rand_query_col.aggregate_query
                         .add_count(aggregate_alias: 'one')
                         .add_count(aggregate_alias: 'two')

      snapshot = aq.get.first
      expect { snapshot.get }.must_raise ArgumentError
    end

    it "throws error when duplicating aliases" do
      rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
      rand_query_col.add({foo: "a"})
      rand_query_col.add({bar: "b"})
      rand_query_col.add({qux: "c"})

      aq = rand_query_col.aggregate_query
                         .add_count(aggregate_alias: 'one')
                         .add_count(aggregate_alias: 'one')

      expect { snapshot = aq.get.first }.must_raise expected_error_class
    end


    it "returns count for multiple requests" do
      rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
      rand_query_col.add({foo: "a"})
      rand_query_col.add({bar: "b"})
      rand_query_col.add({qux: "c"})

      aq = rand_query_col.aggregate_query
                         .add_count

      snapshot = aq.get.first
      _(snapshot.get).must_equal 3

      snapshot = aq.get.first
      _(snapshot.get).must_equal 3
    end

    it "returns different count when data changes" do
      rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
      rand_query_col.add({foo: "a"})
      rand_query_col.add({bar: "b"})
      rand_query_col.add({qux: "c"})

      aq = rand_query_col.aggregate_query
                         .add_count

      snapshot = aq.get.first
      _(snapshot.get).must_equal 3

      rand_query_col.doc("doc4").create({foo: "d"})

      snapshot = aq.get.first
      _(snapshot.get).must_equal 4
    end

    it "throws error when no aggregate is added" do
      rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
      rand_query_col.add({foo: "a"})
      rand_query_col.add({bar: "b"})
      rand_query_col.add({qux: "c"})

      # aggregate object with no added aggregate (ex: aq.add_count)
      aq = rand_query_col.aggregate_query

      expect { snapshot = aq.get.first }.must_raise expected_error_class
    end

    it "returns count inside a transaction" do
      rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
      rand_query_col.add({foo: "a"})
      rand_query_col.add({bar: "b"})
      rand_query_col.add({qux: "c"})

      aq = rand_query_col.aggregate_query
                         .add_count

      results = firestore.transaction do |tx|
        tx.get_aggregate(aq).to_a
      end

      snapshot = results.first
      _(snapshot.get).must_equal 3
    end
  end
end
