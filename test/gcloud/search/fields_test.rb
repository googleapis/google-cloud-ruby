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

require "helper"

##
# A field can have multiple values with same or different types; however, it
# cannot have multiple Timestamp or number values.
describe Gcloud::Search::Fields, :mock_search do

  let(:fields_hash) { random_fields_hash }
  let(:fields) { Gcloud::Search::Fields.new fields_hash }

  it "sets a number field from float" do
    fields["rating"] = 4.5

    field = fields["rating"]
    field.must_be_kind_of Numeric
    field.must_equal 4.5
    field.type.must_equal :number
  end

  it "sets a timestamp field from DateTime" do
    fields["posted_at"] = DateTime.new 2001, 2, 3, 4, 5, 6, '+7'

    field = fields["posted_at"]
    field.must_be_kind_of DateTime
    field.to_s.must_equal "2001-02-03T04:05:06+07:00"
    field.type.must_equal :timestamp
  end

  it "sets a geo field from Hash" do
    latlon = { latitude: 40.58, longitude: "-111.65" }
    fields["destination"] = latlon

    field = fields["destination"]
    field.must_be_kind_of Gcloud::Search::GeoValue
    field.latitude.must_equal 40.58
    field.longitude.must_equal -111.65
    field.to_s.must_equal "40.58, -111.65"
    field.type.must_equal :geo
  end

  it "sets a string default field" do
    fields["serial_number"] = "abc123"

    field = fields["serial_number"]
    field.must_be_kind_of String
    field.must_equal "abc123"
    field.type.must_equal :default
    field.lang.must_be :nil?
  end

  it "returns its rest api representation" do
    fields.to_raw.must_equal fields_hash
  end

  it "returns a number field" do
    field = fields["price"]
    field.must_be_kind_of Numeric
    field.must_equal 24.95
    field.type.must_equal :number
  end

  it "returns a timestamp field" do
    field = fields["since"]
    field.must_be_kind_of DateTime
    field.to_s.must_equal "2015-10-02T15:00:00+00:00"
    field.type.must_equal :timestamp
  end

  it "returns a geoValue field" do
    field = fields["location"]
    field.must_be_kind_of Gcloud::Search::GeoValue
    field.latitude.must_equal -33.857
    field.longitude.must_equal 151.215
    field.type.must_equal :geo
  end

  it "returns a string field with lang and type" do
    field = fields["body"]
    field.must_be_kind_of String
    field.must_equal "gcloud is a client library"
    field.type.must_equal :text
    field.lang.must_equal "en"
  end

  it "returns all values for a field with values" do
    values = fields["body"].values
    values.must_be_kind_of Array
    values[0].must_equal "gcloud is a client library"
    values[0].type.must_equal :text
    values[0].lang.must_equal "en"
    values[1].must_equal "<code>gcloud</code> is a client library"
    values[1].type.must_equal :html
    values[1].lang.must_equal "en"
    values[2].must_equal "<code>gcloud</code> estas kliento biblioteko"
    values[2].type.must_equal :html
    values[2].lang.must_equal "eo"
  end

  def random_fields_hash
    {
      "price" => {
        "values" => [
          {
            "numberValue" => 24.95
          }
        ]
      },
      "since" => {
        "values" => [
          {
            "timestampValue" => "2015-10-02T15:00:00+00:00"
          }
        ]
      },
      "location" => {
        "values" => [
          {
            "geoValue" => "-33.857, 151.215"
          }
        ]
      },
      "body" => {
        "values" => [
          {
            "stringFormat" => "TEXT",
            "lang" => "en",
            "stringValue" => "gcloud is a client library"
          },
          {
            "stringFormat" => "HTML",
            "lang" => "en",
            "stringValue" => "<code>gcloud</code> is a client library"
          },
          {
            "stringFormat" => "HTML",
            "lang" => "eo",
            "stringValue" => "<code>gcloud</code> estas kliento biblioteko"
          }
        ]
      }
    }
  end

end
