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


require "gcloud"
require "gcloud/search/project"

module Gcloud
  ##
  # Creates a new `Project` instance connected to the Search service.
  # Each call creates a new connection.
  #
  # For more information on connecting to Google Cloud see the [Authentication
  # Guide](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/guides/authentication).
  #
  # @param [String] project Identifier for a Search project. If not present, the
  #   default project for the credentials is used.
  # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud. If file
  #   path the file must be readable.
  # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
  #   set of resources and operations that the connection can access. See [Using
  #   OAuth 2.0 to Access Google
  #   APIs](https://developers.google.com/identity/protocols/OAuth2).
  #
  #   The default scopes are:
  #
  #   * `https://www.googleapis.com/auth/cloudsearch`
  #   * `https://www.googleapis.com/auth/userinfo.email`
  #
  # @return [Gcloud::Search::Project]
  #
  def self.search project = nil, keyfile = nil, scope: nil
    project ||= Gcloud::Search::Project.default_project
    if keyfile.nil?
      credentials = Gcloud::Search::Credentials.default scope: scope
    else
      credentials = Gcloud::Search::Credentials.new keyfile, scope: scope
    end
    Gcloud::Search::Project.new project, credentials
  end

  # rubocop:disable Metrics/LineLength
  # Disabled because there are links in the docs that are long.

  ##
  # # Google Cloud Search
  #
  # Google Cloud Search allows an application to quickly perform full-text and
  # geo-spatial searches without having to spin up instances and without the
  # hassle of managing and maintaining a search service.
  #
  # Cloud Search provides a model for indexing documents containing structured
  # data, with documents and indexes saved to a separate persistent store
  # optimized for search operations. The API supports full text matching on
  # string fields and allows indexing any number of documents in any number of
  # indexes.
  #
  # The Cloud Search API is an Alpha release, and might be changed in
  # backward-incompatible ways. It is not currently recommended for production
  # use. It is not subject to any SLA or deprecation policy.
  #
  # ## Accessing the Service
  #
  # Currently, the Cloud Search API is available only to white-listed users.
  # Contact your account manager or a member of the Google Cloud sales team if
  # you are interested in access.
  #
  # ## Authentication
  #
  # Authentication is handled by {Gcloud#search}. You can provide the project and
  # credential information to connect to the Cloud Search service, or if you are
  # running on Google Compute Engine this configuration is taken care of for
  # you. You can read more about the options for connecting in the
  # [Authentication
  # Guide](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/guides/authentication).
  #
  # ## Managing Indexes
  #
  # An Index is a searchable collection of documents that belongs to a Project.
  #
  # You can list the indexes in your current project:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # search = gcloud.search
  #
  # indexes = search.indexes  # API call
  # indexes.each do |index|
  #   puts index.index_id
  # end
  # ```
  #
  # And you can use the project to create new indexes:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # search = gcloud.search
  #
  # index = search.index "products", skip_lookup: true
  # ```
  #
  # A new index is an unsaved value object. Indexes cannot be created,
  # updated, or deleted directly in the service: They are derived from the
  # documents which are created "within" them. A new index will exist in the
  # service once you save a document that references it.
  #
  # ## Managing Documents
  #
  # Using an index, create a new, unsaved Document instance, providing
  # your own unique document ID, as shown below, or omitting this argument to
  # let the service assign the ID.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # search = gcloud.search
  #
  # index = search.index "products"
  # document = index.document "product-sku-000001"
  # index.find document # API call
  # #=> nil
  # document.rank #=> nil
  # ```
  #
  # Add one or more fields to the document. (See [Adding document fields](#module-Gcloud::Search-label-Adding`document`fields), below.)
  #
  # ```ruby
  # document.add "price", 24.95
  # ```
  #
  # When your document is complete, save it:
  #
  # ```ruby
  # index.save document # API call
  # document.rank # set by the server
  # #=> 1443648166
  # ```
  #
  # You can list the documents in an index:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # search = gcloud.search
  # index = search.index "products"
  #
  # documents = index.documents # API call
  # documents.map &:doc_id #=> ["product-sku-000001"]
  # ```
  #
  # And you can delete documents:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # search = gcloud.search
  # index = search.index "products"
  #
  # document = index.find "product-sku-000001"
  #
  # document.delete  # API call
  # index.find document # API call
  # #=> nil
  # ```
  #
  # To update a document after manipulating its fields or rank, just re-save it:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # search = gcloud.search
  # index = search.index "products"
  #
  # document = index.find "product-sku-000001"
  #
  # document.rank = 12345
  # document.add "price", 9.95 # replace existing number value
  # index.save document # API call
  # ```
  #
  # ## Adding document fields
  #
  # Fields belong to documents and are the data that actually gets searched.
  # Each field has a FieldValues collection, which facilitates access to
  # FieldValue objects. Each FieldValue object will be saved as one of the
  # [Cloud Search types](https://cloud.google.com/search/documents_indexes#document_fields_field_names_and_multi-valued_fields).
  # The type will be inferred from the value when possible, or you can
  # explicitly specify it by passing a symbol with the `type` option to
  # {Gcloud::Search::Document#add}.
  #
  # - String (`:atom`, `:html`, `:text`, or `:default`)
  # - Number (`:number`)
  # - Timestamp (`:datetime`)
  # - Geovalue (`:geo`)
  #
  # String values can be tokenized using one of three different types of
  # tokenization, which can be passed with the `type` option when the value is
  # added:
  #
  # - `:atom` means "don't tokenize this string", treat it as one
  #   thing to compare against
  #
  # - `:html` means "treat this string as HTML", not comparing against the
  #   tags, and treating the rest of the content like `:text`
  #
  # - `:text` means "treat this string as normal text" and split words
  #   apart to be compared against
  #
  # Again, you can add more than one value to a field, and the values may be of
  # different types.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # search = gcloud.search
  #
  # index = search.index "products"
  # document = index.find "product-sku-000001"
  # document.add "description", "The best T-shirt ever.", type: :text, lang: "en"
  # document.add "description", "<p>The best T-shirt ever.</p>", type: :html, lang: "en"
  # document["description"].size #=> 2
  # ```
  #
  # ## Searching
  #
  # After populating an index with documents, you can request search results
  # with a query:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # search = gcloud.search
  # index = search.index "books"
  #
  # results = index.search "dark stormy"
  # results.each do |result|
  #   puts result.doc_id
  # end
  # ```
  #
  # By default, Result objects are sorted by document rank. For more information
  # see the [REST API documentation for Document.rank](https://cloud.google.com/search/reference/rest/v1/projects/indexes/documents#resource_representation.google.cloudsearch.v1.Document.rank).
  #
  # You can specify how to sort results with the `order` option:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # search = gcloud.search
  # index = search.index "books"
  #
  # results = index.search "dark stormy", order: "published, avg_review desc"
  # documents = index.search query # API call
  # ```
  #
  # You can add computed fields with the `expressions` option, and specify the
  # fields that are returned with the `fields` option. No document data will be
  # returned if you omit the `fields` option, only `doc_id` references to any
  # matched documents.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # search = gcloud.search
  # index = search.index "products"
  #
  # results = index.search "cotton T-shirt",
  #                        expressions: { total_price: "(price + tax)" },
  #                        fields: ["name", "total_price", "highlight"]
  # ```
  #
  # Just as in documents, Result data is accessible via Fields methods:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # search = gcloud.search
  # index = search.index "products"
  # document = index.find "product-sku-000001"
  # results = index.search "cotton T-shirt"
  # values = results[0]["description"]
  #
  # values[0] #=> "100% organic cotton ruby gem T-shirt"
  # values[0].type #=> :text
  # values[0].lang #=> "en"
  # values[1] #=> "<p>100% organic cotton ruby gem T-shirt</p>"
  # values[1].type #=> :html
  # values[1].lang #=> "en"
  # ```
  #
  module Search
  end
  # rubocop:enable Metrics/LineLength
end
