# frozen_string_literal: true

require "bundler/setup"
require "google-cloud-bigtable"

# Connect to bigtable and perform basic operations
# 1. Create table with column family
# 2. Insert rows and Read rows
# 3. Delete table
class HelloWorld
  attr_accessor :project_id, :instance_id, :keyfile, :bigtable

  # @param project_id [String]
  # @param instance_id [String]
  # @param keyfile [String]
  # 	keyfile .json or .p12 file path. It is optional. In case of vm/machine
  # 	have not in authorization scope keyfile required.
  def initialize(project_id, instance_id, keyfile = nil)
    @project_id = project_id
    @instance_id = instance_id
    @keyfile = keyfile

    # Init bigtable
    gcloud = Google::Cloud.new(project_id, keyfile)
    @bigtable = gcloud.bigtable
  end

  # # Create table
  #
  # Create table if not exist.
  #
  # @param table_id [String] Table name
  # @param column_family [String] Connect family name
  #
  def create_table table_id, column_family
    puts "Creating table '#{table_id}'"

    if bigtable.table(instance_id, table_id).exists?
      puts " '#{table_id}' is already exists."
    else
      bigtable.create_table(instance_id, table_id) do |column_families|
        column_families.add(
          column_family,
          Google::Cloud::Bigtable::GcRule.max_versions(3)
        )
      end
    end
  end

  # Write and Read rows.
  #
  # Each row has a unique row key.
  #
  # Note: This example uses sequential numeric IDs for simplicity, but
  # this can result in poor performance in a production application.
  # Since rows are stored in sorted order by key, sequential keys can
  # result in poor distribution of operations across nodes.
  #
  # For more information about how to design a Bigtable schema for the
  # best performance, see the documentation:
  #
  #	https://cloud.google.com/bigtable/docs/schema-design
  #
  # @param table_id [String] Table name
  # @param column_qualifier [String] Column qualifer name
  # @param column_family [String] Column family name
  #
  def write_and_read table_id, column_family, column_qualifier
    table = bigtable.table(instance_id, table_id)

    puts "Write some greetings to the table '#{table_id}'"
    greetings = ["Hello World!", "Hello Bigtable!", "Hello Ruby!"]

    # Insert rows one by one
    # Note: To perform multiple mutation on multiple rows use `mutate_rows`.
    greetings.each_with_index do |value, i|
      puts "  Writing,  Row key: greeting#{i}, Value: #{value}"

      entry = table.new_mutation_entry("greeting#{i}")
      entry.set_cell(
        column_family,
        column_qualifier,
        value,
        timestamp: Time.now.to_i * 1000
      )

      table.mutate_row(entry)
    end

    puts "Reading rows"
    table.read_rows.each do |row|
      p "  Row key: #{row.key}, Value: #{row.cells["cf"].first.value}"
    end
  end

  # # Delete table
  # Get table and delete table
  #
  # @param table_id [String] Table name
  #
  def delete_table table_id
    puts "Deleting the table '#{table_id}'"

    bigtable.delete_table(instance_id, table_id)
  end

  def do_hello_world
    table_id = "Hello-Bigtable"
    column_family = "cf"
    column_qualifier = "greeting"

    # 1. Create table with column family
    create_table(table_id, column_family)

    # 2. Insert rows and Read rows
    write_and_read(table_id, column_family, column_qualifier)

    # 3. Delete table
    delete_table(table_id)
  end
end

# # Main
#
# hello_world = HelloWorld.new(ENV["PROJECT_ID"], ENV["INSTANCE_ID"])
# hello_world.do_hello_world

# # Using keyfile
#
# hello_world = HelloWorld.new(
#  ENV["PROJECT_ID"],
#  ENV["INSTANCE_ID"],
#  "keyfile.json"
# )
# hello_world.do_hello_world
