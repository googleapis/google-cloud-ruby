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

def query_create_examples project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START firestore_query_filter_dataset]
  cities_ref = firestore.col collection_path
  cities_ref.doc("SF").set(
    {
      name:       "San Francisco",
      state:      "CA",
      country:    "USA",
      capital:    false,
      density:    18_000,
      population: 860_000,
      regions:    ["west_coast", "norcal"]
    }
  )
  cities_ref.doc("LA").set(
    {
      name:       "Los Angeles",
      state:      "CA",
      country:    "USA",
      capital:    false,
      density:    8_300,
      population: 3_900_000,
      regions:    ["west_coast", "socal"]
    }
  )
  cities_ref.doc("DC").set(
    {
      name:       "Washington D.C.",
      state:      nil,
      country:    "USA",
      capital:    true,
      density:    11_300,
      population: 680_000,
      regions:    ["east_coast"]
    }
  )
  cities_ref.doc("TOK").set(
    {
      name:       "Tokyo",
      state:      nil,
      country:    "Japan",
      capital:    true,
      density:    16_000,
      population: 9_000_000,
      regions:    ["kanto", "honshu"]
    }
  )
  cities_ref.doc("BJ").set(
    {
      name:       "Beijing",
      state:      nil,
      country:    "China",
      capital:    true,
      density:    3_500,
      population: 21_500_000,
      regions:    ["jingjinji", "hebei"]
    }
  )
  # [END firestore_query_filter_dataset]
  puts "Added example cities data to the cities collection."
end

def create_query_state project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START firestore_query_filter_eq_string]
  cities_ref = firestore.col collection_path

  query = cities_ref.where "state", "=", "CA"

  query.get do |city|
    puts "Document #{city.document_id} returned by query state=CA."
  end
  # [END firestore_query_filter_eq_string]
end

def create_query_capital project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START firestore_query_filter_eq_boolean]
  cities_ref = firestore.col collection_path

  query = cities_ref.where "capital", "=", true

  query.get do |city|
    puts "Document #{city.document_id} returned by query capital=true."
  end
  # [END firestore_query_filter_eq_boolean]
end

def simple_queries project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore  = Google::Cloud::Firestore.new project_id: project_id
  cities_ref = firestore.col collection_path

  # [START firestore_query_filter_single_examples]
  state_query      = cities_ref.where "state", "=", "CA"
  population_query = cities_ref.where "population", ">", 1_000_000
  name_query       = cities_ref.where "name", ">=", "San Francisco"
  # [END firestore_query_filter_single_examples]
  state_query.get do |city|
    puts "Document #{city.document_id} returned by query state=CA."
  end
  population_query.get do |city|
    puts "Document #{city.document_id} returned by query population>1000000."
  end
  name_query.get do |city|
    puts "Document #{city.document_id} returned by query name>=San Francisco."
  end
end

def chained_query project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore  = Google::Cloud::Firestore.new project_id: project_id
  cities_ref = firestore.col collection_path
  # [START firestore_query_filter_compound_multi_eq]
  chained_query = cities_ref.where("state", "=", "CA").where("name", "=", "San Francisco")
  # [END firestore_query_filter_compound_multi_eq]
  chained_query.get do |city|
    puts "Document #{city.document_id} returned by query state=CA and name=San Francisco."
  end
end

def composite_index_chained_query project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore  = Google::Cloud::Firestore.new project_id: project_id
  cities_ref = firestore.col collection_path
  # [START firestore_query_filter_compound_multi_eq_lt]
  chained_query = cities_ref.where("state", "=", "CA").where("population", "<", 1_000_000)
  # [END firestore_query_filter_compound_multi_eq_lt]
  chained_query.get do |city|
    puts "Document #{city.document_id} returned by query state=CA and population<1000000."
  end
end

def range_query project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore  = Google::Cloud::Firestore.new project_id: project_id
  cities_ref = firestore.col collection_path
  # [START firestore_query_filter_range_valid]
  range_query = cities_ref.where("state", ">=", "CA").where("state", "<=", "IN")
  # [END firestore_query_filter_range_valid]
  range_query.get do |city|
    puts "Document #{city.document_id} returned by query CA<=state<=IN."
  end
end

def invalid_range_query project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore  = Google::Cloud::Firestore.new project_id: project_id
  cities_ref = firestore.col collection_path
  # [START firestore_query_filter_range_invalid]
  invalid_range_query = cities_ref.where("state", ">=", "CA").where("population", ">", 1_000_000)
  # [END firestore_query_filter_range_invalid]
end

def query_filter_compound_multi_ineq project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore  = Google::Cloud::Firestore.new project_id: project_id
  # [START firestore_query_filter_compound_multi_ineq]
  cities_ref = firestore.col collection_path
  compound_multi_ineq_query = cities_ref.where("population", ">", 1_000_000).where("density", "<", 5_000)
  # [END firestore_query_filter_compound_multi_ineq]
  compound_multi_ineq_query.get do |city|
    puts "Document #{city.document_id} returned by query population>1_000_000 AND density<5_000"
  end
end

def in_query_without_array project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START firestore_query_filter_in]
  cities_ref = firestore.col collection_path
  usr_or_japan = cities_ref.where "country", "in", ["USA", "Japan"]
  # [END firestore_query_filter_in]
  usr_or_japan.get do |city|
    puts "Document #{city.document_id} returned by query in ['USA','Japan']."
  end
end

def in_query_with_array project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START firestore_query_filter_in_with_array]
  cities_ref = firestore.col collection_path
  exactly_one_cost = cities_ref.where "regions", "in", [["west_coast"], ["east_coast"]]
  # [END firestore_query_filter_in_with_array]
  exactly_one_cost.get do |city|
    puts "Document #{city.document_id} returned by query in [['west_coast'], ['east_coast']]."
  end
end

def query_not_equals project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START firestore_query_filter_not_eq]
  cities_ref = firestore.col collection_path
  query = cities_ref.where "capital", "!=", false
  # [END firestore_query_filter_not_eq]
  query.get do |city|
    puts "Document #{city.document_id} returned by query capital!=false."
  end
end

def filter_not_in project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START firestore_query_filter_not_in]
  cities_ref = firestore.col collection_path
  usr_or_japan = cities_ref.where "country", "not_in", ["USA", "Japan"]
  # [END firestore_query_filter_not_in]
  usr_or_japan.get do |city|
    puts "Document #{city.document_id} returned by query not_in ['USA','Japan']."
  end
end

def array_contains_any_queries project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START firestore_query_filter_array_contains_any]
  cities_ref = firestore.col collection_path
  costal_cities = cities_ref.where "regions", "array-contains-any", ["west_coast", "east_coast"]
  # [END firestore_query_filter_array_contains_any]
  costal_cities.get do |city|
    puts "Document #{city.document_id} returned by query array-contains-any ['west_coast', 'east_coast']."
  end
end

def array_contains_filter project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START firestore_query_filter_array_contains]
  cities_ref = firestore.col collection_path
  cities = cities_ref.where "regions", "array-contains", "west_coast"
  # [END firestore_query_filter_array_contains]
  cities.get do |city|
    puts "Document #{city.document_id} returned by query array-contains 'west_coast'."
  end
end

def collection_group_query project_id:, collection_path: "cities"
  # project_id = "Your Google Cloud Project ID"
  # collection_path = "cities"

  firestore = Google::Cloud::Firestore.new project_id: project_id
  # [START firestore_query_collection_group_dataset]
  cities_ref = firestore.col collection_path

  sf_landmarks = cities_ref.document("SF").collection("landmarks")
  sf_landmarks.document.set(
    {
      name: "Golden Gate Bridge",
      type: "bridge"
    }
  )
  sf_landmarks.document.set(
    {
      name: "Legion of Honor",
      type: "museum"
    }
  )

  la_landmarks = cities_ref.document("LA").collection("landmarks")
  la_landmarks.document.set(
    {
      name: "Griffith Park",
      type: "park"
    }
  )
  la_landmarks.document.set(
    {
      name: "The Getty",
      type: "museum"
    }
  )

  dc_landmarks = cities_ref.document("DC").collection("landmarks")
  dc_landmarks.document.set(
    {
      name: "Lincoln Memorial",
      type: "memorial"
    }
  )
  dc_landmarks.document.set(
    {
      name: "National Air and Space Museum",
      type: "museum"
    }
  )

  tok_landmarks = cities_ref.document("TOK").collection("landmarks")
  tok_landmarks.document.set(
    {
      name: "Ueno Park",
      type: "park"
    }
  )
  tok_landmarks.document.set(
    {
      name: "National Museum of Nature and Science",
      type: "museum"
    }
  )

  bj_landmarks = cities_ref.document("BJ").collection("landmarks")
  bj_landmarks.document.set(
    {
      name: "Jingshan Park",
      type: "park"
    }
  )
  bj_landmarks.document.set(
    {
      name: "Beijing Ancient Observatory",
      type: "museum"
    }
  )
  # [END firestore_query_collection_group_dataset]

  # [START firestore_query_collection_group_filter_eq]
  museums = firestore.collection_group("landmarks").where("type", "==", "museum")
  museums.get do |museum|
    puts "#{museum[:type]} name is #{museum[:name]}."
  end
  # [END firestore_query_collection_group_filter_eq]
end

if $PROGRAM_NAME == __FILE__
  project = ENV["FIRESTORE_PROJECT"]
  case ARGV.shift
  when "query_create_examples"
    query_create_examples project_id: project
  when "create_query_state"
    create_query_state project_id: project
  when "create_query_capital"
    create_query_capital project_id: project
  when "simple_queries"
    simple_queries project_id: project
  when "chained_query"
    chained_query project_id: project
  when "composite_index_chained_query"
    composite_index_chained_query project_id: project
  when "range_query"
    range_query project_id: project
  when "invalid_range_query"
    invalid_range_query project_id: project
  when "query_filter_compound_multi_ineq"
    query_filter_compound_multi_ineq project_id: project
  when "in_query_without_array"
    in_query_without_array project_id: project
  when "in_query_with_array"
    in_query_with_array project_id: project
  when "query_not_equals"
    query_not_equals project_id: project
  when "filter_not_in"
    filter_not_in project_id: project
  when "array_contains_any_queries"
    array_contains_any_queries project_id: project
  when "array_contains_filter"
    array_contains_filter project_id: project
  when "collection_group_query"
    collection_group_query project_id: project
  else
    puts <<~USAGE
      Usage: bundle exec ruby query_data.rb [command]

      Commands:
        query_create_examples             Create an example collection of documents.
        create_query_state                Create a query by state.
        create_query_capital              Create a query by capital.
        simple_queries                    Create simple queries with a single where clause.
        chained_query                     Create a query with chained clauses.
        composite_index_chained_query     Create a composite index chained query.
        range_query                       Create a query with range clauses.
        invalid_range_query               An example of an invalid range query.
        query_filter_compound_multi_ineq  Compound query with range and inequality filters on multiple fields.
        in_query_without_array            In queries without array.
        in_query_with_array               In queries with array.
        query_not_equals                  Create a query with a NOT_EQUAL where clause.
        filter_not_in                     Create a query with a NOT_IN where clause.
        array_contains_any_queries        Array contains any in query.
        array_contains_filter             Array contains filter.
        collection_group_query            Add sub collection and filter.
    USAGE
  end
end
