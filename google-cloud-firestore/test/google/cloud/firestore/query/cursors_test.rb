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

require "helper"

describe Google::Cloud::Firestore::Query, :cursors, :mock_firestore do
  let(:query) { Google::Cloud::Firestore::Query.start nil, "#{firestore.path}/documents", firestore }
  let(:collection) { Google::Cloud::Firestore::CollectionReference.from_path "projects/#{project}/databases/(default)/documents/C", firestore }
  let(:read_time) { Time.now }

  it "with a document snapshot" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "C")],
      order_by: [
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "__name__"),
          direction: :ASCENDING
        )
      ],
      start_at: Google::Firestore::V1beta1::Cursor.new(
        values: [
          Google::Cloud::Firestore::Convert.raw_to_value(
            Google::Cloud::Firestore::DocumentReference.from_path("projects/projectID/databases/(default)/documents/C/D", firestore)
          )
        ],
        before: true
      )
    )

    doc_snp = document_snapshot("projects/projectID/databases/(default)/documents/C/D", { a: 7, b: 8 })

    generated_query = collection.start_at(doc_snp).query
    generated_query.must_equal expected_query
  end

  it "document snapshot and an equality where clause" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "C")],
      where: Google::Firestore::V1beta1::StructuredQuery::Filter.new(
        field_filter: Google::Firestore::V1beta1::StructuredQuery::FieldFilter.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(
            field_path: "a"
          ),
          op: :EQUAL,
          value: Google::Firestore::V1beta1::Value.new(integer_value: 3)
        )
      ),
      order_by: [
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "__name__"),
          direction: :ASCENDING
        )
      ],
      end_at: Google::Firestore::V1beta1::Cursor.new(
        values: [
          Google::Cloud::Firestore::Convert.raw_to_value(
            Google::Cloud::Firestore::DocumentReference.from_path("projects/projectID/databases/(default)/documents/C/D", firestore)
          )
        ],
        before: false
      )
    )

    doc_snp = document_snapshot("projects/projectID/databases/(default)/documents/C/D", { a: 7, b: 8 })

    generated_query = collection.where(:a, "==", 3).end_at(doc_snp).query
    generated_query.must_equal expected_query
  end

  it "document snapshot and an inequality where clause" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "C")],
      where: Google::Firestore::V1beta1::StructuredQuery::Filter.new(
        field_filter: Google::Firestore::V1beta1::StructuredQuery::FieldFilter.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(
            field_path: "a"
          ),
          op: :LESS_THAN_OR_EQUAL,
          value: Google::Firestore::V1beta1::Value.new(integer_value: 3)
        )
      ),
      order_by: [
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "a"),
          direction: :ASCENDING
        ),
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "__name__"),
          direction: :ASCENDING
        )
      ],
      end_at: Google::Firestore::V1beta1::Cursor.new(
        values: [
          Google::Cloud::Firestore::Convert.raw_to_value(7),
          Google::Cloud::Firestore::Convert.raw_to_value(
            Google::Cloud::Firestore::DocumentReference.from_path("projects/projectID/databases/(default)/documents/C/D", firestore)
          )
        ],
        before: true
      )
    )

    doc_snp = document_snapshot("projects/projectID/databases/(default)/documents/C/D", { a: 7, b: 8 })

    generated_query = collection.where(:a, "<=", 3).end_before(doc_snp).query
    generated_query.must_equal expected_query
  end

  it "doc snapshot, inequality where clause, and existing orderBy clause" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "C")],
      where: Google::Firestore::V1beta1::StructuredQuery::Filter.new(
        field_filter: Google::Firestore::V1beta1::StructuredQuery::FieldFilter.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(
            field_path: "a"
          ),
          op: :LESS_THAN,
          value: Google::Firestore::V1beta1::Value.new(integer_value: 4)
        )
      ),
      order_by: [
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "a"),
          direction: :DESCENDING
        ),
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "__name__"),
          direction: :DESCENDING
        )
      ],
      start_at: Google::Firestore::V1beta1::Cursor.new(
        values: [
          Google::Cloud::Firestore::Convert.raw_to_value(7),
          Google::Cloud::Firestore::Convert.raw_to_value(
            Google::Cloud::Firestore::DocumentReference.from_path("projects/projectID/databases/(default)/documents/C/D", firestore)
          )
        ],
        before: true
      )
    )

    doc_snp = document_snapshot("projects/projectID/databases/(default)/documents/C/D", { a: 7, b: 8 })

    generated_query = collection.order(:a, :desc).where(:a, "<", 4).start_at(doc_snp).query
    generated_query.must_equal expected_query
  end

  it "existing orderBy" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "C")],
      where: Google::Firestore::V1beta1::StructuredQuery::Filter.new(
        field_filter: Google::Firestore::V1beta1::StructuredQuery::FieldFilter.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(
            field_path: "a"
          ),
          op: :LESS_THAN,
          value: Google::Firestore::V1beta1::Value.new(integer_value: 4)
        )
      ),
      order_by: [
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "a"),
          direction: :ASCENDING
        ),
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "b"),
          direction: :DESCENDING
        ),
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "__name__"),
          direction: :DESCENDING
        )
      ],
      start_at: Google::Firestore::V1beta1::Cursor.new(
        values: [
          Google::Cloud::Firestore::Convert.raw_to_value(7),
          Google::Cloud::Firestore::Convert.raw_to_value(8),
          Google::Cloud::Firestore::Convert.raw_to_value(
            Google::Cloud::Firestore::DocumentReference.from_path("projects/projectID/databases/(default)/documents/C/D", firestore)
          )
        ],
        before: false
      )
    )

    doc_snp = document_snapshot("projects/projectID/databases/(default)/documents/C/D", { a: 7, b: 8 })

    generated_query = collection.order(:a).order(:b, :desc).where(:a, "<", 4).start_after(doc_snp).query
    generated_query.must_equal expected_query
  end

  it "existing orderBy __name__" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "C")],
      order_by: [
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "a"),
          direction: :DESCENDING
        ),
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "__name__"),
          direction: :ASCENDING
        )
      ],
      start_at: Google::Firestore::V1beta1::Cursor.new(
        values: [
          Google::Cloud::Firestore::Convert.raw_to_value(7),
          Google::Cloud::Firestore::Convert.raw_to_value(
            Google::Cloud::Firestore::DocumentReference.from_path(
              "projects/projectID/databases/(default)/documents/C/D",
              firestore
            )
          )
        ],
        before: true
      ),
      end_at: Google::Firestore::V1beta1::Cursor.new(
        values: [
          Google::Cloud::Firestore::Convert.raw_to_value(7),
          Google::Cloud::Firestore::Convert.raw_to_value(
            Google::Cloud::Firestore::DocumentReference.from_path(
              "projects/projectID/databases/(default)/documents/C/D",
              firestore
            )
          )
        ]
      )
    )

    doc_snp = document_snapshot("projects/projectID/databases/(default)/documents/C/D", { a: 7, b: 8 })

    generated_query = collection.order(:a, :desc).order(:__name__).start_at(doc_snp).end_at(doc_snp).query
    generated_query.must_equal expected_query
  end

  it "without orderBy" do
    # TODO: I guess we need to raise here?
    expect do
      collection.start_at(7).query
    end.must_raise ArgumentError
  end

  it "StartAt/EndBefore with values" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "C")],
      order_by: [
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "a"),
          direction: :ASCENDING
        )
      ],
      start_at: Google::Firestore::V1beta1::Cursor.new(
        values: [
          Google::Cloud::Firestore::Convert.raw_to_value(7)
        ],
        before: true
      ),
      end_at: Google::Firestore::V1beta1::Cursor.new(
        values: [
          Google::Cloud::Firestore::Convert.raw_to_value(9)
        ],
        before: true
      )
    )

    generated_query = collection.order(:a).start_at(7).end_before(9).query
    generated_query.must_equal expected_query
  end

  it "StartAfter/EndAt with values" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "C")],
      order_by: [
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "a"),
          direction: :ASCENDING
        )
      ],
      start_at: Google::Firestore::V1beta1::Cursor.new(
        values: [
          Google::Cloud::Firestore::Convert.raw_to_value(7)
        ],
        before: false
      ),
      end_at: Google::Firestore::V1beta1::Cursor.new(
        values: [
          Google::Cloud::Firestore::Convert.raw_to_value(9)
        ],
        before: false
      )
    )

    generated_query = collection.order(:a).start_after(7).end_at(9).query
    generated_query.must_equal expected_query
  end

  it "Start/End with two values" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "C")],
      order_by: [
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "a"),
          direction: :ASCENDING
        ),
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "b"),
          direction: :DESCENDING
        )
      ],
      start_at: Google::Firestore::V1beta1::Cursor.new(
        values: [
          Google::Cloud::Firestore::Convert.raw_to_value(7),
          Google::Cloud::Firestore::Convert.raw_to_value(8)
        ],
        before: false
      ),
      end_at: Google::Firestore::V1beta1::Cursor.new(
        values: [
          Google::Cloud::Firestore::Convert.raw_to_value(9),
          Google::Cloud::Firestore::Convert.raw_to_value(10)
        ],
        before: false
      )
    )

    generated_query = collection.order(:a).order(:b, :desc).start_after(7, 8).end_at(9, 10).query
    generated_query.must_equal expected_query
  end

  it "with __name__" do
    # TODO: Looks like we need to create the full path when paired with __name__
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "C")],
      order_by: [
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "__name__"),
          direction: :ASCENDING
        )
      ],
      start_at: Google::Firestore::V1beta1::Cursor.new(
        values: [
          Google::Cloud::Firestore::Convert.raw_to_value(
            Google::Cloud::Firestore::DocumentReference.from_path(
              "projects/projectID/databases/(default)/documents/C/D1",
              firestore
            )
          )
        ],
        before: false
      ),
      end_at: Google::Firestore::V1beta1::Cursor.new(
        values: [
          Google::Cloud::Firestore::Convert.raw_to_value(
            Google::Cloud::Firestore::DocumentReference.from_path(
              "projects/projectID/databases/(default)/documents/C/D2",
              firestore
            )
          )
        ],
        before: true
      )
    )

    generated_query = collection.order(:__name__).start_after("D1").end_before("D2").query
    generated_query.must_equal expected_query
  end

  it "last one wins" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "C")],
      order_by: [
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "a"),
          direction: :ASCENDING
        )
      ],
      start_at: Google::Firestore::V1beta1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value(2)], before: true),
      end_at: Google::Firestore::V1beta1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value(4)], before: true)
    )

    generated_query = collection.order(:a).start_after(1).start_at(2).end_at(3).end_before(4).query
    generated_query.must_equal expected_query
  end

  def document_snapshot path, data
    doc_ref = Google::Cloud::Firestore::DocumentReference.from_path path, firestore
    doc_grpc = Google::Firestore::V1beta1::Document.new(
      name: path,
      fields: Google::Cloud::Firestore::Convert.hash_to_fields(data)
    )
    Google::Cloud::Firestore::DocumentSnapshot.new.tap do |s|
      s.grpc = doc_grpc
      s.instance_variable_set :@ref, doc_ref
    end
  end
end
