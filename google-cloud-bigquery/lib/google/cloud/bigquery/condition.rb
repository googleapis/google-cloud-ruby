# Copyright 2025 Google LLC
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

require "google/apis/bigquery_v2"

module Google
  module Cloud
    module Bigquery
      ##
      # # Condition
      #
      # Represents a textual expression in the Common Expression Language (CEL) syntax.
      # CEL is a C-like expression language. The syntax and semantics of CEL are documented
      # at https://github.com/google/cel-spec
      #
      # Used to define condition for {Dataset::Access} rules
      #
      class Condition
        ##
        # Returns the textual representation of an expression in Common Expression Language syntax.
        #
        # @return [String] The expression of the condition.
        #
        # @example
        #   condition = Google::Cloud::Bigquery::Condition.new(
        #     "resource.name.startsWith('projects/my-project')"
        #   )
        #   puts condition.expression # => "resource.name.startsWith('projects/my-project')"
        #
        def expression
          @expression
        end

        ##
        # Sets the textual representation of an expression in Common Expression Language syntax.
        #
        # @param [String] val The expression to set.
        #
        # @raise [ArgumentError] if the expression is nil or empty.
        #
        # @example
        #   condition = Google::Cloud::Bigquery::Condition.new(
        #     "resource.name.startsWith('projects/my-project')"
        #   )
        #   condition.expression = "document.summary.size() < 100"
        #
        def expression= val
          if val.nil? || val.strip.empty?
            raise ArgumentError, "Expression cannot be nil or empty"
          end
          @expression = val
        end

        ##
        # Returns the optional description of the expression. This is a longer text which describes
        # the expression, e.g. when hovered over it in a UI.
        #
        # @return [String, nil] The description of the condition. nil if not set.
        #
        # @example
        #   condition = Google::Cloud::Bigquery::Condition.new(
        #     "document.summary.size() < 100",
        #     description: "Checks if summary is less than 100 chars"
        #   )
        #   puts condition.description # => "Checks if summary is less than 100 chars"
        #
        def description
          @description
        end

        ##
        # Sets the optional description of the expression. This is a longer text which describes
        # the expression, e.g. when hovered over it in a UI.
        #
        # @param [String, nil] val The description to set. nil to unset.
        #
        # @example
        #   condition = Google::Cloud::Bigquery::Condition.new(
        #     "document.summary.size() < 100"
        #   )
        #   condition.description = "Checks if summary is less than 100 chars"
        #
        def description= val
          @description = val
        end

        ##
        # Returns the optional string indicating the location of the expression for error reporting,
        # e.g. a file name and a position in the file.
        #
        # @return [String, nil] The location of the condition. nil if not set.
        #
        # @example
        #   condition = Google::Cloud::Bigquery::Condition.new(
        #     "document.summary.size() < 100",
        #     location: "document/summary"
        #   )
        #   puts condition.location # => "document/summary"
        #
        def location
          @location
        end

        ##
        # Sets the optional string indicating the location of the expression for error reporting,
        # e.g. a file name and a position in the file.
        #
        # @param [String, nil] val The location to set. nil to unset.
        #
        # @example
        #   condition = Google::Cloud::Bigquery::Condition.new(
        #     "document.summary.size() < 100"
        #   )
        #   condition.location = "document/summary"
        #
        def location= val
          @location = val
        end

        ##
        # Returns the optional title for the expression, i.e. a short string describing its purpose.
        # This can be used e.g. in UIs which allow to enter the expression.
        #
        # @return [String, nil] The title of the condition. nil if not set.
        #
        # @example
        #   condition = Google::Cloud::Bigquery::Condition.new(
        #     "document.summary.size() < 100",
        #     title: "Summary size limit"
        #   )
        #   puts condition.title # => "Summary size limit"
        #
        def title
          @title
        end

        ##
        # Sets the optional title for the expression, i.e. a short string describing its purpose.
        # This can be used e.g. in UIs which allow to enter the expression.
        #
        # @param [String, nil] val The title to set. nil to unset.
        #
        # @example
        #   condition = Google::Cloud::Bigquery::Condition.new(
        #     "document.summary.size() < 100"
        #   )
        #   condition.title = "Summary size limit"
        #
        def title= val
          @title = val
        end

        ##
        # Create a new Condition object.
        #
        # @param [String] expression The expression in CEL syntax.
        # @param [String] description Optional description of the expression.
        # @param [String] location Optional location of the expression for error reporting.
        # @param [String] title Optional title for the expression.
        #
        # @raise [ArgumentError] if expression is nil or empty.
        #
        # @example
        #   condition = Google::Cloud::Bigquery::Condition.new(
        #     "document.summary.size() < 100",
        #     description: "Determines if a summary is less than 100 chars",
        #     location: "document/summary",
        #     title: "Summary size limit"
        #   )
        #
        # @see https://cloud.google.com/bigquery/docs/reference/auditlogs/rest/Shared.Types/Expr
        #
        def initialize expression, description: nil, location: nil, title: nil
          if expression.nil? || expression.strip.empty?
            raise ArgumentError, "Expression cannot be nil or empty"
          end
          @expression = expression
          @description = description
          @location = location
          @title = title
        end

        ##
        # @private Convert the Condition object to a Google API Client object.
        #
        # @return [Google::Apis::BigqueryV2::Expr] The Google API Client object representing the condition.
        #
        # @example
        #   condition = Google::Cloud::Bigquery::Condition.new(
        #     "resource.name.startsWith('projects/my-project')"
        #   )
        #   gapi_condition = condition.to_gapi
        #
        # @see https://cloud.google.com/bigquery/docs/reference/auditlogs/rest/Shared.Types/Expr
        #
        def to_gapi
          gapi = Google::Apis::BigqueryV2::Expr.new
          gapi.description = @description unless @description.nil?
          gapi.expression = @expression
          gapi.location = @location unless @location.nil?
          gapi.title = @title unless @title.nil?
          gapi
        end
      end
    end
  end
end
