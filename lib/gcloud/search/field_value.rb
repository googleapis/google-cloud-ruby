#--
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

module Gcloud
  module Search
    ##
    # = FieldValue
    #
    # FieldValue is used to represent a value that belongs to a field. (See
    # Fields and FieldValues)
    #
    # A field value must have a type. A value that is a Numeric will default to
    # `:number`, while a DateTime will default to `:timestamp`. If a type is not
    # provided it will be determined by looking at the value.
    #
    # String values (text, html, atom) can also specify a lang value, which is
    # an {ISO 639-1
    # code}[https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes].
    #
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   search = gcloud.search
    #   index = search.index "products"
    #
    #   document = index.document "product-sku-000001"
    #   puts "The document description is:"
    #   document["description"].each do |value|
    #     puts "* #{value.value} (#{value.type}) [#{value.lang}]"
    #   end
    #
    # For more information see {Documents and
    # fields}[https://cloud.google.com/search/documents_indexes].
    #
    class FieldValue
      attr_reader :value, :type, :lang, :name

      # rubocop:disable Metrics/LineLength
      # Disabled because there are links in the docs that are long.

      ##
      # Create a new FieldValue object.
      #
      # === Parameters
      #
      # +value+::
      #   The value to add to the field. (+String+ or +Datetime+ or +Float+)
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:type]</code>::
      #   The type of the field value. A field can have multiple values with
      #   same or different types; however, it cannot have multiple Timestamp or
      #   number values. (+Symbol+)
      #
      #   The following values are supported:
      #   * +:text+ - The value is a string with maximum length 1024**2
      #     characters.
      #   * +:html+ - The value is an HTML-formatted string with maximum length
      #     1024**2 characters.
      #   * +:atom+ - The value is a string with maximum length 500 characters.
      #   * +:geo+ - The value is a point on earth described by latitude and
      #     longitude coordinates, represented in string with any of the listed
      #     {ways of writing
      #     coordinates}[http://en.wikipedia.org/wiki/Geographic_coordinate_conversion].
      #   * +:timestamp+ - The value is a +DateTime+.
      #   * +:number+ - The value is a +Numeric+ between -2,147,483,647 and
      #     2,147,483,647. The value will be stored as a double precision
      #     floating point value in Cloud Search.
      # <code>options[:lang]</code>::
      #   The language of a string value. Must be a valid {ISO 639-1
      #   code}[https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes].
      #   (+String+)
      # <code>options[:name]</code>::
      #   The name of the field. New values will be configured with this name.
      #   (+String+)
      #
      def initialize value, options = {} #:nodoc:
        @value = value
        @type = nil
        @type = options[:type].to_s.downcase.to_sym if options[:type]
        @type = infer_type if @type.nil?
        @lang = options[:lang] if string_type?
        @name = options[:name]
      end

      # rubocop:enable Metrics/LineLength

      ##
      # Determines if the value a string type. The value is text or html or atom
      # (or default).
      def string_type?
        [:atom, :default, :html, :text].include? type
      end

      ##
      # Create a new FieldValue instance from a value Hash.
      def self.from_raw field_value, name = nil #:nodoc:
        value = field_value["stringValue"]
        type = field_value["stringFormat"]
        if field_value["timestampValue"]
          value = DateTime.parse(field_value["timestampValue"])
          type = :timestamp
        elsif field_value["geoValue"]
          value = field_value["geoValue"]
          type = :geo
        elsif field_value["numberValue"]
          value = Float(field_value["numberValue"])
          type = :number
        end
        fail "No value found in #{raw_field.inspect}" if value.nil?
        new value, type: type, lang: field_value["lang"], name: name
      end

      ##
      # Create a raw Hash object containing the field value.
      def to_raw #:nodoc:
        case type
        when :atom, :default, :html, :text
          {
            "stringFormat" => type.to_s.upcase,
            "lang" => lang,
            "stringValue" => value.to_s
          }.delete_if { |_, v| v.nil? }
        when :geo
          { "geoValue" => value.to_s }
        when :number
          { "numberValue" => value.to_f }
        when :timestamp
          { "timestampValue" => value.rfc3339 }
        end
      end

      protected

      def infer_type #:nodoc:
        if value.respond_to?(:rfc3339)
          :timestamp
        elsif value.is_a? Numeric
          :number
        else
          :default
        end
      end
    end
  end
end
