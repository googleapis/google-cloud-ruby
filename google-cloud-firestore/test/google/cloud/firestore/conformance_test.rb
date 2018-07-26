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

require "helper.rb"
require_relative "../../../../conformance/test-definition_pb"

class ConformanceTest < MockFirestore
  def doc_ref_from_path doc_path
    Google::Cloud::Firestore::DocumentReference.from_path doc_path, firestore
  end

  def doc_snap_from_path_and_json_data doc_path, json_data
    Google::Cloud::Firestore::DocumentSnapshot.new.tap do |s|
      s.grpc = Google::Firestore::V1beta1::Document.new(
        name: doc_path,
        fields: Google::Cloud::Firestore::Convert.hash_to_fields(data_from_json(json_data))
      )
      s.instance_variable_set :@ref, doc_ref_from_path(doc_path)
    end
  end

  def data_from_json data_json
    convert_values JSON.parse data_json
  end

  def data_from_field_paths_and_json field_paths, data_json
    keys = field_paths.map do |fp|
      firestore.field_path fp.field
    end
    values = data_json.map {|v| JSON.parse v }
    data = Hash[keys.zip(values)]
    convert_values data
    data
  end

  def convert_values data
    if data == "Delete"
      firestore.field_delete
    elsif data == "ServerTimestamp"
      firestore.field_server_time
    elsif data == "NaN"
      Float::NAN
    elsif data.is_a? Hash
      Hash[data.map { |k, v| [k, convert_values(v)] }]
    elsif data.is_a? Array
      data.map { |v| convert_values(v) }
    else
      data
    end
  end
end

class ConformanceCreate < ConformanceTest
  let(:commit_time) { Time.now }
  let :commit_resp do
    Google::Firestore::V1beta1::CommitResponse.new(
      commit_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time),
      write_results: [Google::Firestore::V1beta1::WriteResult.new(
        update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time))]
      )
  end

  def self.build_test_for description, test, i
    define_method("test_#{i}: #{description}") do
      doc_ref = doc_ref_from_path test.doc_ref_path
      data = data_from_json test.json_data

      if test.is_error
        expect do
          doc_ref.create data
        end.must_raise ArgumentError
      else
        firestore_mock.expect :commit, commit_resp, [test.request.database, test.request.writes, options: default_options]

        doc_ref.create data
      end
    end
  end
end

class ConformanceSet < ConformanceTest
  let(:commit_time) { Time.now }
  let :commit_resp do
    Google::Firestore::V1beta1::CommitResponse.new(
      commit_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time),
      write_results: [Google::Firestore::V1beta1::WriteResult.new(
        update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time))]
      )
  end

  def self.build_test_for description, test, i
    define_method("test_#{i}: #{description}") do
      doc_ref = doc_ref_from_path test.doc_ref_path
      data = data_from_json test.json_data
      merge = if test.option && test.option.all
                true
              elsif test.option && !test.option.fields.empty?
                test.option.fields.map do |fp|
                  firestore.field_path fp.field
                end
              end

      if test.is_error
        expect do
          doc_ref.set data, merge: merge
        end.must_raise ArgumentError
      else
        firestore_mock.expect :commit, commit_resp, [test.request.database, test.request.writes, options: default_options]

        doc_ref.set data, merge: merge
      end
    end
  end
end

class ConformanceUpdate < ConformanceTest
  let(:commit_time) { Time.now }
  let :commit_resp do
    Google::Firestore::V1beta1::CommitResponse.new(
        commit_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time),
        write_results: [Google::Firestore::V1beta1::WriteResult.new(
                            update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time))]
    )
  end

  def self.build_test_for description, test, i
    define_method("test_#{i}: #{description}") do
      doc_ref = doc_ref_from_path test.doc_ref_path
      data = data_from_json test.json_data

      if test.is_error
        expect do
          doc_ref.update data
        end.must_raise ArgumentError
      else
        firestore_mock.expect :commit, commit_resp, [test.request.database, test.request.writes, options: default_options]

        if test.precondition && test.precondition.update_time
          update_time = Time.at(test.precondition.update_time.seconds)
        end

        doc_ref.update data, update_time: update_time
      end
    end
  end
end

class ConformanceUpdatePaths < ConformanceTest
  let(:commit_time) { Time.now }
  let :commit_resp do
    Google::Firestore::V1beta1::CommitResponse.new(
        commit_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time),
        write_results: [Google::Firestore::V1beta1::WriteResult.new(
                            update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time))]
    )
  end

  def self.build_test_for description, test, i
    define_method("test_#{i}: #{description}") do
      doc_ref = doc_ref_from_path test.doc_ref_path

      if test.is_error
        expect do
          data = data_from_field_paths_and_json test.field_paths, test.json_values
          doc_ref.update data
        end.must_raise ArgumentError
      else
        data =  data_from_field_paths_and_json test.field_paths, test.json_values
        firestore_mock.expect :commit, commit_resp, [test.request.database, test.request.writes, options: default_options]

        if test.precondition && test.precondition.update_time
          update_time = Time.at(test.precondition.update_time.seconds)
        end

        doc_ref.update data, update_time: update_time
      end
    end
  end
end

class ConformanceDelete < ConformanceTest
  let(:commit_time) { Time.now }
  let :commit_resp do
    Google::Firestore::V1beta1::CommitResponse.new(
        commit_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time),
        write_results: [Google::Firestore::V1beta1::WriteResult.new(
                            update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time))]
    )
  end

  def self.build_test_for description, test, i
    define_method("test_#{i}: #{description}") do
      doc_ref = doc_ref_from_path test.doc_ref_path
      opts = {}
      if test.precondition && test.precondition.exists
        opts[:exists] = test.precondition.exists
      end
      if test.precondition && test.precondition.update_time
        opts[:update_time] = Time.at(test.precondition.update_time.seconds)
      end
      if test.is_error
        expect do
          doc_ref.delete opts
        end.must_raise ArgumentError
      else
        firestore_mock.expect :commit, commit_resp, [test.request.database, test.request.writes, options: default_options]

        doc_ref.delete opts
      end
    end
  end
end

class ConformanceQuery < ConformanceTest
  def self.build_test_for description, test, i
    define_method("test_#{i}: #{description}") do
      if test.is_error
        expect do
          build_query test, get_collection_reference(test.coll_path)
        end.must_raise ArgumentError
      else
        query = build_query test, get_collection_reference(test.coll_path)
        assert_equal test.query, query
      end
    end
  end

  def get_collection_reference resource_name
    col_path = resource_name.split("/documents/")[1]
    firestore.col col_path
  end

  def build_query test, col
    test.clauses.each do |clause|
      col = if clause.select
              col.select(clause.select.fields.map(&:field))
            elsif where = clause.where
              field_path = convert_field_path where
              where_value = data_from_json where.json_value
              col.where(field_path, where.op, where_value)
            elsif clause.order_by
              direction = clause.order_by.direction
              col.order convert_field_path(clause.order_by), direction
            elsif clause.offset && clause.offset != 0
              col.offset clause.offset
            elsif  clause.limit && clause.limit != 0
              col.limit clause.limit
            elsif clause.start_at
              col.start_at *convert_cursor(clause.start_at)
            elsif clause.start_after
              col.start_after *convert_cursor(clause.start_after)
            elsif clause.end_at
              col.end_at *convert_cursor(clause.end_at)
            elsif clause.end_before
              col.end_before *convert_cursor(clause.end_before)
            else
              raise "Unexpected Clause state: #{clause.inspect}"
            end
    end
    col.query
  end

  def convert_cursor clause_val
    if clause_val.doc_snapshot
      return [doc_snap_from_path_and_json_data(clause_val.doc_snapshot.path, clause_val.doc_snapshot.json_data)]
    end

    clause_val.json_values.map {|x| data_from_json x }
  end

  def convert_field_path clause_val
    firestore.field_path clause_val.path.field
  end
end

file = File.open "conformance/test-suite.binproto", "rb"
test_suite = Tests::TestSuite.decode file.read

failing_tests = {
    get: [],
    create: [],
    set: [],
    update: [62, 65, 66],
    update_paths: [79, 80, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 100, 102],
    delete: [],
    query: [],
    listen: [],

}

test_suite.tests.each_with_index do |wrapper, i|
  next if failing_tests[wrapper.test].include?(i)

  case wrapper.test
    when :get
      next # Google::Firestore::V1beta1::GetDocumentRequest is not used.
    when :create
      ConformanceCreate.build_test_for wrapper.description, wrapper.create, i
    when :set
      ConformanceSet.build_test_for wrapper.description, wrapper.set, i
    when :update
      ConformanceUpdate.build_test_for wrapper.description, wrapper.update, i
    when :update_paths
      ConformanceUpdatePaths.build_test_for wrapper.description, wrapper.update_paths, i
    when :delete
      ConformanceDelete.build_test_for wrapper.description, wrapper.delete, i
    when :query
      ConformanceQuery.build_test_for wrapper.description, wrapper.query, i
    when :listen
      next
      # TODO
    else
      raise "Unexpected test: #{wrapper.inspect}"
  end
end


##
# Failures
#
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

# 91 actual does not include "b" in document mask
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"a"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["a", "b"]>, current_document: <Google::Firestore::V1beta1::Precondition: exists: true, update_time: nil>, transform: nil>, <Google::Firestore::V1beta1::Write: update: nil, delete: "", update_mask: nil, current_document: nil, transform: <Google::Firestore::V1beta1::DocumentTransform: document: "projects/projectID/databases/(default)/documents/C/d", field_transforms: [<Google::Firestore::V1beta1::DocumentTransform::FieldTransform: field_path: "b.c", set_to_server_value: :REQUEST_TIME>]>>], transaction: "">
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"a"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["a"]>, current_document: <Google::Firestore::V1beta1::Precondition: exists: true, update_time: nil>, transform: nil>, <Google::Firestore::V1beta1::Write: update: nil, delete: "", update_mask: nil, current_document: nil, transform: <Google::Firestore::V1beta1::DocumentTransform: document: "projects/projectID/databases/(default)/documents/C/d", field_transforms: [<Google::Firestore::V1beta1::DocumentTransform::FieldTransform: field_path: "b.c", set_to_server_value: :REQUEST_TIME>]>>], transaction: "">

# 92 actual does not include "c" in document mask
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"a"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["a", "c"]>, current_document: <Google::Firestore::V1beta1::Precondition: exists: true, update_time: nil>, transform: nil>, <Google::Firestore::V1beta1::Write: update: nil, delete: "", update_mask: nil, current_document: nil, transform: <Google::Firestore::V1beta1::DocumentTransform: document: "projects/projectID/databases/(default)/documents/C/d", field_transforms: [<Google::Firestore::V1beta1::DocumentTransform::FieldTransform: field_path: "b", set_to_server_value: :REQUEST_TIME>, <Google::Firestore::V1beta1::DocumentTransform::FieldTransform: field_path: "c.d", set_to_server_value: :REQUEST_TIME>]>>], transaction: "">
#<Google::Firestore::V1beta1::CommitRequest: database: "projects/projectID/databases/(default)", writes: [<Google::Firestore::V1beta1::Write: update: <Google::Firestore::V1beta1::Document: name: "projects/projectID/databases/(default)/documents/C/d", fields: {"a"=><Google::Firestore::V1beta1::Value: boolean_value: false, integer_value: 1, double_value: 0.0, reference_value: "", map_value: nil, geo_point_value: nil, array_value: nil, timestamp_value: nil, null_value: :NULL_VALUE, string_value: "", bytes_value: "">}, create_time: nil, update_time: nil>, delete: "", update_mask: <Google::Firestore::V1beta1::DocumentMask: field_paths: ["a"]>, current_document: <Google::Firestore::V1beta1::Precondition: exists: true, update_time: nil>, transform: nil>, <Google::Firestore::V1beta1::Write: update: nil, delete: "", update_mask: nil, current_document: nil, transform: <Google::Firestore::V1beta1::DocumentTransform: document: "projects/projectID/databases/(default)/documents/C/d", field_transforms: [<Google::Firestore::V1beta1::DocumentTransform::FieldTransform: field_path: "b", set_to_server_value: :REQUEST_TIME>, <Google::Firestore::V1beta1::DocumentTransform::FieldTransform: field_path: "c.d", set_to_server_value: :REQUEST_TIME>]>>], transaction: "">

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
