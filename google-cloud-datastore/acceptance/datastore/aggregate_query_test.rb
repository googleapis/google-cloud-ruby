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

  let(:eddard) do
    character = Google::Cloud::Datastore::Entity.new.tap do |e|
      e["name"]        = "Eddard"
      e["family"]      = "Stark"
      e["appearances"] = 9
      e["alive"]       = false
    end
    character.key = Google::Cloud::Datastore::Key.new "Character", "Eddard"
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

  let(:george) do
    character = Google::Cloud::Datastore::Entity.new.tap do |e|
      e["name"]        = "George"
      e["family"]      = "Martin"
      e["appearances"] = 1
      e["alive"]       = true
    end
    character.key = Google::Cloud::Datastore::Key.new "Character", "George"
    character.key.parent = book
    character
  end

  let(:characters) do
    [eddard, arya, bran, george]
  end

  before do
    dataset.transaction { |tx| tx.save *characters }
  end

  after do
    dataset.delete *characters
  end

  describe "Common tests for aggregates" do
    it "throws error when no aggregate is added" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
      expect { dataset.run_aggregation aggregate_query }.must_raise Google::Cloud::InvalidArgumentError
    end
  end

  describe "COUNT via AggregateQuery" do
    
    it "returns 0 for no records" do
      dataset.delete *characters
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_count
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 0
    end

    it "returns count for non-zero records" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_count
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 4
    end

    it "returns count on filter" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
                .where("alive", "=", false)
      aggregate_query = query.aggregate_query
                            .add_count
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 1
    end

    it "returns count on filter with and without read time" do
      read_time = Time.now
      sleep(1)

      arya["alive"] = false
      dataset.transaction { |tx| tx.save arya }

      query = Google::Cloud::Datastore.new
                                      .query("Character")
                                      .ancestor(book)
                                      .where("alive", "=", false)
      aggregate_query = query.aggregate_query
                             .add_count

      res = dataset.run_aggregation aggregate_query, read_time: read_time
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 1
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 2
    end

    it "returns count on limit" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
                .limit(2)
      aggregate_query = query.aggregate_query
                             .add_count
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 2
    end

    it "returns count with a custom alias" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_count(aggregate_alias: "total")
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 4
      _(res.get('total')).must_be_kind_of Integer
      _(res.get('total')).must_equal 4
    end

    it "returns count with multiple custom aliases" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_count(aggregate_alias: "total_1")
                             .add_count(aggregate_alias: "total_2")
      res = dataset.run_aggregation aggregate_query
      _(res.get('total_1')).must_be_kind_of Integer
      _(res.get('total_1')).must_equal 4
      _(res.get('total_2')).must_be_kind_of Integer
      _(res.get('total_2')).must_equal 4
    end

    it "returns nil with unspecified aliases" do
      query = Google::Cloud::Datastore.new.
        query("Character").
        ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_count
      res = dataset.run_aggregation aggregate_query
      _(res.get('unspecified_alias')).must_be :nil?
    end

    it "throws error when duplicating aliases" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_count(aggregate_alias: 'total')
                             .add_count(aggregate_alias: 'total')
      expect { res = dataset.run_aggregation aggregate_query }.must_raise Google::Cloud::InvalidArgumentError
    end

    it "throws error when custom alias isn't specified for multiple aliases" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_count(aggregate_alias: 'total_1')
                             .add_count(aggregate_alias: 'total_2')
      res = dataset.run_aggregation aggregate_query
      expect { res.get }.must_raise ArgumentError
    end

    it "returns different count when data changes" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_count
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 4
      dataset.delete bran.key
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 3
    end

    it "returns count inside a transaction" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      dataset.read_only_transaction do |tx|
        aggregate_query = query.aggregate_query
                               .add_count
        res = dataset.run_aggregation aggregate_query
        _(res.get).must_be_kind_of Integer
        _(res.get).must_equal 4
      end
    end
  end

  describe "COUNT via GQL" do
    it "returns count without alias" do
      gql = dataset.gql "SELECT COUNT(*) FROM Character WHERE __key__ HAS ANCESTOR @bookKey",
                        bookKey: book.key
      res = dataset.run_aggregation gql
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 4
    end

    it "returns count with single custom alias" do
      gql = dataset.gql "SELECT COUNT(*) AS total FROM Character WHERE __key__ HAS ANCESTOR @bookKey",
                        bookKey: book.key
      res = dataset.run_aggregation gql
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 4
      _(res.get('total')).must_be_kind_of Integer
      _(res.get('total')).must_equal 4
    end

    it "returns count with a filter" do
      gql = dataset.gql "SELECT COUNT(*) FROM Character WHERE __key__ HAS ANCESTOR @bookKey AND alive = @alive",
                        alive: false, bookKey: book.key
      res = dataset.run_aggregation gql
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 1
    end

    it "throws error when custom alias isn't specified for multiple aliases" do
      gql = dataset.gql "SELECT COUNT(*) AS total_1, COUNT(*) as total_2 FROM Character WHERE __key__ HAS ANCESTOR @bookKey",
                        bookKey: book.key
      res = dataset.run_aggregation gql
      expect { res.get }.must_raise ArgumentError
    end

    it "returns count inside a transaction" do
      dataset.read_only_transaction do |tx|
        gql = dataset.gql "SELECT COUNT(*) FROM Character WHERE __key__ HAS ANCESTOR @bookKey",
                          bookKey: book.key
        res = dataset.run_aggregation gql
        _(res.get).must_be_kind_of Integer
        _(res.get).must_equal 4
      end
    end
  end

  describe "SUM via AggregateQuery" do
    it "returns 0 for no records" do
      dataset.delete *characters # delete dataset before querying
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_sum('appearances')
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 0
    end

    it "returns sum for non-zero records" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_sum('appearances')
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 68
    end

    it "returns double sum for records with double values" do
      # delete integer dataset and save records with doubles
      dataset.delete *characters
      characters.each do |ch|
        ch["appearances"] = ch["appearances"].to_f
      end
      dataset.transaction { |tx| tx.save *characters }

      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_sum('appearances')
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Float
      _(res.get).must_equal 68.0
    end

    it "returns sum on filter" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
                .where("family", "=", "Martin")
      aggregate_query = query.aggregate_query
                            .add_sum('appearances')
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 1
    end

    it "returns sum on filter with and without read time" do
      read_time = Time.now
      sleep(1)
      dataset.transaction { |tx| tx.delete george }

      query = Google::Cloud::Datastore.new
                                      .query("Character")
                                      .ancestor(book)
                                      .where("family", "=", "Martin")
      aggregate_query = query.aggregate_query
                             .add_sum("appearances")

      res = dataset.run_aggregation aggregate_query, read_time: read_time
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 1
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 0
    end

    it "returns sum on limit" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
                .limit(2)
      aggregate_query = query.aggregate_query
                             .add_sum("appearances")
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 10
    end

    it "returns sum with a custom alias" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_sum("appearances", aggregate_alias: "total")
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 68
      _(res.get('total')).must_be_kind_of Integer
      _(res.get('total')).must_equal 68
    end

    it "returns sum with multiple custom aliases" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_sum("appearances", aggregate_alias: "total_1")
                             .add_sum("appearances", aggregate_alias: "total_2")
      res = dataset.run_aggregation aggregate_query
      _(res.get('total_1')).must_be_kind_of Integer
      _(res.get('total_1')).must_equal 68
      _(res.get('total_2')).must_be_kind_of Integer
      _(res.get('total_2')).must_equal 68
    end

    it "returns nil with unspecified aliases" do
      query = Google::Cloud::Datastore.new.
        query("Character").
        ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_sum("appearances")
      res = dataset.run_aggregation aggregate_query
      _(res.get('unspecified_alias')).must_be :nil?
    end

    it "throws error when duplicating aliases" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_sum("appearances", aggregate_alias: "total")
                             .add_sum("appearances", aggregate_alias: "total")
      expect { res = dataset.run_aggregation aggregate_query }.must_raise Google::Cloud::InvalidArgumentError
    end

    it "throws error when custom alias isn't specified for multiple aliases" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_sum("appearances", aggregate_alias: "total_1")
                             .add_sum("appearances", aggregate_alias: "total_2")
      res = dataset.run_aggregation aggregate_query
      expect { res.get }.must_raise ArgumentError
    end

    it "returns different sum when data changes" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_sum("appearances")
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 68
      dataset.delete bran.key
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 43
    end

    it "returns sum inside a transaction" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      dataset.read_only_transaction do |tx|
        aggregate_query = query.aggregate_query
                             .add_sum("appearances")
        res = dataset.run_aggregation aggregate_query
        _(res.get).must_be_kind_of Integer
        _(res.get).must_equal 68
      end
    end
  end

  describe "SUM via GQL" do
    it "returns sum without alias" do
      gql = dataset.gql "SELECT SUM(appearances) FROM Character WHERE __key__ HAS ANCESTOR @bookKey",
                        bookKey: book.key
      res = dataset.run_aggregation gql
        _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 68
    end

    it "returns sum with single custom alias" do
      gql = dataset.gql "SELECT SUM(appearances) AS total FROM Character WHERE __key__ HAS ANCESTOR @bookKey",
                        bookKey: book.key
      res = dataset.run_aggregation gql
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 68
      _(res.get('total')).must_be_kind_of Integer
      _(res.get('total')).must_equal 68
    end

    it "returns sum with a filter" do
      gql = dataset.gql "SELECT SUM(appearances) FROM Character WHERE __key__ HAS ANCESTOR @bookKey AND family = @family",
                        family: 'Martin', bookKey: book.key
      res = dataset.run_aggregation gql
      _(res.get).must_be_kind_of Integer
      _(res.get).must_equal 1
    end

    it "throws error when custom alias isn't specified for multiple aliases" do
      gql = dataset.gql "SELECT SUM(appearances) AS total_1, SUM(appearances) as total_2 FROM Character WHERE __key__ HAS ANCESTOR @bookKey",
                        bookKey: book.key
      res = dataset.run_aggregation gql
      expect { res.get }.must_raise ArgumentError
    end

    it "returns sum inside a transaction" do
      dataset.read_only_transaction do |tx|
        gql = dataset.gql "SELECT SUM(appearances) FROM Character WHERE __key__ HAS ANCESTOR @bookKey",
                          bookKey: book.key
        res = dataset.run_aggregation gql
        _(res.get).must_be_kind_of Integer
        _(res.get).must_equal 68
      end
    end
  end

  describe "AVG via AggregateQuery" do
    it "returns 0 for no records" do
      dataset.delete *characters # delete dataset before querying
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_avg('appearances')
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Float
      _(res.get).must_equal 0.0
    end

    it "returns average for non-zero records" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_avg('appearances')
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Float
      _(res.get).must_equal 17.0
    end

    it "returns average on filter" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
                .where("family", "=", "Martin")
      aggregate_query = query.aggregate_query
                            .add_avg('appearances')
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Float
      _(res.get).must_equal 1.0
    end

    it "returns average on filter with and without read time" do
      read_time = Time.now
      sleep(1)
      dataset.transaction { |tx| tx.delete george }

      query = Google::Cloud::Datastore.new
                                      .query("Character")
                                      .ancestor(book)
                                      .where("family", "=", "Martin")
      aggregate_query = query.aggregate_query
                             .add_avg("appearances")

      res = dataset.run_aggregation aggregate_query, read_time: read_time
      _(res.get).must_be_kind_of Float
      _(res.get).must_equal 1.0
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Float
      _(res.get).must_equal 0.0
    end

    it "returns average on limit" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
                .limit(2)
      aggregate_query = query.aggregate_query
                             .add_avg("appearances")
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Float
      _(res.get).must_equal 5.0
    end

    it "returns average with a custom alias" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_avg("appearances", aggregate_alias: "total")
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Float
      _(res.get).must_equal 17.0
      _(res.get('total')).must_be_kind_of Float
      _(res.get('total')).must_equal 17.0
    end

    it "returns average with multiple custom aliases" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_avg("appearances", aggregate_alias: "total_1")
                             .add_avg("appearances", aggregate_alias: "total_2")
      res = dataset.run_aggregation aggregate_query
      _(res.get('total_1')).must_be_kind_of Float
      _(res.get('total_1')).must_equal 17.0
      _(res.get('total_2')).must_be_kind_of Float
      _(res.get('total_2')).must_equal 17.0
    end

    it "returns nil with unspecified aliases" do
      query = Google::Cloud::Datastore.new.
        query("Character").
        ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_avg("appearances")
      res = dataset.run_aggregation aggregate_query
      _(res.get('unspecified_alias')).must_be :nil?
    end

    it "throws error when duplicating aliases" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_avg("appearances", aggregate_alias: "total")
                             .add_avg("appearances", aggregate_alias: "total")
      expect { res = dataset.run_aggregation aggregate_query }.must_raise Google::Cloud::InvalidArgumentError
    end

    it "throws error when custom alias isn't specified for multiple aliases" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_avg("appearances", aggregate_alias: "total_1")
                             .add_avg("appearances", aggregate_alias: "total_2")
      res = dataset.run_aggregation aggregate_query
      expect { res.get }.must_raise ArgumentError
    end

    it "returns different average when data changes" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      aggregate_query = query.aggregate_query
                             .add_avg("appearances")
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Float
      _(res.get).must_equal 17.0
      dataset.delete bran.key
      res = dataset.run_aggregation aggregate_query
      _(res.get).must_be_kind_of Float
      _(res.get.round(2)).must_equal 14.33
    end

    it "returns average inside a transaction" do
      query = Google::Cloud::Datastore.new
                .query("Character")
                .ancestor(book)
      dataset.read_only_transaction do |tx|
        aggregate_query = query.aggregate_query
                             .add_avg("appearances")
        res = dataset.run_aggregation aggregate_query
        _(res.get).must_be_kind_of Float
        _(res.get).must_equal 17.0
      end
    end
  end

  describe "AVG via GQL" do
    it "returns average without alias" do
      gql = dataset.gql "SELECT AVG(appearances) FROM Character WHERE __key__ HAS ANCESTOR @bookKey",
                        bookKey: book.key
      res = dataset.run_aggregation gql
      _(res.get).must_be_kind_of Float
      _(res.get).must_equal 17.0
    end

    it "returns average with single custom alias" do
      gql = dataset.gql "SELECT AVG(appearances) AS total FROM Character WHERE __key__ HAS ANCESTOR @bookKey",
                        bookKey: book.key
      res = dataset.run_aggregation gql
      _(res.get).must_be_kind_of Float
      _(res.get).must_equal 17.0
      _(res.get('total')).must_be_kind_of Float
      _(res.get('total')).must_equal 17.0
    end

    it "returns average with a filter" do
      gql = dataset.gql "SELECT AVG(appearances) FROM Character WHERE __key__ HAS ANCESTOR @bookKey AND family = @family",
                        family: 'Martin', bookKey: book.key
      res = dataset.run_aggregation gql
      _(res.get).must_be_kind_of Float
      _(res.get).must_equal 1.0
    end

    it "throws error when custom alias isn't specified for multiple aliases" do
      gql = dataset.gql "SELECT AVG(appearances) AS total_1, AVG(appearances) as total_2 FROM Character WHERE __key__ HAS ANCESTOR @bookKey",
                        bookKey: book.key
      res = dataset.run_aggregation gql
      expect { res.get }.must_raise ArgumentError
    end

    it "returns average inside a transaction" do
      dataset.read_only_transaction do |tx|
        gql = dataset.gql "SELECT AVG(appearances) FROM Character WHERE __key__ HAS ANCESTOR @bookKey",
                          bookKey: book.key
        res = dataset.run_aggregation gql
        _(res.get).must_be_kind_of Float
        _(res.get).must_equal 17.0
      end
    end
  end
end
