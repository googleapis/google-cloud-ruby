# require "google/cloud/spanner"
# require "google/cloud/spanner/admin/database"
# # Google::Cloud::Spanner.configure do |config|
# #      config.quota_project  = "span-cloud-testing"
# # end
# spanner = Google::Cloud::Spanner.new
# client  = spanner.client "aseering-us-west2", "ruby-pg-test"
# sql_query = "SELECT *  FROM accounts1 where num_test=$1"
# param_types = { p1: :PG_NUMERIC }
# params      = { p1: BigDecimal("NaN") }
# client.execute(sql_query, params: params, types: param_types).rows.each do |row|
#   puts row
# end
# client  = spanner.client "aseering-us-west2", "ruby-gsql-test"
# sql_query = "SELECT *  FROM test where nun_test

require "google/cloud/spanner"
require "google/cloud/spanner/admin/database"

# Google::Cloud::Spanner.configure do |config|
#    config.quota_project  = "span-cloud-testing"
# end

database_admin_client = Google::Cloud::Spanner::Admin::Database.database_admin

db_path = database_admin_client.database_path project: "span-cloud-testing",
                                              instance: "aseering-us-west2",
                                              database: "ruby-pg-test"
db = database_admin_client.get_database name: db_path
p db
