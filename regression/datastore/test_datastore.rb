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

require "datastore_helper"

# This test is a ruby version of gcloud-node's datastore test.

describe "Datastore", :datastore do

  it "should allocate IDs" do
    incomplete_key = Gcloud::Datastore::Key.new "Kind"
    incomplete_key.wont_be :complete?

    keys = connection.allocate_ids incomplete_key, 10

    keys.count.must_equal 10
    keys.each { |key| key.must_be :complete? }
  end

  describe "create, retrieve and delete" do

    let(:post) do
      Gcloud::Datastore::Entity.new.tap do |e|
        e["title"]       = "How to make the perfect pizza in your grill"
        e["tags"]        = ["pizza", "grill"]
        e["publishedAt"] = Time.new 2001, 1, 1
        e["author"]      = "Silvano"
        e["isDraft"]     = false
        e["wordCount"]   = 400
        e["rating"]      = 5.0
      end
    end

    let(:post2) do
      Gcloud::Datastore::Entity.new.tap do |e|
        e["title"]       = "How to make the perfect homemade pasta"
        e["tags"]        = ["pasta", "homemade"]
        e["publishedAt"] = Time.parse "2001-01-01T00:00:00.000Z"
        e["author"]      = "Silvano"
        e["isDraft"]     = false
        e["wordCount"]   = 450
        e["rating"]      = 4.5
      end
    end

    it "should save/find/delete with a key name" do
      post.key = Gcloud::Datastore::Key.new "Post", "post1"
      connection.save post

      refresh = connection.find post.key
      refresh.key.kind.must_equal post.key.kind
      refresh.key.id.must_equal   post.key.id
      refresh.key.name.must_equal post.key.name
      refresh.properties.must_equal post.properties

      connection.delete post
      refresh = connection.find post.key
      refresh.must_be :nil?
    end

    it "should save/find/delete with a numeric key id" do
      post.key = Gcloud::Datastore::Key.new "Post", 123456789
      connection.save post

      refresh = connection.find post.key
      refresh.key.kind.must_equal post.key.kind
      refresh.key.id.must_equal   post.key.id
      refresh.key.name.must_equal post.key.name
      refresh.properties.must_equal post.properties

      connection.delete post
      refresh = connection.find post.key
      refresh.must_be :nil?
    end

    it "should save/find/delete with a generated key id" do
      post.key = Gcloud::Datastore::Key.new "Post"

      post.key.id.must_be :nil?

      connection.save post

      post.key.id.wont_be :nil?

      refresh = connection.find "Post", post.key.id
      refresh.key.kind.must_equal post.key.kind
      refresh.key.id.must_equal   post.key.id
      refresh.key.name.must_equal post.key.name
      refresh.properties.must_equal post.properties

      connection.delete post
      refresh = connection.find post.key
      refresh.must_be :nil?
    end

    it "should save/find/delete multiple entities at once" do
      post.key  = Gcloud::Datastore::Key.new "Post"
      post2.key = Gcloud::Datastore::Key.new "Post"

      post.key.id.must_be :nil?
      post2.key.id.must_be :nil?

      connection.save post, post2

      post.key.id.wont_be :nil?
      post2.key.id.wont_be :nil?

      entities = connection.find_all post.key, post2.key
      entities.count.must_equal 2

      connection.delete post, post2

      entities = connection.find_all post.key, post2.key
      entities.count.must_equal 0
    end

  end

  it "should be able to save keys as a part of entity and query by key" do
    person = Gcloud::Datastore::Entity.new
    person.key = Gcloud::Datastore::Key.new "Person", "name"
    person["fullName"] = "Full name"
    person["linkedTo"] = person.key # itself
    connection.save person

    query = Gcloud::Datastore::Query.new.kind("Person").
      where("linkedTo", "=", person.key)

    entities = connection.run query
    entities.count.must_equal 1

    entity = entities.first
    entity["fullName"].must_equal      person["fullName"]
    entity["linkedTo"].kind.must_equal person["linkedTo"].kind
    entity["linkedTo"].id.must_equal   person["linkedTo"].id
    entity["linkedTo"].name.must_equal person["linkedTo"].name
  end

  describe "querying the datastore" do

    let(:book) do
      book = Gcloud::Datastore::Entity.new.tap do |e|
        e["title"] = "Game of Thrones"
      end
      book.key = Gcloud::Datastore::Key.new "Book", "GoT"
      book
    end

    let(:rickard) do
      character = Gcloud::Datastore::Entity.new.tap do |e|
        e["name"]        = "Rickard"
        e["family"]      = "Stark"
        e["appearances"] = 0
        e["alive"]       = false
      end
      character.key = Gcloud::Datastore::Key.new "Character", "Rickard"
      character.key.parent = book
      character
    end

    let(:eddard) do
      character = Gcloud::Datastore::Entity.new.tap do |e|
        e["name"]        = "Eddard"
        e["family"]      = "Stark"
        e["appearances"] = 9
        e["alive"]       = false
      end
      character.key = Gcloud::Datastore::Key.new "Character", "Eddard"
      character.key.parent = rickard
      character
    end

    let(:catelyn) do
      character = Gcloud::Datastore::Entity.new.tap do |e|
        e["name"]        = "Catelyn"
        e["family"]      = "Stark"
        e["appearances"] = 26
        e["alive"]       = false
      end
      character.key = Gcloud::Datastore::Key.new "Character", "Catelyn"
      character.key.parent = book
      character
    end

    let(:arya) do
      character = Gcloud::Datastore::Entity.new.tap do |e|
        e["name"]        = "Arya"
        e["family"]      = "Stark"
        e["appearances"] = 33
        e["alive"]       = true
      end
      character.key = Gcloud::Datastore::Key.new "Character", "Arya"
      character.key.parent = eddard
      character
    end

    let(:sansa) do
      character = Gcloud::Datastore::Entity.new.tap do |e|
        e["name"]        = "Sansa"
        e["family"]      = "Stark"
        e["appearances"] = 31
        e["alive"]       = true
      end
      character.key = Gcloud::Datastore::Key.new "Character", "Sansa"
      character.key.parent = eddard
      character
    end

    let(:robb) do
      character = Gcloud::Datastore::Entity.new.tap do |e|
        e["name"]        = "Robb"
        e["family"]      = "Stark"
        e["appearances"] = 22
        e["alive"]       = false
      end
      character.key = Gcloud::Datastore::Key.new "Character", "Robb"
      character.key.parent = eddard
      character
    end

    let(:bran) do
      character = Gcloud::Datastore::Entity.new.tap do |e|
        e["name"]        = "Bran"
        e["family"]      = "Stark"
        e["appearances"] = 25
        e["alive"]       = true
      end
      character.key = Gcloud::Datastore::Key.new "Character", "Bran"
      character.key.parent = eddard
      character
    end

    let(:jonsnow) do
      character = Gcloud::Datastore::Entity.new.tap do |e|
        e["name"]        = "Jon Snow"
        e["family"]      = "Stark"
        e["appearances"] = 32
        e["alive"]       = true
      end
      character.key = Gcloud::Datastore::Key.new "Character", "Jon Snow"
      character.key.parent = eddard
      character
    end

    let(:characters) do
      [rickard, eddard, catelyn, arya, sansa, robb, bran, jonsnow]
    end

    before do
      connection.save *characters
    end

    it "should limit queries" do
      # first page
      query = Gcloud::Datastore::Query.new.
        kind("Character").ancestor(book).limit(5)
      entities = connection.run query
      entities.count.must_equal 5

      # second page
      query.offset 5
      entities = connection.run query
      entities.count.must_equal 3

      # third page
      query.offset 10
      entities = connection.run query
      entities.count.must_equal 0
    end

    it "should filter queries with simple indexes" do
      query = Gcloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        where("appearances", ">=", 20)
      entities = connection.run query
      entities.count.must_equal 6
    end

    it "should filter queries with defined indexes" do
      query = Gcloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        where("family", "=", "Stark").
        where("appearances", ">=", 20)
      entities = connection.run query
      entities.count.must_equal 6
    end

    it "should filter by ancestor key" do
      query = Gcloud::Datastore::Query.new.
        kind("Character").ancestor(book.key)
      entities = connection.run query
      entities.count.must_equal 8
    end

    it "should filter by ancestor entity" do
      query = Gcloud::Datastore::Query.new.
        kind("Character").ancestor(book)
      entities = connection.run query
      entities.count.must_equal 8
    end

    it "should filter by key" do
      query = Gcloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        where("__key__", "=", rickard.key)
      entities = connection.run query
      entities.count.must_equal 1
    end

    it "should order queries" do
      query = Gcloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        order("appearances")
      entities = connection.run query
      entities.count.must_equal      characters.count
      entities[0]["name"].must_equal rickard["name"]
      entities[7]["name"].must_equal arya["name"]
    end

    it "should select projections" do
      query = Gcloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        select("name", "family")
      entities = connection.run query
      entities.each do |entity|
        entity.properties.count.must_equal 2
        entity.properties.assoc("name").wont_be :nil?
        entity.properties.assoc("family").wont_be :nil?
      end
    end

    it "should paginate with offset and limit" do
      query = Gcloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        limit(3).offset(2).order("appearances")
      entities = connection.run query
      entities.count.must_equal 3
      entities[0]["name"].must_equal robb["name"]
      entities[2]["name"].must_equal catelyn["name"]

      # next page
      query.offset(5)
      entities = connection.run query
      entities.count.must_equal 3
      entities[0]["name"].must_equal sansa["name"]
      entities[2]["name"].must_equal arya["name"]
    end

    it "should resume from a start cursor" do
      query = Gcloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        limit(3).order("appearances")
      entities = connection.run query
      entities.count.must_equal 3
      entities[0]["name"].must_equal rickard["name"]
      entities[2]["name"].must_equal robb["name"]

      next_cursor = entities.cursor
      next_cursor.wont_be :nil?
      next_query = Gcloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        limit(3).order("appearances").
        cursor(next_cursor)
      next_entities = connection.run next_query
      next_entities.count.must_equal 3
      next_entities[0]["name"].must_equal bran["name"]
      next_entities[2]["name"].must_equal sansa["name"]

      last_cursor = next_entities.cursor
      last_cursor.wont_be :nil?
      last_query = Gcloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        limit(3).order("appearances").
        cursor(last_cursor)
      last_entities = connection.run last_query
      last_entities.count.must_equal 2
      last_entities[0]["name"].must_equal jonsnow["name"]
      last_entities[1]["name"].must_equal arya["name"]
    end

    it "should group queries" do
      query = Gcloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        group_by("alive")
      entities = connection.run query
      entities.count.must_equal 2
    end

    after do
      connection.delete *characters
    end
  end

  describe "transactions" do

    it "should run in a transaction block" do
      obj = Gcloud::Datastore::Entity.new
      obj.key = Gcloud::Datastore::Key.new "Company", "Google"
      obj["url"] = "www.google.com"

      connection.transaction do |tx|
        tx.id.wont_be :nil?
        if tx.find(obj.key).nil?
          tx.save obj
        end
      end

      entity = connection.find obj.key
      entity.wont_be :nil?
      entity.key.kind.must_equal   obj.key.kind
      entity.key.id.must_equal     obj.key.id
      entity.key.name.must_equal   obj.key.name
      entity.properties.must_equal obj.properties
      connection.delete entity
    end

    it "should run in an explicit transaction" do
      obj = Gcloud::Datastore::Entity.new
      obj.key = Gcloud::Datastore::Key.new "Company", "Google"
      obj["url"] = "www.google.com"

      tx = connection.transaction
      tx.id.wont_be :nil?

      if tx.find(obj.key).nil?
        tx.save obj
      end
      # Don't handle errors and rollback, let test fail
      tx.commit

      entity = connection.find obj.key
      entity.wont_be :nil?
      entity.key.kind.must_equal   obj.key.kind
      entity.key.id.must_equal     obj.key.id
      entity.key.name.must_equal   obj.key.name
      entity.properties.must_equal obj.properties
      connection.delete entity
    end
  end
end
