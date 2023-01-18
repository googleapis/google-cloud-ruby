# Copyright 2023 Google LLC
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

require "datastore_helper"

describe "Aggregate Queries", :datastore do

  let(:prefix) { "#{Time.now.utc.iso8601.gsub ":", "_"}_#{SecureRandom.hex(4)}" }

  let(:book) do
    book = Google::Cloud::Datastore::Entity.new.tap do |e|
      e["title"] = "Game of Thrones"
    end
    book.key = Google::Cloud::Datastore::Key.new "Book", "#{prefix}_GoT"
    book
  end

  let(:rickard) do
    character = Google::Cloud::Datastore::Entity.new.tap do |e|
      e["name"]        = "Rickard"
      e["family"]      = "Stark"
      e["appearances"] = 0
      e["alive"]       = false
    end
    character.key = Google::Cloud::Datastore::Key.new "Character", "Rickard"
    character.key.parent = book
    character
  end

  let(:eddard) do
    character = Google::Cloud::Datastore::Entity.new.tap do |e|
      e["name"]        = "Eddard"
      e["family"]      = "Stark"
      e["appearances"] = 9
      e["alive"]       = false
    end
    character.key = Google::Cloud::Datastore::Key.new "Character", "Eddard"
    character.key.parent = rickard
    character
  end

  let(:catelyn) do
    character = Google::Cloud::Datastore::Entity.new.tap do |e|
      e["name"]        = "Catelyn"
      e["family"]      = "Stark"
      e["appearances"] = 26
      e["alive"]       = false
    end
    character.key = Google::Cloud::Datastore::Key.new "Character", "Catelyn"
    character.key.parent = book
    character
  end

  let(:arya) do
    character = Google::Cloud::Datastore::Entity.new.tap do |e|
      e["name"]        = "Arya"
      e["family"]      = "Stark"
      e["appearances"] = 33
      e["alive"]       = true
    end
    character.key = Google::Cloud::Datastore::Key.new "Character", "Arya"
    character.key.parent = eddard
    character
  end

  let(:sansa) do
    character = Google::Cloud::Datastore::Entity.new.tap do |e|
      e["name"]        = "Sansa"
      e["family"]      = "Stark"
      e["appearances"] = 31
      e["alive"]       = true
    end
    character.key = Google::Cloud::Datastore::Key.new "Character", "Sansa"
    character.key.parent = eddard
    character
  end

  let(:robb) do
    character = Google::Cloud::Datastore::Entity.new.tap do |e|
      e["name"]        = "Robb"
      e["family"]      = "Stark"
      e["appearances"] = 22
      e["alive"]       = false
    end
    character.key = Google::Cloud::Datastore::Key.new "Character", "Robb"
    character.key.parent = eddard
    character
  end

  let(:bran) do
    character = Google::Cloud::Datastore::Entity.new.tap do |e|
      e["name"]        = "Bran"
      e["family"]      = "Stark"
      e["appearances"] = 25
      e["alive"]       = true
    end
    character.key = Google::Cloud::Datastore::Key.new "Character", "Bran"
    character.key.parent = eddard
    character
  end

  let(:jon) do
    character = Google::Cloud::Datastore::Entity.new.tap do |e|
      e["name"]        = "Jon"
      e["family"]      = "Targaryen"
      e["appearances"] = 32
      e["alive"]       = true
    end
    character.key = Google::Cloud::Datastore::Key.new "Character", "Jon"
    character.key.parent = eddard
    character
  end

  let(:characters) do
    [rickard, eddard, catelyn, arya, sansa, robb, bran, jon]
  end

  before do
    dataset.transaction { |tx| tx.save *characters }
  end

  after do
    dataset.delete *characters
  end

  describe "via AggregateQuery" do
    
    it "returns 0 for no records" do
      dataset.delete *characters
      query = Google::Cloud::Datastore.new.
        query("Character").
        ancestor(book)
      aggregate_query = query.aggregate_query
                            .add_count
      res = dataset.run_aggregation aggregate_query
      _(res.get('count')).must_equal 0
    end

    it "returns count for non-zero records" do
      query = Google::Cloud::Datastore.new.
        query("Character").
        ancestor(book)
      aggregate_query = query.aggregate_query
                            .add_count
      res = dataset.run_aggregation aggregate_query
      _(res.get('count')).must_equal 8
    end

    it "returns count on filter" do
      query = Google::Cloud::Datastore.new.
        query("Character").
        ancestor(book).
        where("alive", "=", true)
      aggregate_query = query.aggregate_query
                            .add_count
      res = dataset.run_aggregation aggregate_query
      _(res.get('count')).must_equal 4
    end

    it "returns count on limit" do
      query = Google::Cloud::Datastore.new.
        query("Character").
        ancestor(book).
        limit(5)
      aggregate_query = query.aggregate_query
                            .add_count
      res = dataset.run_aggregation aggregate_query
      _(res.get('count')).must_equal 5
    end

    it "returns count with a custom alias" do
      query = Google::Cloud::Datastore.new.
        query("Character").
        ancestor(book)
      aggregate_query = query.aggregate_query
                            .add_count(aggregate_alias: "total")
      res = dataset.run_aggregation aggregate_query
      _(res.get('total')).must_equal 8
    end

    it "returns count with multiple custom aliases" do
      query = Google::Cloud::Datastore.new.
        query("Character").
        ancestor(book)
      aggregate_query = query.aggregate_query
                            .add_count(aggregate_alias: "total_1")
                            .add_count(aggregate_alias: "total_2")
      res = dataset.run_aggregation aggregate_query
      _(res.get('total_1')).must_equal 8
      _(res.get('total_2')).must_equal 8
    end

    it "returns count with unspecified aliases" do
      query = Google::Cloud::Datastore.new.
        query("Character").
        ancestor(book)
      aggregate_query = query.aggregate_query
                            .add_count
      res = dataset.run_aggregation aggregate_query
      _(res.get('unspecified_alias')).must_be :nil?
    end

    it "throws error when duplicating aliases" do
      query = Google::Cloud::Datastore.new.
        query("Character").
        ancestor(book)
      aggregate_query = query.aggregate_query
                            .add_count(aggregate_alias: 'total')
                            .add_count(aggregate_alias: 'total')
      expect { res = dataset.run_aggregation aggregate_query }.must_raise Google::Cloud::InvalidArgumentError
    end

    it "returns different count when data changes" do
      query = Google::Cloud::Datastore.new.
        query("Character").
        ancestor(book)
      aggregate_query = query.aggregate_query
                            .add_count
      res = dataset.run_aggregation aggregate_query
      _(res.get('count')).must_equal 8
      dataset.delete jon.key
      res = dataset.run_aggregation aggregate_query
      _(res.get('count')).must_equal 7
    end
    
    it "throws error when no aggregate is added" do
      query = Google::Cloud::Datastore.new.
        query("Character").
        ancestor(book)
      aggregate_query = query.aggregate_query
      expect { res = dataset.run_aggregation aggregate_query }.must_raise Google::Cloud::InvalidArgumentError
    end

    it "returns count inside a transaction" do
      query = Google::Cloud::Datastore.new.
        query("Character").
        ancestor(book)
      dataset.read_only_transaction do |tx|
        aggregate_query = query.aggregate_query
                               .add_count
        res = dataset.run_aggregation aggregate_query
        _(res.get('count')).must_equal 8
      end
    end
  end

  describe "via GQL" do
    it "returns count for non-zero records" do
      gql = dataset.gql "SELECT COUNT(*) AS total FROM Character WHERE __key__ HAS ANCESTOR @bookKey",
                        bookKey: book.key
      res = dataset.run_aggregation gql
      _(res.get('total')).must_equal 8
    end
  
    it "returns count with a filter" do
      gql = dataset.gql "SELECT COUNT(*) AS total_alive FROM Character WHERE __key__ HAS ANCESTOR @bookKey AND alive = @alive",
                        alive: true, bookKey: book.key
      res = dataset.run_aggregation gql
      _(res.get('total_alive')).must_equal 4
    end

    it "returns count inside a transaction" do
      dataset.read_only_transaction do |tx|
        gql = dataset.gql "SELECT COUNT(*) AS total FROM Character WHERE __key__ HAS ANCESTOR @bookKey",
                          bookKey: book.key
        res = dataset.run_aggregation gql
        _(res.get('total')).must_equal 8
      end
    end
  end

end
