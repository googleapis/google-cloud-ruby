# Copyright 2015 Google Inc. All rights reserved.
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

describe Gcloud::Bigquery::Dataset, :access, :mock_bigquery do
  # Create a dataset object with the project's mocked connection object
  let(:dataset_id) { "my_dataset" }
  let(:dataset_hash) { random_dataset_hash dataset_id }
  let(:dataset) { Gcloud::Bigquery::Dataset.from_gapi dataset_hash,
                                                      bigquery.connection }

  it "gets the access rules" do
    dataset.access.must_be :empty?
  end

  it "sets the access rules" do
    mock_connection.patch "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}" do |env|
      json = JSON.parse env.body
      access = json["access"]
      access.wont_be :nil?
      access.must_be_kind_of Array
      access.wont_be :empty?
      access.count.must_equal 1
      rule = access.first
      rule.wont_be :nil?
      rule.must_be_kind_of Hash
      rule["role"].must_equal "WRITER"
      rule["userByEmail"].must_equal "writers@example.com"

      ret_dataset = random_dataset_hash(dataset_id)
      ret_dataset["access"] = access
      [200, {"Content-Type"=>"application/json"},
       ret_dataset.to_json]
    end

    dataset.access = [{"role"=>"WRITER", "userByEmail"=>"writers@example.com"}]
  end

  it "adds an access entry with specifying user scope" do
    mock_connection.patch "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}" do |env|
      json = JSON.parse env.body
      access = json["access"]
      access.wont_be :nil?
      access.must_be_kind_of Array
      access.wont_be :empty?
      access.count.must_equal 1
      rule = access.first
      rule.wont_be :nil?
      rule.must_be_kind_of Hash
      rule["role"].must_equal "WRITER"
      rule["userByEmail"].must_equal "writers@example.com"

      ret_dataset = random_dataset_hash(dataset_id)
      ret_dataset["access"] = access
      [200, {"Content-Type"=>"application/json"},
       ret_dataset.to_json]
    end

    dataset.access do |acl|
      refute acl.writer_user? "writers@example.com"
      acl.add_writer_user "writers@example.com"
      assert acl.writer_user? "writers@example.com"
    end
  end

  it "adds an access entry with specifying group scope" do
    mock_connection.patch "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}" do |env|
      json = JSON.parse env.body
      access = json["access"]
      access.wont_be :nil?
      access.must_be_kind_of Array
      access.wont_be :empty?
      access.count.must_equal 1
      rule = access.first
      rule.wont_be :nil?
      rule.must_be_kind_of Hash
      rule["role"].must_equal "WRITER"
      rule["groupByEmail"].must_equal "writers@example.com"

      ret_dataset = random_dataset_hash(dataset_id)
      ret_dataset["access"] = access
      [200, {"Content-Type"=>"application/json"},
       ret_dataset.to_json]
    end

    dataset.access do |acl|
      refute acl.writer_group? "writers@example.com"
      acl.add_writer_group "writers@example.com"
      assert acl.writer_group? "writers@example.com"
    end
  end

  it "adds an access entry with specifying domain scope" do
    mock_connection.patch "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}" do |env|
      json = JSON.parse env.body
      access = json["access"]
      access.wont_be :nil?
      access.must_be_kind_of Array
      access.wont_be :empty?
      access.count.must_equal 1
      rule = access.first
      rule.wont_be :nil?
      rule.must_be_kind_of Hash
      rule["role"].must_equal "OWNER"
      rule["domain"].must_equal "example.com"

      ret_dataset = random_dataset_hash(dataset_id)
      ret_dataset["access"] = access
      [200, {"Content-Type"=>"application/json"},
       ret_dataset.to_json]
    end

    dataset.access do |acl|
      refute acl.owner_domain? "example.com"
      acl.add_owner_domain "example.com"
      assert acl.owner_domain? "example.com"
    end
  end

  it "adds an access entry with specifying special scope" do
    mock_connection.patch "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}" do |env|
      json = JSON.parse env.body
      access = json["access"]
      access.wont_be :nil?
      access.must_be_kind_of Array
      access.wont_be :empty?
      access.count.must_equal 1
      rule = access.first
      rule.wont_be :nil?
      rule.must_be_kind_of Hash
      rule["role"].must_equal "READER"
      rule["specialGroup"].must_equal "allAuthenticatedUsers"

      ret_dataset = random_dataset_hash(dataset_id)
      ret_dataset["access"] = access
      [200, {"Content-Type"=>"application/json"},
       ret_dataset.to_json]
    end

    dataset.access do |acl|
      refute acl.reader_special? :all
      acl.add_reader_special :all
      assert acl.reader_special? :all
    end
  end

  it "updates multiple access entries in the block" do
    mock_connection.patch "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}" do |env|
      json = JSON.parse env.body
      access = json["access"]
      access.wont_be :nil?
      access.must_be_kind_of Array
      access.wont_be :empty?
      access.count.must_equal 2
      rule1 = access.first
      rule1.wont_be :nil?
      rule1.must_be_kind_of Hash
      rule1["role"].must_equal "WRITER"
      rule1["userByEmail"].must_equal "writer@example.com"
      rule2 = access.last
      rule2.wont_be :nil?
      rule2.must_be_kind_of Hash
      rule2["role"].must_equal "READER"
      rule2["groupByEmail"].must_equal "readers@example.com"

      ret_dataset = random_dataset_hash(dataset_id)
      ret_dataset["access"] = access
      [200, {"Content-Type"=>"application/json"},
       ret_dataset.to_json]
    end

    dataset.access do |acl|
      refute acl.writer_user? "writer@example.com"
      refute acl.reader_group? "readers@example.com"
      acl.add_writer_user "writer@example.com"
      acl.add_reader_group "readers@example.com"
      assert acl.writer_user? "writer@example.com"
      assert acl.reader_group? "readers@example.com"
    end
  end

  it "does not make an API call when no updates are made" do
    dataset.access do |acl|
      # No changes, no API calls made
    end
  end

  describe :remove do
    let(:dataset_hash) do
      hash = random_dataset_hash dataset_id
      hash["access"] = [
        { "role" => "WRITER",
          "userByEmail" => "writer@example.com"},
        { "role" => "READER",
          "userByEmail" => "reader@example.com"},
      ]
      hash
    end

    it "removes an access entry" do
      mock_connection.patch "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}" do |env|
        json = JSON.parse env.body
        access = json["access"]
        access.wont_be :nil?
        access.must_be_kind_of Array
        access.wont_be :empty?
        access.count.must_equal 1
        rule = access.first
        rule.wont_be :nil?
        rule.must_be_kind_of Hash
        rule["role"].must_equal "WRITER"
        rule["userByEmail"].must_equal "writer@example.com"

        ret_dataset = random_dataset_hash(dataset_id)
        ret_dataset["access"] = access
        [200, {"Content-Type"=>"application/json"},
         ret_dataset.to_json]
      end

      dataset.access do |acl|
        assert acl.writer_user? "writer@example.com"
        assert acl.reader_user? "reader@example.com"
        acl.remove_reader_user "reader@example.com"
        assert acl.writer_user? "writer@example.com"
        refute acl.reader_user? "reader@example.com"
      end
    end
  end
end
