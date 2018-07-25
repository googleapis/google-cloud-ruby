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

      if test.is_error
        expect do
          doc_ref.set data
        end.must_raise ArgumentError
      else
        firestore_mock.expect :commit, commit_resp, [test.request.database, test.request.writes, options: default_options]

        merge = if test.option && test.option.all
                  true
                elsif test.option && !test.option.fields.empty?
                  test.option.fields.map do |fp|
                    Google::Cloud::Firestore::FieldPath.new fp.field
                  end
                end

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
      query = build_query test, get_collection_reference(test.coll_path)
      assert_equal test.query, query
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
    col.query
  end

  def convert_cursor clause_val
    clause_val.json_values.map {|x| JSON.parse x }
  end

  def convert_field_path clause_val
    clause_val.path.field.first
  end
end

file = File.open "conformance/test-suite.binproto", "rb"
test_suite = Tests::TestSuite.decode file.read

test_suite.tests.each_with_index do |wrapper, i|

  #next unless [:query].include?(wrapper.test)
  #next unless (106..118).include?(i)
  #next unless [107].include?(i)

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
