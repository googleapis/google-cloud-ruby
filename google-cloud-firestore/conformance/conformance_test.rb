# Copyright 2018 Google LLC
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

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "google/cloud/firestore"
require "grpc"

require "test-definition_pb"

class MyTests < MiniTest::Unit::TestCase
  attr_reader :project, :default_project_options, :default_options, :credentials, :firestore

  file = File.open "conformance/test-suite.binproto", "rb"
  test_suite = Tests::TestSuite.decode file.read
  @@tests = test_suite.tests

  def setup
    @project =  "projectID"
    @default_project_options =  Google::Gax::CallOptions.new(kwargs: { "google-cloud-resource-prefix" => "projects/#{project}" })
    @default_options =  Google::Gax::CallOptions.new(kwargs: { "google-cloud-resource-prefix" => "projects/#{project}/databases/(default)" })
    @credentials =  OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    @firestore =  Google::Cloud::Firestore::Client.new(Google::Cloud::Firestore::Service.new(project, credentials))
  end

  @@tests.each_with_index do |wrapper, i|

    #next unless [:query].include?(wrapper.test)
    #next unless (77..102).include?(i)
    next unless [1].include?(i)

    define_method("test_conformance_#{i}_#{wrapper.test}") do
      puts wrapper.description
      test_name = wrapper.test
      test = wrapper.send test_name
      next if test.respond_to?(:is_error) && test.is_error
      puts "#{test.inspect}\n\n"

      #puts "#{i} - #{test.description} #{"[Error]" if test.respond_to?(:is_error) && test.is_error}"
      #puts "#{test.description}\t\t#{test.inspect}"
      firestore_execute_mock = Minitest::Mock.new

      # API under test
      #next unless test.respond_to?(:request)
      case test_name
        when :get
          puts "skip - Google::Firestore::V1beta1::GetDocumentRequest is not used."
        when :create
          #next
          puts "#{test.request.inspect}\n"
          client_mocks firestore_execute_mock
          firestore_execute_mock.expect :call, firestore_execute_mock, [test.request, Hash]
          firestore_execute_mock.expect :execute, OpenStruct.new(write_results: nil), []

          Google::Gax::Grpc.stub :create_stub, firestore_execute_mock do

            gax_client = Google::Cloud::Firestore::V1beta1::FirestoreClient.new(
                credentials: credentials,
                lib_name: "gccl",
                lib_version: Google::Cloud::Firestore::VERSION
            )
            firestore.service.instance_variable_set :@firestore, gax_client
            document_path = test.doc_ref_path.split("/documents/")[1]
            data = JSON.parse(test.json_data)
            convert_values data

            # API under test
            firestore.batch do |b|
              b.create document_path, data
            end
          end
          firestore_execute_mock.verify
        when :set
          #next
          client_mocks firestore_execute_mock
          puts test.request.inspect
          firestore_execute_mock.expect :call, firestore_execute_mock, [test.request, Hash]
          firestore_execute_mock.expect :execute, OpenStruct.new(write_results: nil), []

          Google::Gax::Grpc.stub :create_stub, firestore_execute_mock do

            gax_client = Google::Cloud::Firestore::V1beta1::FirestoreClient.new(
                credentials: credentials,
                lib_name: "gccl",
                lib_version: Google::Cloud::Firestore::VERSION
            )
            firestore.service.instance_variable_set :@firestore, gax_client
            document_path = test.doc_ref_path.split("/documents/")[1]
            data = JSON.parse(test.json_data)
            convert_values data

            merge = if test.option && test.option.all
                      true
                    elsif test.option && !test.option.fields.empty?
                      test.option.fields.map do |fp|
                        Google::Cloud::Firestore::FieldPath.new fp.field
                      end
                    end
            puts "merge: #{merge}"

            # API under test
            firestore.batch do |b|
              b.set document_path, data, merge: merge
            end
          end
          firestore_execute_mock.verify
        when :update
          #next
          client_mocks firestore_execute_mock
          puts test.request.inspect
          firestore_execute_mock.expect :call, firestore_execute_mock, [test.request, Hash]
          firestore_execute_mock.expect :execute, OpenStruct.new(write_results: nil), []

          Google::Gax::Grpc.stub :create_stub, firestore_execute_mock do

            gax_client = Google::Cloud::Firestore::V1beta1::FirestoreClient.new(
                credentials: credentials,
                lib_name: "gccl",
                lib_version: Google::Cloud::Firestore::VERSION
            )
            firestore.service.instance_variable_set :@firestore, gax_client
            document_path = test.doc_ref_path.split("/documents/")[1]
            data = JSON.parse(test.json_data)
            convert_values data

            if test.precondition && test.precondition.update_time
              update_time = Time.at(test.precondition.update_time.seconds)
            end

            # API under test
            firestore.batch do |b|
              b.update document_path, data, update_time: update_time
            end
          end
          firestore_execute_mock.verify
        when :update_paths
          #next
          client_mocks firestore_execute_mock
          puts test.request.inspect
          firestore_execute_mock.expect :call, firestore_execute_mock, [test.request, Hash]
          firestore_execute_mock.expect :execute, OpenStruct.new(write_results: nil), []

          Google::Gax::Grpc.stub :create_stub, firestore_execute_mock do

            gax_client = Google::Cloud::Firestore::V1beta1::FirestoreClient.new(
                credentials: credentials,
                lib_name: "gccl",
                lib_version: Google::Cloud::Firestore::VERSION
            )
            firestore.service.instance_variable_set :@firestore, gax_client
            document_path = test.doc_ref_path.split("/documents/")[1]

            keys = test.field_paths.map do |fp|
              firestore.field_path fp.field
            end
            values = test.json_values.map {|v| JSON.parse v }
            data = Hash[keys.zip(values)]
            puts "#{data.inspect}"
            convert_values data
            puts "#{data.inspect}"

            if test.precondition && test.precondition.update_time
              update_time = Time.at(test.precondition.update_time.seconds)
            end

            # API under test
            firestore.batch do |b|
              b.update document_path, data, update_time: update_time
            end
          end
          firestore_execute_mock.verify
        when :delete

          client_mocks firestore_execute_mock
          puts test.inspect
          firestore_execute_mock.expect :call, firestore_execute_mock, [test.request, Hash]
          firestore_execute_mock.expect :execute, OpenStruct.new(write_results: nil), []
          opts = {}
          if test.precondition && test.precondition.exists
            opts[:exists] = test.precondition.exists
          end
          if test.precondition && test.precondition.update_time
            opts[:update_time] = Time.at(test.precondition.update_time.seconds)
          end
          Google::Gax::Grpc.stub :create_stub, firestore_execute_mock do

            gax_client = Google::Cloud::Firestore::V1beta1::FirestoreClient.new(
                credentials: credentials,
                lib_name: "gccl",
                lib_version: Google::Cloud::Firestore::VERSION
            )
            firestore.service.instance_variable_set :@firestore, gax_client
            document_path = test.doc_ref_path.split("/documents/")[1]

            # API under test
            firestore.batch do |b|
              b.delete document_path, opts
            end
          end
          firestore_execute_mock.verify
        when :query
          next
          puts test.inspect
          query = build_query test, get_collection_reference(test.coll_path)
          assert_equal test.query, query
        when :listen
          next
          # TODO
        else
          raise "Unexpected test: #{test_name}"
      end
    end
  end

  def convert_values hsh
    hsh.each_pair do |k,v|
      if v.kind_of? Hash
        v.each_pair do |k2,v2|
          v[k2] = convert_string_value v2
        end
      else
        hsh[k] = convert_string_value v
      end
    end
  end

  def convert_string_value val
    case val
      when "Delete"
        firestore.field_delete
      when "ServerTimestamp"
        firestore.field_server_time
      else
        val
    end
  end

  def get_collection_reference resource_name
    col_path = resource_name.split("/documents/")[1]
    firestore.col col_path
  end

  def build_query test, col
    test.clauses.each do |clause|
      puts "\nclause: #{clause.inspect}"
      col = if clause.select
              col.select(clause.select.fields.map(&:field))
            elsif where = clause.where
              field_path = Google::Cloud::Firestore::FieldPath.new convert_field_path(where)
              where_value = JSON.parse where.json_value
              col.where(field_path, where.op, where_value)
            elsif clause.order_by
              direction = clause.order_by.direction
              col.order convert_field_path(clause.order_by), direction
            elsif clause.offset && clause.offset != 0
              col.offset clause.offset
            elsif  clause.limit && clause.limit != 0
              col.limit clause.limit
            elsif clause.start_at
              col.start_at convert_cursor(clause.start_at)
            elsif clause.start_after
              col.start_after convert_cursor(clause.start_after)
            elsif clause.end_at
              col.end_at convert_cursor(clause.end_at)
            elsif clause.end_before
              col.end_before convert_cursor(clause.end_before)
            else
              raise "Unexpected Clause state: #{clause.inspect}"
            end
    end
    puts "\ntest.query.where: #{test.query.where.inspect}\n"

    #fields = .first.select.fields.map &:field
    #query = col.select fields
    col.query
  end

  def convert_cursor clause_val
    clause_val.json_values.map {|x| JSON.parse x }
  end

  def convert_field_path clause_val
    clause_val.path.field.first
  end

  def client_mocks firestore_execute_mock
    # FirestoreClient.new
    firestore_execute_mock.expect :call, firestore_execute_mock, ["firestore.googleapis.com", 443, Hash]
    firestore_execute_mock.expect :method, firestore_execute_mock, [:get_document]
    firestore_execute_mock.expect :method, firestore_execute_mock, [:list_documents]
    firestore_execute_mock.expect :method, firestore_execute_mock, [:create_document]
    firestore_execute_mock.expect :method, firestore_execute_mock, [:update_document]
    firestore_execute_mock.expect :method, firestore_execute_mock, [:delete_document]
    firestore_execute_mock.expect :method, firestore_execute_mock, [:batch_get_documents]
    firestore_execute_mock.expect :method, firestore_execute_mock, [:begin_transaction]
    firestore_execute_mock.expect :method, firestore_execute_mock, [:commit]
    firestore_execute_mock.expect :method, firestore_execute_mock, [:rollback]
    firestore_execute_mock.expect :method, firestore_execute_mock, [:run_query]
    firestore_execute_mock.expect :method, firestore_execute_mock, [:write]
    firestore_execute_mock.expect :method, firestore_execute_mock, [:listen]
    firestore_execute_mock.expect :method, firestore_execute_mock, [:list_collection_ids]
  end
end

##
# Failures
#

# 30 fields in actual document mask are not sorted. actual: DocumentMask: field_paths: ["h.g", "h.f"]
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"h"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 0, double_value: 0.0, reference_value: "", map_value: <Google::Firestore::V1beta1::MapValue: fields: {"f"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 4, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">, "g"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 3, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}>, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["h.f", "h.g"]>, current_document: nil, transform: nil>], transaction: "">
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"h"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 0, double_value: 0.0, reference_value: "", map_value: <Google::Firestore::V1beta1::MapValue: fields: {"f"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 4, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">, "g"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 3, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}>, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["h.g", "h.f"]>, current_document: nil, transform: nil>], transaction: "">

# 38
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"a"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["a"]>, current_document: nil, transform: nil>], transaction: "">
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"a"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["a"]>, current_document: nil, transform: nil>, <Google::Firestore::V1beta1::Write: update: nil, delete: "", update_mask: nil, current_document: nil, transform: <Google::Firestore::V1beta1::DocumentTransform: document: "projects/projectID/databases/(default)/documents/C/d", field_transforms: [<Google::Firestore::V1beta1::DocumentTransform::FieldTransform: field_path: "b", set_to_server_value: :REQUEST_TIME>]>>], transaction: "">

#41
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["h"]>, current_document: nil, transform: nil>, <Google::Firestore::V1beta1::Write: update: nil, delete: "", update_mask: nil, current_document: nil, transform: <Google::Firestore::V1beta1::DocumentTransform: document: "projects/projectID/databases/(default)/documents/C/d", field_transforms: [<Google::Firestore::V1beta1::DocumentTransform::FieldTransform: field_path: "h.g", set_to_server_value: :REQUEST_TIME>]>>], transaction: "">
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"h."=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 0, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["`h.`"]>, current_document: nil, transform: nil>, <Google::Firestore::V1beta1::Write: update: nil, delete: "", update_mask: nil, current_document: nil, transform: <Google::Firestore::V1beta1::DocumentTransform: document: "projects/projectID/databases/(default)/documents/C/d", field_transforms: [<Google::Firestore::V1beta1::DocumentTransform::FieldTransform: field_path: "h.g", set_to_server_value: :REQUEST_TIME>]>>], transaction: "">

# 42 Actual does not include "b.c" in document mask
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"a"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["a", "b.c"]>, current_document: nil, transform: nil>], transaction: "">
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"a"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["a"]>, current_document: nil, transform: nil>], transaction: "">

# 43 Actual does not include "b.c" in document mask
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"a"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["a", "b.c"]>, current_document: nil, transform: nil>], transaction: "">
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"a"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["a"]>, current_document: nil, transform: nil>], transaction: "">

# 51 - actual is missing update_mask
# <Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"a"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["a"]>, current_document: <Google::Firestore::V1beta1::Precondition: exists: true, update_time: nil>, transform: nil>], transaction: "">
# <Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"a"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: nil, current_document: <Google::Firestore::V1beta1::Precondition: exists: false, update_time: nil>, transform: nil>], transaction: "">

## 65 actual does not include "b" in document mask
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"a"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["a", "b"]>, current_document: <Google::Firestore::V1beta1::Precondition: exists: true, update_time: nil>, transform: nil>, <Google::Firestore::V1beta1::Write: update: nil, delete: "", update_mask: nil, current_document: nil, transform: <Google::Firestore::V1beta1::DocumentTransform: document: "projects/projectID/databases/(default)/documents/C/d", field_transforms: [<Google::Firestore::V1beta1::DocumentTransform::FieldTransform: field_path: "b.c", set_to_server_value: :REQUEST_TIME>]>>], transaction: "">
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"a"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["a"]>, current_document: <Google::Firestore::V1beta1::Precondition: exists: true, update_time: nil>, transform: nil>, <Google::Firestore::V1beta1::Write: update: nil, delete: "", update_mask: nil, current_document: nil, transform: <Google::Firestore::V1beta1::DocumentTransform: document: "projects/projectID/databases/(default)/documents/C/d", field_transforms: [<Google::Firestore::V1beta1::DocumentTransform::FieldTransform: field_path: "b.c", set_to_server_value: :REQUEST_TIME>]>>], transaction: "">

## 66 similar to 65

# 74 fields in actual document mask are not sorted
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"b"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 0, double_value: 0.0, reference_value: "", map_value: <Google::Firestore::V1beta1::MapValue: fields: {"d"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 2, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}>, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">, "a"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["a", "b.c", "b.d"]>, current_document: <Google::Firestore::V1beta1::Precondition: exists: true, update_time: nil>, transform: nil>], transaction: "">
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"b"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 0, double_value: 0.0, reference_value: "", map_value: <Google::Firestore::V1beta1::MapValue: fields: {"d"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 2, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}>, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">, "a"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["a", "b.d", "b.c"]>, current_document: <Google::Firestore::V1beta1::Precondition: exists: true, update_time: nil>, transform: nil>], transaction: "">

# 91 actual does not include "b" in document mask
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"a"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["a", "b"]>, current_document: <Google::Firestore::V1beta1::Precondition: exists: true, update_time: nil>, transform: nil>, <Google::Firestore::V1beta1::Write: update: nil, delete: "", update_mask: nil, current_document: nil, transform: <Google::Firestore::V1beta1::DocumentTransform: document: "projects/projectID/databases/(default)/documents/C/d", field_transforms: [<Google::Firestore::V1beta1::DocumentTransform::FieldTransform: field_path: "b.c", set_to_server_value: :REQUEST_TIME>]>>], transaction: "">
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"a"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["a"]>, current_document: <Google::Firestore::V1beta1::Precondition: exists: true, update_time: nil>, transform: nil>, <Google::Firestore::V1beta1::Write: update: nil, delete: "", update_mask: nil, current_document: nil, transform: <Google::Firestore::V1beta1::DocumentTransform: document: "projects/projectID/databases/(default)/documents/C/d", field_transforms: [<Google::Firestore::V1beta1::DocumentTransform::FieldTransform: field_path: "b.c", set_to_server_value: :REQUEST_TIME>]>>], transaction: "">

# 92 actual does not include "c" in document mask
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"a"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["a", "c"]>, current_document: <Google::Firestore::V1beta1::Precondition: exists: true, update_time: nil>, transform: nil>, <Google::Firestore::V1beta1::Write: update: nil, delete: "", update_mask: nil, current_document: nil, transform: <Google::Firestore::V1beta1::DocumentTransform: document: "projects/projectID/databases/(default)/documents/C/d", field_transforms: [<Google::Firestore::V1beta1::DocumentTransform::FieldTransform: field_path: "b", set_to_server_value: :REQUEST_TIME>, <Google::Firestore::V1beta1::DocumentTransform::FieldTransform: field_path: "c.d", set_to_server_value: :REQUEST_TIME>]>>], transaction: "">
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"a"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["a"]>, current_document: <Google::Firestore::V1beta1::Precondition: exists: true, update_time: nil>, transform: nil>, <Google::Firestore::V1beta1::Write: update: nil, delete: "", update_mask: nil, current_document: nil, transform: <Google::Firestore::V1beta1::DocumentTransform: document: "projects/projectID/databases/(default)/documents/C/d", field_transforms: [<Google::Firestore::V1beta1::DocumentTransform::FieldTransform: field_path: "b", set_to_server_value: :REQUEST_TIME>, <Google::Firestore::V1beta1::DocumentTransform::FieldTransform: field_path: "c.d", set_to_server_value: :REQUEST_TIME>]>>], transaction: "">

# 99 fields in actual document mask are not sorted.  actual: field_paths: ["`*`.`~`", "`*`.`\\``"]
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"*"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 0, double_value: 0.0, reference_value: "", map_value: <Google::Firestore::V1beta1::MapValue: fields: {"`"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 2, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">, "~"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}>, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["`*`.`\\``", "`*`.`~`"]>, current_document: <Google::Firestore::V1beta1::Precondition: exists: true, update_time: nil>, transform: nil>], transaction: "">
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"*"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 0, double_value: 0.0, reference_value: "", map_value: <Google::Firestore::V1beta1::MapValue: fields: {"`"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 2, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">, "~"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}>, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["`*`.`~`", "`*`.`\\``"]>, current_document: <Google::Firestore::V1beta1::Precondition: exists: true, update_time: nil>, transform: nil>], transaction: "">

# 106 Actual does not contain  fields: [<Google::Firestore::V1beta1::StructuredQuery::FieldReference: field_path: "__name__">]
# 108 actual has fields from both select clauses
# 109 Actual has CompositeFilter: op: :AND
# 111 Actual has CompositeFilter: op: :AND
# 112 Actual has CompositeFilter: op: :AND
# 119-126 blowmage cursor work in branch, skip

##
# List of tests
#

# 0 - get: get a document
# 1 - create: basic
# 2 - create: complex
# 3 - create: creating or setting an empty map
# 4 - create: don’t split on dots
# 5 - create: non-alpha characters in map keys
# 6 - create: Delete cannot appear in data [Error]
# 7 - create: ServerTimestamp with data
# 8 - create: nested ServerTimestamp field
# 9 - create: multiple ServerTimestamp fields
# 10 - create: ServerTimestamp cannot be in an array value [Error]
# 11 - create: ServerTimestamp cannot be anywhere inside an array value [Error]
# 12 - create: Delete cannot be in an array value [Error]
# 13 - create: Delete cannot be anywhere inside an array value [Error]
# 14 - create: ServerTimestamp alone
# 15 - set: basic
# 16 - set: complex
# 17 - set: creating or setting an empty map
# 18 - set: don’t split on dots
# 19 - set: non-alpha characters in map keys
# 20 - set: Delete cannot appear in data [Error]
# 21 - set: ServerTimestamp with data
# 22 - set: nested ServerTimestamp field
# 23 - set: multiple ServerTimestamp fields
# 24 - set: ServerTimestamp cannot be in an array value [Error]
# 25 - set: ServerTimestamp cannot be anywhere inside an array value [Error]
# 26 - set: Delete cannot be in an array value [Error]
# 27 - set: Delete cannot be anywhere inside an array value [Error]
# 28 - set: ServerTimestamp alone
# 29 - set: MergeAll
# 30 - set: MergeAll with nested fields
# 31 - set-merge: Merge with a field
# 32 - set-merge: Merge with a nested field
# 33 - set-merge: Merge field is not a leaf
# 34 - set-merge: Merge with FieldPaths
# 35 - set: ServerTimestamp with MergeAll
# 36 - set: ServerTimestamp alone with MergeAll
# 37 - set-merge: ServerTimestamp with Merge of both fields
# 38 - set-merge: If is ServerTimestamp not in Merge, no transform
# 39 - set-merge: If no ordinary values in Merge, no write
# 40 - set-merge: non-leaf merge field with ServerTimestamp
# 41 - set-merge: non-leaf merge field with ServerTimestamp alone
# 42 - set: Delete with MergeAll
# 43 - set-merge: Delete with merge
# 44 - set-merge: Delete with merge
# 45 - set: MergeAll can be specified with empty data.
# 46 - set-merge: Merge fields must all be present in data [Error]
# 47 - set: Delete cannot appear unless a merge option is specified [Error]
# 48 - set-merge: Delete cannot appear in an unmerged field [Error]
# 49 - set-merge: Delete cannot appear as part of a merge path [Error]
# 50 - set-merge: One merge path cannot be the prefix of another [Error]
# 51 - update: basic
# 52 - update: complex
# 53 - update: Delete
# 54 - update: Delete alone
# 55 - update: last-update-time precondition
# 56 - update: no paths [Error]
# 57 - update: empty field path component [Error]
# 58 - update: prefix #1 [Error]
# 59 - update: prefix #2 [Error]
# 60 - update: prefix #3 [Error]
# 61 - update: Delete cannot be nested [Error]
# 62 - update: Exists precondition is invalid [Error]
# 63 - update: ServerTimestamp alone
# 64 - update: ServerTimestamp with data
# 65 - update: nested ServerTimestamp field
# 66 - update: multiple ServerTimestamp fields
# 67 - update: ServerTimestamp cannot be in an array value [Error]
# 68 - update: ServerTimestamp cannot be anywhere inside an array value [Error]
# 69 - update: Delete cannot be in an array value [Error]
# 70 - update: Delete cannot be anywhere inside an array value [Error]
# 71 - update: split on dots
# 72 - update: non-letter starting chars are quoted, except underscore
# 73 - update: Split on dots for top-level keys only
# 74 - update: Delete with a dotted field
# 75 - update: ServerTimestamp with dotted field
# 76 - update: invalid character [Error]
# 77 - update-paths: basic
# 78 - update-paths: complex
# 79 - update-paths: Delete
# 80 - update-paths: Delete alone
# 81 - update-paths: last-update-time precondition
# 82 - update-paths: no paths [Error]
# 83 - update-paths: empty field path component [Error]
# 84 - update-paths: prefix #1 [Error]
# 85 - update-paths: prefix #2 [Error]
# 86 - update-paths: prefix #3 [Error]
# 87 - update-paths: Delete cannot be nested [Error]
# 88 - update-paths: Exists precondition is invalid [Error]
# 89 - update-paths: ServerTimestamp alone
# 90 - update-paths: ServerTimestamp with data
# 91 - update-paths: nested ServerTimestamp field
# 92 - update-paths: multiple ServerTimestamp fields
# 93 - update-paths: ServerTimestamp cannot be in an array value [Error]
# 94 - update-paths: ServerTimestamp cannot be anywhere inside an array value [Error]
# 95 - update-paths: Delete cannot be in an array value [Error]
# 96 - update-paths: Delete cannot be anywhere inside an array value [Error]
# 97 - update-paths: multiple-element field path
# 98 - update-paths: FieldPath elements are not split on dots
# 99 - update-paths: special characters
# 100 - update-paths: field paths with delete
# 101 - update-paths: empty field path [Error]
# 102 - update-paths: duplicate field path [Error]
# 103 - delete: delete without precondition
# 104 - delete: delete with last-update-time precondition
# 105 - delete: delete with exists precondition
# 106 - query: empty Select clause
# 107 - query: Select clause with some fields
# 108 - query: two Select clauses
# 109 - query: Where clause
# 110 - query: two Where clauses
# 111 - query: a Where clause comparing to null
# 112 - query: a Where clause comparing to NaN
# 113 - query: Offset and Limit clauses
# 114 - query: multiple Offset and Limit clauses
# 115 - query: basic OrderBy clauses
# 116 - query: StartAt/EndBefore with values
# 117 - query: StartAfter/EndAt with values
# 118 - query: Start/End with two values
# 119 - query: cursor methods with __name__
# 120 - query: cursor methods, last one wins
# 121 - query: cursor methods with a document snapshot
# 122 - query: cursor methods with a document snapshot, existing orderBy
# 123 - query: cursor methods with a document snapshot and an equality where clause
# 124 - query: cursor method with a document snapshot and an inequality where clause
# 125 - query: cursor method, doc snapshot, inequality where clause, and existing orderBy clause
# 126 - query: cursor method, doc snapshot, existing orderBy __name__
# 127 - query: invalid operator in Where clause [Error]
# 128 - query: invalid path in Where clause [Error]
# 129 - query: invalid path in Where clause [Error]
# 130 - query: invalid path in OrderBy clause [Error]
# 131 - query: cursor method without orderBy [Error]
# 132 - query: ServerTimestamp in Where [Error]
# 133 - query: Delete in Where [Error]
# 134 - query: ServerTimestamp in cursor method [Error]
# 135 - query: Delete in cursor method [Error]
# 136 - query: doc snapshot with wrong collection in cursor method [Error]
# 137 - query: where clause with non-== comparison with Null [Error]
# 138 - query: where clause with non-== comparison with NaN [Error]
# 139 - listen: no changes; empty snapshot
# 140 - listen: add a doc
# 141 - listen: add a doc, modify it, delete it, then add it again
# 142 - listen: add a doc, then change it but without changing its update time
# 143 - listen: add three documents
# 144 - listen: no snapshot if we don't see CURRENT
# 145 - listen: multiple documents, added, deleted and updated
# 146 - listen: RESET turns off CURRENT
# 147 - listen: DocumentRemove behaves like DocumentDelete
# 148 - listen: Filter response with same size is a no-op
# 149 - listen: DocumentChange with removed_target_id is like a delete.
# 150 - listen: TargetChange_ADD is a no-op if it has the same target ID
# 151 - listen: TargetChange_ADD is an error if it has a different target ID [Error]
# 152 - listen: TargetChange_REMOVE should not appear [Error]

