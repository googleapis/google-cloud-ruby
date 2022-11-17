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

  focus; it "returns count for non-zero records" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "a"})
    rand_query_col.add({bar: "b"})
    rand_query_col.add({qux: "c"})

    aq = rand_query_col.aggregate_query
    aq.add_count

    aq.get do |snapshot|
      _(snapshot.get('count')).must_equal 3
    end
  end

  focus; it "returns 0 for no records" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    
    aq = rand_query_col.aggregate_query
    aq.add_count

    aq.get do |snapshot|
      _(snapshot.get('count')).must_equal 0
    end
  end

  focus; it "returns count on filter" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "a"})
    rand_query_col.add({bar: "b"})

    query = rand_query_col.where(:foo, :==, :a)
    
    aq = query.aggregate_query
    aq.add_count

    aq.get do |snapshot|
      _(snapshot.get('count')).must_equal 1
    end
  end

  focus; it "returns count on limit" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "a"})
    rand_query_col.add({bar: "b"})
    rand_query_col.add({qux: "c"})

    query = rand_query_col.limit 2
    
    aq = query.aggregate_query
    aq.add_count

    aq.get do |snapshot|
      _(snapshot.get('count')).must_equal 2
    end
  end

  focus; it "returns count with a custom alias" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "a"})
    rand_query_col.add({bar: "b"})
    rand_query_col.add({qux: "c"})

    aq = rand_query_col.aggregate_query
    aq.add_count aggregate_alias: 'one'

    aq.get do |snapshot|
      _(snapshot.get('one')).must_equal 3
    end
  end

  focus; it "returns count with multiple custom aliases" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "a"})
    rand_query_col.add({bar: "b"})
    rand_query_col.add({qux: "c"})

    aq = rand_query_col.aggregate_query
    aq.add_count aggregate_alias: 'one'
    aq.add_count aggregate_alias: 'two'

    aq.get do |snapshot|
      _(snapshot.get('one')).must_equal 3
      _(snapshot.get('two')).must_equal 3
    end
  end
  
  focus; it "returns nil for unspecified alias" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "a"})
    rand_query_col.add({bar: "b"})
    rand_query_col.add({qux: "c"})

    aq = rand_query_col.aggregate_query
    aq.add_count

    aq.get do |snapshot|
      _(snapshot.get('unspecified_alias')).must_be :nil?
    end
  end

  focus; it "throws error when duplicating aliases" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "a"})
    rand_query_col.add({bar: "b"})
    rand_query_col.add({qux: "c"})

    aq = rand_query_col.aggregate_query
    aq.add_count aggregate_alias: 'one'
    aq.add_count aggregate_alias: 'one'

    expect do
      aq.get { |snapshot| }
    end.must_raise GRPC::InvalidArgument
  end


  focus; it "returns count for multiple requests" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "a"})
    rand_query_col.add({bar: "b"})
    rand_query_col.add({qux: "c"})

    aq = rand_query_col.aggregate_query
    aq.add_count

    aq.get do |snapshot|
      _(snapshot.get('count')).must_equal 3
    end

    aq.get do |snapshot|
      _(snapshot.get('count')).must_equal 3
    end
  end

  focus; it "returns different count when data changes" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "a"})
    rand_query_col.add({bar: "b"})
    rand_query_col.add({qux: "c"})

    aq = rand_query_col.aggregate_query
    aq.add_count

    aq.get do |snapshot|
      _(snapshot.get('count')).must_equal 3
    end

    # insert more data
    rand_query_col.doc("doc4").create({foo: "d"})

    aq.get do |snapshot|
      _(snapshot.get('count')).must_equal 4
    end
  end
  
  focus; it "throws error when no aggregate is added" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.add({foo: "a"})
    rand_query_col.add({bar: "b"})
    rand_query_col.add({qux: "c"})

    # aggregate object with no added aggregate (ex: aq.add_count)
    aq = rand_query_col.aggregate_query

    expect do
      aq.get { |snapshot| }
    end.must_raise GRPC::InvalidArgument
  end
end