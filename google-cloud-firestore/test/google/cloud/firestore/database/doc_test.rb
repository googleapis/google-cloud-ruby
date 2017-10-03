# Copyright 2017, Google Inc. All rights reserved.
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

require "helper"

describe Google::Cloud::Firestore::Database, :doc, :mock_firestore do
  it "produces a Document reference for a document_path" do
    document_path = "users/mike"

    document = firestore.doc document_path

    document.must_be_kind_of Google::Cloud::Firestore::Document::Reference
    document.project_id.must_equal project
    document.database_id.must_equal "(default)"
    document.document_id.must_equal "mike"
    document.document_path.must_equal document_path
    document.path.must_equal "projects/test/databases/(default)/documents/users/mike"

    document.parent.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    document.parent.project_id.must_equal project
    document.parent.database_id.must_equal "(default)"
    document.parent.collection_id.must_equal "users"
    document.parent.collection_path.must_equal "users"
    document.parent.path.must_equal "projects/test/databases/(default)/documents/users"

    document.context.must_equal firestore
    document.parent.context.must_equal firestore
  end

  it "does not allow a collection_id" do
    error = expect do
      firestore.doc "users"
    end.must_raise ArgumentError
    error.message.must_equal "document_path must refer to a document."
  end

  it "does not allow a collection_path" do
    error = expect do
      firestore.doc "users/mike/messages"
    end.must_raise ArgumentError
    error.message.must_equal "document_path must refer to a document."
  end
end
