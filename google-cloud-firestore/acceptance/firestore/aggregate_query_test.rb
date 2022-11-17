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

  focus; it "works with single named alias" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})
    rand_query_col.doc("doc3").create({foo: "c"})

    aq = rand_query_col.aggregate_query

    aq.add_count aggregate_alias: 'one'

    aq.get do |snapshot|
      _(snapshot.get('one')).must_equal 3
    end
  end

  focus; it "works with multiple named alias" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})
    rand_query_col.doc("doc3").create({foo: "c"})

    aq = rand_query_col.aggregate_query

    aq.add_count aggregate_alias: 'one'
    aq.add_count aggregate_alias: 'two'

    aq.get do |snapshot|
      _(snapshot.get('one')).must_equal 3
      _(snapshot.get('two')).must_equal 3
    end
  end

  focus; it "works with unnamed alias" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})
    rand_query_col.doc("doc3").create({foo: "c"})

    aq = rand_query_col.aggregate_query

    aq.add_count

    aq.get do |snapshot|
      _(snapshot.get('count')).must_equal 3
    end
  end
  
  focus; it "returns nil for unspecified alias" do
    rand_query_col = firestore.col "#{root_path}/query/#{SecureRandom.hex(4)}"
    rand_query_col.doc("doc1").create({foo: "a"})
    rand_query_col.doc("doc2").create({foo: "b"})
    rand_query_col.doc("doc3").create({foo: "c"})

    aq = rand_query_col.aggregate_query

    aq.add_count

    aq.get do |snapshot|
      _(snapshot.get('afdas')).must_be :nil?
    end
  end


end