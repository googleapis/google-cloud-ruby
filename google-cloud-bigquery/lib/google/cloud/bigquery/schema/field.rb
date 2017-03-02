# Copyright 2017 Google Inc. All rights reserved.
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


module Google
  module Cloud
    module Bigquery
      class Schema
        class Field
          # @private
          MODES = %w( NULLABLE REQUIRED REPEATED )

          # @private
          TYPES = %w( STRING INTEGER FLOAT BOOLEAN BYTES TIMESTAMP TIME DATETIME
                      DATE RECORD )

          def initialize name, type, description: nil,
                         mode: :nullable, fields: nil
            @gapi = Google::Apis::BigqueryV2::TableFieldSchema.new
            @gapi.update! name: name
            @gapi.update! type: verify_type(type)
            @gapi.update! description: description if description
            @gapi.update! mode: verify_mode(mode) if mode
            if fields
              @fields = fields
              check_for_changed_fields!
            end
            @original_json = @gapi.to_json
          end

          def name
            @gapi.name
          end

          def name= new_name
            @gapi.update! name: String(new_name)
          end

          def type
            @gapi.type
          end

          def type= new_type
            @gapi.update! type: verify_type(new_type)
          end

          def description
            @gapi.description
          end

          def description= new_description
            @gapi.update! description: new_description
          end

          def mode
            @gapi.mode
          end

          def mode= new_mode
            @gapi.update! mode: verify_mode(new_mode)
          end

          def fields
            @fields ||= Array(@gapi.fields).map { |f| Field.from_gapi f }
          end

          def fields= new_fields
            @fields = new_fields
          end

          ##
          # @private Make sure any fields are saved.
          def check_for_changed_fields!
            return if frozen?
            fields.each(&:check_for_changed_fields!)
            gapi_fields = Array(fields).map(&:to_gapi)
            @gapi.update! fields: gapi_fields
          end

          # @private
          def changed?
            @original_json == to_gapi.to_json
          end

          # @private
          def self.from_gapi gapi
            new("to-be-replaced", "STRING").tap do |f|
              f.instance_variable_set :@gapi, gapi
              f.instance_variable_set :@original_json, gapi.to_json
            end
          end

          # @private
          def to_gapi
            # make sure any changes are saved.
            check_for_changed_fields!
            @gapi
          end

          # @private
          def == other
            return false unless other.is_a? Field
            to_gapi.to_h == other.to_gapi.to_h
          end

          protected

          def verify_type type
            upcase_type = type.to_s.upcase
            unless TYPES.include? upcase_type
              fail ArgumentError,
                   "Type '#{upcase_type}' not found in #{TYPES.inspect}"
            end
            upcase_type
          end

          def verify_mode mode
            upcase_mode = mode.to_s.upcase
            unless MODES.include? upcase_mode
              fail ArgumentError "Unable to determine mode for '#{mode}'"
            end
            upcase_mode
          end
        end
      end
    end
  end
end
