# Copyright 2014 Google LLC
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
  let(:prefix) { "#{Time.now.utc.iso8601.gsub ":", "_"}_#{SecureRandom.hex(4)}" }

  it "should allocate IDs" do
    incomplete_key = Google::Cloud::Datastore::Key.new "Kind"
    incomplete_key.wont_be :complete?

    keys = dataset.allocate_ids incomplete_key, 10

    keys.count.must_equal 10
    keys.each { |key| key.must_be :complete? }
  end

  describe "create, retrieve and delete" do

    let(:post) do
      Google::Cloud::Datastore::Entity.new.tap do |e|
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
      Google::Cloud::Datastore::Entity.new.tap do |e|
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
      post.key = Google::Cloud::Datastore::Key.new "Post", "#{prefix}_post1"
      post.exclude_from_indexes! "author", true
      # Verify the index excludes are set properly
      post.exclude_from_indexes?("title").must_equal false
      post.exclude_from_indexes?("author").must_equal true

      dataset.save post

      refresh = dataset.find post.key
      refresh.key.kind.must_equal        post.key.kind
      refresh.key.id.must_be :nil?
      refresh.key.name.must_equal        post.key.name
      refresh.properties.to_h.must_equal post.properties.to_h
      # Verify the index excludes are retrieved properly
      refresh.exclude_from_indexes?("title").must_equal false
      refresh.exclude_from_indexes?("author").must_equal true

      dataset.delete post
      refresh = dataset.find post.key
      refresh.must_be :nil?
    end

    it "should save/find with a key name and delete with a key" do
      post.key = Google::Cloud::Datastore::Key.new "Post", "#{prefix}_post2"
      dataset.save post

      refresh = dataset.find post.key
      refresh.key.kind.must_equal        post.key.kind
      refresh.key.id.must_be :nil?
      refresh.key.name.must_equal        post.key.name
      refresh.properties.to_h.must_equal post.properties.to_h

      dataset.delete post.key
      refresh = dataset.find post.key
      refresh.must_be :nil?
    end

    it "should save/find/delete with a numeric key id" do
      post.key = Google::Cloud::Datastore::Key.new "Post", SecureRandom.hex(4).to_i(16)
      dataset.save post

      refresh = dataset.find post.key
      refresh.key.kind.must_equal        post.key.kind
      refresh.key.id.must_equal          post.key.id
      refresh.key.name.must_be :nil?
      refresh.properties.to_h.must_equal post.properties.to_h

      dataset.delete post
      refresh = dataset.find post.key
      refresh.must_be :nil?
    end

    it "should save/find/delete with a generated key id" do
      post.key = Google::Cloud::Datastore::Key.new "Post"

      post.key.id.must_be :nil?

      dataset.save post

      post.key.id.wont_be :nil?

      refresh = dataset.find "Post",     post.key.id
      refresh.key.kind.must_equal        post.key.kind
      refresh.key.id.must_equal          post.key.id
      refresh.key.name.must_be :nil?
      refresh.properties.to_h.must_equal post.properties.to_h

      dataset.delete post
      refresh = dataset.find post.key
      refresh.must_be :nil?
    end

    it "should save/find/delete multiple entities at once" do
      post.key  = Google::Cloud::Datastore::Key.new "Post"
      post2.key = Google::Cloud::Datastore::Key.new "Post"

      post.key.must_be :incomplete?
      post2.key.must_be :incomplete?

      dataset.save post, post2

      post.key.wont_be :incomplete?
      post2.key.wont_be :incomplete?

      entities = dataset.find_all post.key, post2.key
      entities.count.must_equal 2

      dataset.delete post, post2

      entities = dataset.find_all post.key, post2.key
      entities.count.must_equal 0
    end

    it "should save/find/delete multiple entities with commit" do
      post.key  = Google::Cloud::Datastore::Key.new "Post"
      post2.key = Google::Cloud::Datastore::Key.new "Post"

      post.key.must_be :incomplete?
      post2.key.must_be :incomplete?

      dataset.save post

      post.key.must_be :complete?
      post2.key.must_be :incomplete?

      dataset.commit do |c|
        c.delete post
        c.save post2
      end

      post.key.must_be :complete?
      post2.key.must_be :complete?

      dataset.delete post2

      entities = dataset.find_all post.key, post2.key
      entities.count.must_equal 0
    end

    it "entities retrieved from datastore have immutable keys" do
      post.key = Google::Cloud::Datastore::Key.new "Post", "#{prefix}_post3"
      dataset.save post

      refresh = dataset.find post.key
      refresh.must_be :persisted?
      refresh.key.must_be :frozen?

      assert_raises RuntimeError do
        refresh.key = Google::Cloud::Datastore::Key.new "User", 456789
      end

      assert_raises RuntimeError do
        refresh.key.id = 456789
      end

      dataset.delete post
    end

    it "should save and read blob values" do
      avatar = File.open("acceptance/data/CloudPlatform_128px_Retina.png", mode: "rb")
      post.key  = Google::Cloud::Datastore::Key.new "Post", "#{prefix}_blob_support"
      post["avatar"] = avatar
      post.exclude_from_indexes! "avatar", true

      dataset.save post

      entity = dataset.find post.key

      # Rewind not needed because the StringIO poistion is always at the beginning whe retrieved from Datastore.
      # entity["avatar"].rewind
      post["avatar"].rewind
      entity["avatar"].size.must_equal post["avatar"].size
      entity["avatar"].read.must_equal post["avatar"].read

      Tempfile.open ["avatar", "png"] do |tmpfile|
        tmpfile.binmode
        entity["avatar"].rewind
        tmpfile.write entity["avatar"].read

        tmpfile.rewind
        avatar.rewind
        tmpfile.size.must_equal avatar.size
        tmpfile.read.must_equal avatar.read
      end

      dataset.delete post
    end

    it "should find with specifying consistency" do
      post.key = Google::Cloud::Datastore::Key.new "Post", "#{prefix}_post4"
      dataset.save post

      # sleep for one second to aid in the eventual consistency
      sleep 1

      refresh = dataset.find post.key, consistency: :eventual
      refresh.wont_be :nil?
      refresh.key.kind.must_equal        post.key.kind
      refresh.key.id.must_be :nil?
      refresh.key.name.must_equal        post.key.name
      refresh.properties.to_h.must_equal post.properties.to_h

      dataset.delete post.key
      refresh = dataset.find post.key
      refresh.must_be :nil?
    end

    it "allows embedded entities and keys" do
      post.key = Google::Cloud::Datastore::Key.new "Post", "#{prefix}_post_embedded"
      post["embedded_entity"] = dataset.entity "EmbeddedPost", "key_will_not_be_pesisted"
      post["embedded_entity"]["embedded_name"] = "hello!"
      post["embedded_key"] = dataset.entity "EmbeddedKey", "#{prefix}_will_be_pesisted"

      post["embedded_entity"].wont_be :nil?
      post["embedded_entity"].key.wont_be :nil?
      post["embedded_entity"]["embedded_name"].must_equal "hello!"
      post["embedded_key"].wont_be :nil?

      dataset.save post

      refresh = dataset.find post.key

      refresh["embedded_entity"].wont_be :nil?
      refresh["embedded_entity"].key.must_be :nil?
      refresh["embedded_entity"]["embedded_name"].must_equal "hello!"
      refresh["embedded_entity"].to_grpc.properties.must_equal post["embedded_entity"].to_grpc.properties
      refresh["embedded_key"].wont_be :nil?
      refresh["embedded_key"].to_grpc.must_equal post["embedded_key"].to_grpc

      dataset.delete post
    end
  end

  it "should be able to save keys as a part of entity and query by key" do
    person = Google::Cloud::Datastore::Entity.new
    person.key = Google::Cloud::Datastore::Key.new "Person", "#{prefix}_name"
    person["fullName"] = "Full name"
    person["linkedTo"] = person.key # itself
    dataset.save person

    query = Google::Cloud::Datastore::Query.new.kind("Person").
      where("linkedTo", "=", person.key)

    try_with_backoff "query by key" do
      entities = dataset.run query
      fail "retry query by key" unless entities.count == 1
      entities.count.must_equal 1

      entity = entities.first
      entity["fullName"].must_equal      person["fullName"]
      entity["linkedTo"].kind.must_equal person["linkedTo"].kind
      entity["linkedTo"].id.must_be :nil?
      entity["linkedTo"].name.must_equal person["linkedTo"].name
    end
  end

  describe "querying the datastore" do

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

    let(:jonsnow) do
      character = Google::Cloud::Datastore::Entity.new.tap do |e|
        e["name"]        = "Jon Snow"
        e["family"]      = "Stark"
        e["appearances"] = 32
        e["alive"]       = true
      end
      character.key = Google::Cloud::Datastore::Key.new "Character", "Jon Snow"
      character.key.parent = eddard
      character
    end

    let(:characters) do
      [rickard, eddard, catelyn, arya, sansa, robb, bran, jonsnow]
    end

    before do
      dataset.transaction { |tx| tx.save *characters }
    end

    it "should limit queries" do
      # first page
      query = Google::Cloud::Datastore::Query.new.
        kind("Character").ancestor(book).limit(5)
      entities = dataset.run query
      entities.count.must_equal 5

      # second page
      query.offset 5
      entities = dataset.run query
      entities.count.must_equal 3

      # third page
      query.offset 10
      entities = dataset.run query
      entities.count.must_equal 0
    end

    it "should filter queries with simple indexes" do
      query = Google::Cloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        where("appearances", ">=", 20)
      entities = dataset.run query
      entities.count.must_equal 6
    end

    it "should filter queries with defined indexes" do
      query = Google::Cloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        where("family", "=", "Stark").
        where("appearances", ">=", 20)
      entities = dataset.run query
      entities.count.must_equal 6
    end

    it "should filter by ancestor key" do
      query = Google::Cloud::Datastore::Query.new.
        kind("Character").ancestor(book.key)
      entities = dataset.run query
      entities.count.must_equal 8
    end

    it "should filter by ancestor entity" do
      query = Google::Cloud::Datastore::Query.new.
        kind("Character").ancestor(book)
      entities = dataset.run query
      entities.count.must_equal 8
    end

    it "should filter by key" do
      query = Google::Cloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        where("__key__", "=", rickard.key)
      entities = dataset.run query
      entities.count.must_equal 1
    end

    it "should order queries" do
      query = Google::Cloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        order("appearances")
      entities = dataset.run query
      entities.count.must_equal      characters.count
      entities[0]["name"].must_equal rickard["name"]
      entities[7]["name"].must_equal arya["name"]
    end

    it "should select projections" do
      query = Google::Cloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        select("name", "family")
      entities = dataset.run query
      entities.each do |entity|
        entity.properties.to_h.keys.count.must_equal 2
        entity.properties["name"].wont_be :nil?
        entity.properties["family"].wont_be :nil?
      end
    end

    it "should paginate with offset and limit" do
      query = Google::Cloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        limit(3).offset(2).order("appearances")
      entities = dataset.run query
      entities.count.must_equal 3
      entities[0]["name"].must_equal robb["name"]
      entities[2]["name"].must_equal catelyn["name"]

      # next page
      query.offset(5)
      entities = dataset.run query
      entities.count.must_equal 3
      entities[0]["name"].must_equal sansa["name"]
      entities[2]["name"].must_equal arya["name"]
    end

    it "should paginate with all" do
      query = Google::Cloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        order("appearances")
      entities = dataset.run(query).all.to_a
      entities.count.must_equal 8
      entities[0]["name"].must_equal rickard["name"]
      entities[5]["name"].must_equal sansa["name"]
    end

    it "should resume from a start cursor" do
      query = Google::Cloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        limit(3).order("appearances")
      entities = dataset.run query
      entities.count.must_equal 3
      entities[0]["name"].must_equal rickard["name"]
      entities[2]["name"].must_equal robb["name"]

      next_cursor = entities.cursor
      next_cursor.wont_be :nil?
      next_query = Google::Cloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        limit(3).order("appearances").
        cursor(next_cursor)
      next_entities = dataset.run next_query
      next_entities.count.must_equal 3
      next_entities[0]["name"].must_equal bran["name"]
      next_entities[2]["name"].must_equal sansa["name"]

      last_cursor = next_entities.cursor
      last_cursor.wont_be :nil?
      last_query = Google::Cloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        limit(3).order("appearances").
        cursor(last_cursor)
      last_entities = dataset.run last_query
      last_entities.count.must_equal 2
      last_entities[0]["name"].must_equal jonsnow["name"]
      last_entities[1]["name"].must_equal arya["name"]
    end

    it "should group queries" do
      query = Google::Cloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        group_by("alive")
      entities = dataset.run query
      entities.count.must_equal 2
    end

    it "should filter queries with simple indexes using GQL and named bindings" do
      gql = dataset.gql "SELECT * FROM Character WHERE __key__ HAS ANCESTOR @bookKey AND appearances >= @appearanceCount",
                        bookKey: book.key, appearanceCount: 20
      entities = dataset.run gql
      entities.count.must_equal 6
    end

    it "should filter queries with simple indexes using GQL and positional bindings" do
      gql = dataset.gql "SELECT * FROM Character WHERE __key__ HAS ANCESTOR @1 AND appearances >= @2"
      gql.positional_bindings = [book.key, 20]
      entities = dataset.run gql
      entities.count.must_equal 6
    end

    it "should filter queries with defined indexes using GQL and named bindings" do
      gql = dataset.gql "SELECT * FROM Character WHERE __key__ HAS ANCESTOR @bookKey AND family = @familyName AND appearances >= @appearanceCount",
                        bookKey: book.key, familyName: "Stark", appearanceCount: 20
      entities = dataset.run gql
      entities.count.must_equal 6
    end

    it "should filter queries with defined indexes using GQL and positional bindings" do
      gql = dataset.gql "SELECT * FROM Character WHERE __key__ HAS ANCESTOR @1 AND family = @2 AND appearances >= @3"
      gql.positional_bindings = [book.key, "Stark", 20]
      entities = dataset.run gql
      entities.count.must_equal 6
    end

    it "should filter queries with defined indexes using GQL and literal values" do
      gql = dataset.gql "SELECT * FROM Character WHERE __key__ HAS ANCESTOR Key(Book, '#{prefix}_GoT') AND family = 'Stark' AND appearances >= 20"
      gql.allow_literals = true
      entities = dataset.run gql
      entities.count.must_equal 6
    end

    it "should specify consistency" do
      query = Google::Cloud::Datastore::Query.new.
        kind("Character").ancestor(book).
        where("family", "=", "Stark").
        where("appearances", ">=", 20)
      entities = dataset.run query, consistency: :strong
      entities.count.must_equal 6
    end

    it "should find and run query in a read-only transaction" do
      query = dataset.query("Character").
        ancestor(book.key)
      entities = nil

      tx = dataset.read_only_transaction do |tx|
        fresh = tx.find book.key
        entities = tx.run query
      end
      entities.count.must_equal 8
    end

    after do
      dataset.delete *characters
    end
  end

  describe "transactions" do

    it "should run in a transaction block" do
      obj = Google::Cloud::Datastore::Entity.new
      obj.key = Google::Cloud::Datastore::Key.new "Company", "#{prefix}_Google1"
      obj["url"] = "www.google.com"

      dataset.transaction do |t|
        entity = t.find obj.key
        if entity.nil?
          t.save obj
        end
      end

      entity = dataset.find obj.key
      entity.wont_be :nil?
      entity.key.kind.must_equal        obj.key.kind
      entity.key.id.must_be :nil?
      entity.key.name.must_equal        obj.key.name
      entity.properties.to_h.must_equal obj.properties.to_h
      dataset.delete entity
    end

    it "should run in an explicit transaction" do
      obj = Google::Cloud::Datastore::Entity.new
      obj.key = Google::Cloud::Datastore::Key.new "Company", "#{prefix}_Google2"
      obj["url"] = "www.google.com"

      tx = dataset.transaction
      tx.id.wont_be :nil?

      if tx.find(obj.key).nil?
        tx.save obj
      end
      # Don't handle errors and rollback, let test fail
      tx.commit

      entity = dataset.find obj.key
      entity.wont_be :nil?
      entity.key.kind.must_equal        obj.key.kind
      entity.key.id.must_be :nil?
      entity.key.name.must_equal        obj.key.name
      entity.properties.to_h.must_equal obj.properties.to_h
      dataset.delete entity
    end

    it "should manually retry a transaction with previous_transaction" do
      obj = Google::Cloud::Datastore::Entity.new
      obj.key = Google::Cloud::Datastore::Key.new "Company", "#{prefix}_Google3"
      obj["url"] = "www.google.com"
      dataset.save obj

      tx = dataset.transaction
      tx.id.wont_be :nil?

      obj2 = tx.find obj.key

      obj["url"] = "1.google.com"
      dataset.update obj

      obj2["url"] = "2.google.com"
      tx.update obj2

      retried = false
      begin
        tx.commit
      rescue Google::Cloud::AbortedError
        retried = true
        tx2 = dataset.transaction previous_transaction: tx.id
        tx2.update obj2
        tx2.commit
      end

      retried.must_equal true
      entity = dataset.find obj.key
      entity.wont_be :nil?
      entity["url"].must_equal "2.google.com"
      dataset.delete entity
    end

    it "should find within the transaction" do
      dataset.save dataset.entity("Post", "#{prefix}_post5")

      tx = dataset.transaction do |tx|
        in_tx_refresh = tx.find dataset.key("Post", "#{prefix}_post5")
        tx.delete in_tx_refresh if in_tx_refresh
      end

      refresh = dataset.find "Post", "#{prefix}_post5"
      refresh.must_be :nil?
    end
  end
end
