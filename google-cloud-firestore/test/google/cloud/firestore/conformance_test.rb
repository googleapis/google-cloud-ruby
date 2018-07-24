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

  def doc_data_from_json data_json
    convert_values JSON.parse data_json
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

  def self.build_test_for wrapper
    define_method("test_: #{wrapper.description}") do
      doc_ref = doc_ref_from_path wrapper.create.doc_ref_path
      data = doc_data_from_json wrapper.create.json_data

      if wrapper.create.is_error
        expect do
          doc_ref.create data
        end.must_raise ArgumentError
      else
        firestore_mock.expect :commit, commit_resp, [wrapper.create.request.database, wrapper.create.request.writes, options: default_options]

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

  def self.build_test_for wrapper
    define_method("test_: #{wrapper.description}") do
      doc_ref = doc_ref_from_path wrapper.set.doc_ref_path
      data = doc_data_from_json wrapper.set.json_data

      if wrapper.set.is_error
        expect do
          doc_ref.create data
        end.must_raise ArgumentError
      else
        firestore_mock.expect :commit, commit_resp, [wrapper.set.request.database, wrapper.set.request.writes, options: default_options]

        merge = if wrapper.set.option && wrapper.set.option.all
                  true
                elsif wrapper.set.option && !wrapper.set.option.fields.empty?
                  wrapper.set.option.fields.map do |fp|
                    Google::Cloud::Firestore::FieldPath.new fp.field
                  end
                end

        doc_ref.set data, merge: merge
      end
    end
  end
end

  #   #next
  #   client_mocks firestore_execute_mock
  #   puts test.request.inspect
  #   firestore_execute_mock.expect :call, firestore_execute_mock, [test.request, Hash]
  #   firestore_execute_mock.expect :execute, OpenStruct.new(write_results: nil), []
  #
  #   Google::Gax::Grpc.stub :create_stub, firestore_execute_mock do
  #
  #     gax_client = Google::Cloud::Firestore::V1beta1::FirestoreClient.new(
  #         credentials: credentials,
  #         lib_name: "gccl",
  #         lib_version: Google::Cloud::Firestore::VERSION
  #     )
  #     firestore.service.instance_variable_set :@firestore, gax_client
  #     document_path = test.doc_ref_path.split("/documents/")[1]
  #     data = JSON.parse(test.json_data)
  #     convert_values data
  #
  #     merge = if test.option && test.option.all
  #               true
  #             elsif test.option && !test.option.fields.empty?
  #               test.option.fields.map do |fp|
  #                 Google::Cloud::Firestore::FieldPath.new fp.field
  #               end
  #             end
  #     puts "merge: #{merge}"
  #
  #     # API under test
  #     firestore.batch do |b|
  #       b.set document_path, data, merge: merge
  #     end
  #   end
  #   firestore_execute_mock.verify

file = File.open "conformance/test-suite.binproto", "rb"
test_suite = Tests::TestSuite.decode file.read

test_suite.tests.each_with_index do |wrapper, i|

  #next unless [:query].include?(wrapper.test)
  #next unless (77..102).include?(i)
  # next unless [9].include?(i)

  case wrapper.test
    when :get
      puts "skip - Google::Firestore::V1beta1::GetDocumentRequest is not used."
    when :create
      ConformanceCreate.build_test_for wrapper
    when :set
      ConformanceSet.build_test_for wrapper


  # when :update
  #   #next
  #   client_mocks firestore_execute_mock
  #   puts test.request.inspect
  #   firestore_execute_mock.expect :call, firestore_execute_mock, [test.request, Hash]
  #   firestore_execute_mock.expect :execute, OpenStruct.new(write_results: nil), []
  #
  #   Google::Gax::Grpc.stub :create_stub, firestore_execute_mock do
  #
  #     gax_client = Google::Cloud::Firestore::V1beta1::FirestoreClient.new(
  #         credentials: credentials,
  #         lib_name: "gccl",
  #         lib_version: Google::Cloud::Firestore::VERSION
  #     )
  #     firestore.service.instance_variable_set :@firestore, gax_client
  #     document_path = test.doc_ref_path.split("/documents/")[1]
  #     data = JSON.parse(test.json_data)
  #     convert_values data
  #
  #     if test.precondition && test.precondition.update_time
  #       update_time = Time.at(test.precondition.update_time.seconds)
  #     end
  #
  #     # API under test
  #     firestore.batch do |b|
  #       b.update document_path, data, update_time: update_time
  #     end
  #   end
  #   firestore_execute_mock.verify
  # when :update_paths
  #   #next
  #   client_mocks firestore_execute_mock
  #   puts test.request.inspect
  #   firestore_execute_mock.expect :call, firestore_execute_mock, [test.request, Hash]
  #   firestore_execute_mock.expect :execute, OpenStruct.new(write_results: nil), []
  #
  #   Google::Gax::Grpc.stub :create_stub, firestore_execute_mock do
  #
  #     gax_client = Google::Cloud::Firestore::V1beta1::FirestoreClient.new(
  #         credentials: credentials,
  #         lib_name: "gccl",
  #         lib_version: Google::Cloud::Firestore::VERSION
  #     )
  #     firestore.service.instance_variable_set :@firestore, gax_client
  #     document_path = test.doc_ref_path.split("/documents/")[1]
  #
  #     keys = test.field_paths.map do |fp|
  #       firestore.field_path fp.field
  #     end
  #     values = test.json_values.map {|v| JSON.parse v }
  #     data = Hash[keys.zip(values)]
  #     puts "#{data.inspect}"
  #     convert_values data
  #     puts "#{data.inspect}"
  #
  #     if test.precondition && test.precondition.update_time
  #       update_time = Time.at(test.precondition.update_time.seconds)
  #     end
  #
  #     # API under test
  #     firestore.batch do |b|
  #       b.update document_path, data, update_time: update_time
  #     end
  #   end
  #   firestore_execute_mock.verify
  # when :delete
  #
  #   client_mocks firestore_execute_mock
  #   puts test.inspect
  #   firestore_execute_mock.expect :call, firestore_execute_mock, [test.request, Hash]
  #   firestore_execute_mock.expect :execute, OpenStruct.new(write_results: nil), []
  #   opts = {}
  #   if test.precondition && test.precondition.exists
  #     opts[:exists] = test.precondition.exists
  #   end
  #   if test.precondition && test.precondition.update_time
  #     opts[:update_time] = Time.at(test.precondition.update_time.seconds)
  #   end
  #   Google::Gax::Grpc.stub :create_stub, firestore_execute_mock do
  #
  #     gax_client = Google::Cloud::Firestore::V1beta1::FirestoreClient.new(
  #         credentials: credentials,
  #         lib_name: "gccl",
  #         lib_version: Google::Cloud::Firestore::VERSION
  #     )
  #     firestore.service.instance_variable_set :@firestore, gax_client
  #     document_path = test.doc_ref_path.split("/documents/")[1]
  #
  #     # API under test
  #     firestore.batch do |b|
  #       b.delete document_path, opts
  #     end
  #   end
  #   firestore_execute_mock.verify
  # when :query
  #   next
  #   puts test.inspect
  #   query = build_query test, get_collection_reference(test.coll_path)
  #   assert_equal test.query, query
  # when :listen
  #   next
  #   # TODO
  # else
  #   raise "Unexpected test: #{test_name}"
  end
end
