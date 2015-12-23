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
require "gcloud/bigquery/project"

module Gcloud
  ##
  # Creates a new `Project` instance connected to the BigQuery service.
  # Each call creates a new connection.
  #
  # ### Parameters
  #
  # `project`::
  #   Identifier for a BigQuery project. If not present, the default project for
  #   the credentials is used. (`String`)
  # `keyfile`::
  #   Keyfile downloaded from Google Cloud. If file path the file must be
  #   readable. (`String` or `Hash`)
  # `scope`::
  #   The OAuth 2.0 scopes controlling the set of resources and operations that
  #   the connection can access. See [Using OAuth 2.0 to Access Google
  #   APIs](https://developers.google.com/identity/protocols/OAuth2). (`String`
  #   or `Array`)
  #
  #   The default scope is:
  #
  #   * `https://www.googleapis.com/auth/bigquery`
  #
  # ### Returns
  #
  # Gcloud::Bigquery::Project
  #
  # ### Example
  #
  #   require "gcloud/bigquery"
  #
  #   bigquery = Gcloud.bigquery
  #   dataset = bigquery.dataset "my_dataset"
  #   table = dataset.table "my_table"
  #
  def self.bigquery project = nil, keyfile = nil, scope: nil
    project ||= Gcloud::Bigquery::Project.default_project
    if keyfile.nil?
      credentials = Gcloud::Bigquery::Credentials.default scope: scope
    else
      credentials = Gcloud::Bigquery::Credentials.new keyfile, scope: scope
    end
    Gcloud::Bigquery::Project.new project, credentials
  end

  ##
  # # Google Cloud BigQuery
  #
  # Google Cloud BigQuery enables super-fast, SQL-like queries against massive
  # datasets, using the processing power of Google's infrastructure. To learn
  # more, read [What is
  # BigQuery?](https://cloud.google.com/bigquery/what-is-bigquery).
  #
  # Gcloud's goal is to provide an API that is familiar and comfortable to
  # Rubyists. Authentication is handled by Gcloud#bigquery. You can provide
  # the project and credential information to connect to the BigQuery service,
  # or if you are running on Google Compute Engine this configuration is taken
  # care of for you. You can read more about the options for connecting in the
  # [Authentication Guide](../AUTHENTICATION).
  #
  # To help you get started quickly, the first few examples below use a public
  # dataset provided by Google. As soon as you have [signed
  # up](https://cloud.google.com/bigquery/sign-up) to use BigQuery, and provided
  # that you stay in the free tier for queries, you should be able to run these
  # first examples without the need to set up billing or to load data (although
  # we'll show you how to do that too.)
  #
  # ## Listing Datasets and Tables
  #
  # A BigQuery project holds datasets, which in turn hold tables. Assuming that
  # you have not yet created datasets or tables in your own project, let's
  # connect to Google's `publicdata` project, and see what you find.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new "publicdata"
  # bigquery = gcloud.bigquery
  #
  # bigquery.datasets.count #=> 1
  # bigquery.datasets.first.dataset_id #=> "samples"
  #
  # dataset = bigquery.datasets.first
  # tables = dataset.tables
  #
  # tables.count #=> 7
  # tables.map &:table_id #=> [..., "shakespeare", "trigrams", "wikipedia"]
  # ```
  #
  # In addition listing all datasets and tables in the project, you can also
  # retrieve individual datasets and tables by ID. Let's look at the structure
  # of the `shakespeare` table, which contains an entry for every word in every
  # play written by Shakespeare.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new "publicdata"
  # bigquery = gcloud.bigquery
  #
  # dataset = bigquery.dataset "samples"
  # table = dataset.table "shakespeare"
  #
  # table.headers #=> ["word", "word_count", "corpus", "corpus_date"]
  # table.rows_count #=> 164656
  # ```
  #
  # Now that you know the column names for the Shakespeare table, you can write
  # and run a query.
  #
  # ## Running queries
  #
  # BigQuery offers both synchronous and asynchronous methods, as explained in
  # [Querying Data](https://cloud.google.com/bigquery/querying-data).
  #
  # ### Synchronous queries
  #
  # Let's start with the simpler synchronous approach. Notice that this time you
  # are connecting using your own default project. This is necessary for running
  # a query, since queries need to be able to create tables to hold results.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # bigquery = gcloud.bigquery
  #
  # sql = "SELECT TOP(word, 50) as word, COUNT(*) as count " +
  #       "FROM publicdata:samples.shakespeare"
  # data = bigquery.query sql
  #
  # data.count #=> 50
  # data.next? #=> false
  # data.first #=> {"word"=>"you", "count"=>42}
  # ```
  #
  # The `TOP` function shown above is just one of a variety of functions
  # offered by BigQuery. See the [Query
  # Reference](https://cloud.google.com/bigquery/query-reference) for a full
  # listing.
  #
  # ### Asynchronous queries
  #
  # Because you probably should not block for most BigQuery operations,
  # including querying as well as importing, exporting, and copying data, the
  # BigQuery API enables you to manage longer-running jobs. In the asynchronous
  # approach to running a query, an instance of Gcloud::Bigquery::QueryJob is
  # returned, rather than an instance of Gcloud::Bigquery::QueryData.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # bigquery = gcloud.bigquery
  #
  # sql = "SELECT TOP(word, 50) as word, COUNT(*) as count " +
  #       "FROM publicdata:samples.shakespeare"
  # job = bigquery.query_job sql
  #
  # job.wait_until_done!
  # if !job.failed?
  #   job.query_results.each do |row|
  #     puts row["word"]
  #   end
  # end
  # ```
  #
  # Once you have determined that the job is done and has not failed, you can
  # obtain an instance of Gcloud::Bigquery::QueryData by calling
  # Gcloud::Bigquery::QueryJob#query_results. The query results for both of
  # the above examples are stored in temporary tables with a lifetime of about
  # 24 hours. See the final example below for a demonstration of how to store
  # query results in a permanent table.
  #
  # ## Creating Datasets and Tables
  #
  # The first thing you need to do in a new BigQuery project is to create a
  # Gcloud::Bigquery::Dataset. Datasets hold tables and control access to them.
  #
  # ```ruby
  # require "gcloud/bigquery"
  #
  # gcloud = Gcloud.new
  # bigquery = gcloud.bigquery
  # dataset = bigquery.create_dataset "my_dataset"
  # ```
  #
  # Now that you have a dataset, you can use it to create a table. Every table
  # is defined by a schema that may contain nested and repeated fields. The
  # example below shows a schema with a repeated record field named
  # `cities_lived`. (For more information about nested and repeated fields, see
  # [Preparing Data for
  # BigQuery](https://cloud.google.com/bigquery/preparing-data-for-bigquery).)
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # bigquery = gcloud.bigquery
  # dataset = bigquery.dataset "my_dataset"
  #
  # table = dataset.create_table "people" do |schema|
  #   schema.string "first_name", mode: :required
  #   schema.record "cities_lived", mode: :repeated do |nested_schema|
  #     nested_schema.string "place", mode: :required
  #     nested_schema.integer "number_of_years", mode: :required
  #   end
  # end
  # ```
  #
  # Because of the repeated field in this schema, we cannot use the CSV format
  # to load data into the table.
  #
  # ## Loading records
  #
  # In addition to CSV, data can be imported from files that are formatted as
  # [Newline-delimited JSON](http://jsonlines.org/) or
  # [Avro](http://avro.apache.org/), or from a Google Cloud Datastore backup. It
  # can also be "streamed" into BigQuery.
  #
  # To follow along with these examples, you will need to set up billing on the
  # [Google Developers Console](https://console.developers.google.com).
  #
  # ### Streaming records
  #
  # For situations in which you want new data to be available for querying as
  # soon as possible, inserting individual records directly from your Ruby
  # application is a great approach.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # bigquery = gcloud.bigquery
  # dataset = bigquery.dataset "my_dataset"
  # table = dataset.table "people"
  #
  # rows = [
  #     {
  #         "first_name" => "Anna",
  #         "cities_lived" => [
  #             {
  #                 "place" => "Stockholm",
  #                 "number_of_years" => 2
  #             }
  #         ]
  #     },
  #     {
  #         "first_name" => "Bob",
  #         "cities_lived" => [
  #             {
  #                 "place" => "Seattle",
  #                 "number_of_years" => 5
  #             },
  #             {
  #                 "place" => "Austin",
  #                 "number_of_years" => 6
  #             }
  #         ]
  #     }
  # ]
  # table.insert rows
  # ```
  #
  # There are some trade-offs involved with streaming, so be sure to read the
  # discussion of data consistency in [Streaming Data Into
  # BigQuery](https://cloud.google.com/bigquery/streaming-data-into-bigquery).
  #
  # ### Uploading a file
  #
  # To follow along with this example, please download the
  # [names.zip](http://www.ssa.gov/OACT/babynames/names.zip) archive from the
  # U.S. Social Security Administration. Inside the archive you will find over
  # 100 files containing baby name records since the year 1880. A PDF file also
  # contained in the archive specifies the schema used below.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # bigquery = gcloud.bigquery
  # dataset = bigquery.dataset "my_dataset"
  # table = dataset.create_table "baby_names" do |schema|
  #   schema.string "name", mode: :required
  #   schema.string "sex", mode: :required
  #   schema.integer "number", mode: :required
  # end
  #
  # file = File.open "names/yob2014.txt"
  # load_job = table.load file, format: "csv"
  # ```
  #
  # Because the names data, although formatted as CSV, is distributed in files
  # with a `.txt` extension, this example explicitly passes the `format` option
  # in order to demonstrate how to handle such situations. Because CSV is the
  # default format for load operations, the option is not actually necessary.
  # For JSON saved with a `.txt` extension, however, it would be.
  #
  # ### A note about large uploads
  #
  # You may encounter a Broken pipe (Errno::EPIPE) error when attempting to
  # upload large files. To avoid this problem, add the
  # [httpclient](https://rubygems.org/gems/httpclient) gem to your project, and
  # the line (or lines) of configuration shown below. These lines must execute
  # after you require gcloud but before you make your first gcloud connection.
  # The first statement configures [Faraday](https://rubygems.org/gems/faraday)
  # to use httpclient. The second statement, which should only be added if you
  # are using a version of Faraday at or above 0.9.2, is a workaround for [this
  # gzip issue](https://github.com/GoogleCloudPlatform/gcloud-ruby/issues/367).
  #
  # ```ruby
  # require "gcloud"
  #
  # # Use httpclient to avoid broken pipe errors with large uploads
  # Faraday.default_adapter = :httpclient
  #
  # # Only add the following statement if using Faraday >= 0.9.2
  # # Override gzip middleware with no-op for httpclient
  # Faraday::Response.register_middleware :gzip =>
  #                                         Faraday::Response::Middleware
  #
  # gcloud = Gcloud.new
  # bigquery = gcloud.bigquery
  # ```
  #
  # ## Exporting query results to Google Cloud Storage
  #
  # The example below shows how to pass the `table` option with a query in order
  # to store results in a permanent table. It also shows how to export the
  # result data to a Google Cloud Storage file. In order to follow along, you
  # will need to enable the Google Cloud Storage API in addition to setting up
  # billing.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # bigquery = gcloud.bigquery
  # dataset = bigquery.dataset "my_dataset"
  # source_table = dataset.table "baby_names"
  # result_table = dataset.create_table "baby_names_results"
  #
  # sql = "SELECT name, number as count " +
  #       "FROM baby_names " +
  #       "WHERE name CONTAINS 'Sam' " +
  #       "ORDER BY count DESC"
  # query_job = dataset.query_job sql, table: result_table
  #
  # query_job.wait_until_done!
  #
  # if !query_job.failed?
  #
  #   storage = gcloud.storage
  #   bucket_id = "bigquery-exports-#{SecureRandom.uuid}"
  #   bucket = storage.create_bucket bucket_id
  #   extract_url = "gs://#{bucket.id}/baby-names-sam.csv"
  #
  #   extract_job = result_table.extract extract_url
  #
  #   extract_job.wait_until_done!
  #
  #   # Download to local filesystem
  #   bucket.files.first.download "baby-names-sam.csv"
  #
  # end
  # ```
  #
  # If a table you wish to export contains a large amount of data, you can pass
  # a wildcard URI to export to multiple files (for sharding), or an array of
  # URIs (for partitioning), or both. See [Exporting Data From
  # BigQuery](https://cloud.google.com/bigquery/exporting-data-from-bigquery)
  # for details.
  #
  module Bigquery
  end
end
