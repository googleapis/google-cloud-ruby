# Copyright 2020 Google, Inc
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

require "google/cloud/firestore"

def order_by_name_limit_query project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id

  cities_ref = firestore.col collection_path
  # [START fs_order_by_name_limit_query]
  query = cities_ref.order("name").limit(3)
  # [END fs_order_by_name_limit_query]
  query.get do |city|
    puts "Document #{city.document_id} returned by order by name with limit query."
  end
end

def order_by_name_desc_limit_query project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id

  cities_ref = firestore.col collection_path
  # [START fs_order_by_name_desc_limit_query]
  query = cities_ref.order("name", "desc").limit(3)
  # [END fs_order_by_name_desc_limit_query]
  query.get do |city|
    puts "Document #{city.document_id} returned by order by name descending with limit query."
  end
end

def order_by_state_and_population_query project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id

  cities_ref = firestore.col collection_path
  # [START fs_order_by_state_and_population_query]
  query = cities_ref.order("state").order("population", "desc")
  # [END fs_order_by_state_and_population_query]
  query.get do |city|
    puts "Document #{city.document_id} returned by order by state and descending population query."
  end
end

def where_order_by_limit_query project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id

  cities_ref = firestore.col collection_path
  # [START fs_where_order_by_limit_query]
  query = cities_ref.where("population", ">", 2_500_000).order("population").limit(2)
  # [END fs_where_order_by_limit_query]
  query.get do |city|
    puts "Document #{city.document_id} returned by where order by limit query."
  end
end

def range_order_by_query project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id

  cities_ref = firestore.col collection_path
  # [START fs_range_order_by_query]
  query = cities_ref.where("population", ">", 2_500_000).order("population")
  # [END fs_range_order_by_query]
  query.get do |city|
    puts "Document #{city.document_id} returned by range with order by query."
  end
end

def invalid_range_order_by_query project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id

  cities_ref = firestore.col collection_path
  # [START fs_invalid_range_order_by_query]
  query = cities_ref.where("population", ">", 2_500_000).order("country")
  # [END fs_invalid_range_order_by_query]
end

def order_by_name_limit_to_last_query project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id

  cities_ref = firestore.col collection_path
  # [START fs_order_by_name_limit_to_last_query]
  query = cities_ref.order("name").limit_to_last(3)
  # [END fs_order_by_name_limit_to_last_query]
  query.get do |city|
    puts "Document #{city.document_id} returned by order by name with limit_to_last query."
  end
end

if $PROGRAM_NAME == __FILE__
  project = ENV["FIRESTORE_PROJECT"]
  case ARGV.shift
  when "order_by_name_limit_query"
    order_by_name_limit_query project_id: project
  when "order_by_name_desc_limit_query"
    order_by_name_desc_limit_query project_id: project
  when "order_by_state_and_population_query"
    order_by_state_and_population_query project_id: project
  when "where_order_by_limit_query"
    where_order_by_limit_query project_id: project
  when "range_order_by_query"
    range_order_by_query project_id: project
  when "invalid_range_order_by_query"
    invalid_range_order_by_query project_id: project
  when "order_by_name_limit_to_last_query"
    order_by_name_limit_to_last_query project_id: project
  else
    puts <<~USAGE
      Usage: bundle exec ruby order_limit_data.rb [command]

      Commands:
        order_by_name_limit_query            Create an order by name with limit query.
        order_by_name_desc_limit_query       Create an order by name descending with limit query.
        order_by_state_and_population_query  Create an order by state and descending population query.
        where_order_by_limit_query           Combine where with order by and limit in a query.
        range_order_by_query                 Create a range with order by query.
        invalid_range_order_by_query         An example of an invalid range with order by query.
        order_by_name_limit_to_last_query    Create an order by name with limit_to_last query.
    USAGE
  end
end
