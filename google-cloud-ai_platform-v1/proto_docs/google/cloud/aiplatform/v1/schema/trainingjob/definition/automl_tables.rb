# frozen_string_literal: true

# Copyright 2022 Google LLC
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

# Auto-generated by gapic-generator-ruby. DO NOT EDIT!


module Google
  module Cloud
    module AIPlatform
      module V1
        module Schema
          module TrainingJob
            module Definition
              # A TrainingJob that trains and uploads an AutoML Tables Model.
              # @!attribute [rw] inputs
              #   @return [::Google::Cloud::AIPlatform::V1::Schema::TrainingJob::Definition::AutoMlTablesInputs]
              #     The input parameters of this TrainingJob.
              # @!attribute [rw] metadata
              #   @return [::Google::Cloud::AIPlatform::V1::Schema::TrainingJob::Definition::AutoMlTablesMetadata]
              #     The metadata information.
              class AutoMlTables
                include ::Google::Protobuf::MessageExts
                extend ::Google::Protobuf::MessageExts::ClassMethods
              end

              # @!attribute [rw] optimization_objective_recall_value
              #   @return [::Float]
              #     Required when optimization_objective is "maximize-precision-at-recall".
              #     Must be between 0 and 1, inclusive.
              #
              #     Note: The following fields are mutually exclusive: `optimization_objective_recall_value`, `optimization_objective_precision_value`. If a field in that set is populated, all other fields in the set will automatically be cleared.
              # @!attribute [rw] optimization_objective_precision_value
              #   @return [::Float]
              #     Required when optimization_objective is "maximize-recall-at-precision".
              #     Must be between 0 and 1, inclusive.
              #
              #     Note: The following fields are mutually exclusive: `optimization_objective_precision_value`, `optimization_objective_recall_value`. If a field in that set is populated, all other fields in the set will automatically be cleared.
              # @!attribute [rw] prediction_type
              #   @return [::String]
              #     The type of prediction the Model is to produce.
              #       "classification" - Predict one out of multiple target values is
              #                          picked for each row.
              #       "regression" - Predict a value based on its relation to other values.
              #                      This type is available only to columns that contain
              #                      semantically numeric values, i.e. integers or floating
              #                      point number, even if stored as e.g. strings.
              # @!attribute [rw] target_column
              #   @return [::String]
              #     The column name of the target column that the model is to predict.
              # @!attribute [rw] transformations
              #   @return [::Array<::Google::Cloud::AIPlatform::V1::Schema::TrainingJob::Definition::AutoMlTablesInputs::Transformation>]
              #     Each transformation will apply transform function to given input column.
              #     And the result will be used for training.
              #     When creating transformation for BigQuery Struct column, the column should
              #     be flattened using "." as the delimiter.
              # @!attribute [rw] optimization_objective
              #   @return [::String]
              #     Objective function the model is optimizing towards. The training process
              #     creates a model that maximizes/minimizes the value of the objective
              #     function over the validation set.
              #
              #     The supported optimization objectives depend on the prediction type.
              #     If the field is not set, a default objective function is used.
              #
              #     classification (binary):
              #       "maximize-au-roc" (default) - Maximize the area under the receiver
              #                                     operating characteristic (ROC) curve.
              #       "minimize-log-loss" - Minimize log loss.
              #       "maximize-au-prc" - Maximize the area under the precision-recall curve.
              #       "maximize-precision-at-recall" - Maximize precision for a specified
              #                                       recall value.
              #       "maximize-recall-at-precision" - Maximize recall for a specified
              #                                        precision value.
              #
              #     classification (multi-class):
              #       "minimize-log-loss" (default) - Minimize log loss.
              #
              #     regression:
              #       "minimize-rmse" (default) - Minimize root-mean-squared error (RMSE).
              #       "minimize-mae" - Minimize mean-absolute error (MAE).
              #       "minimize-rmsle" - Minimize root-mean-squared log error (RMSLE).
              # @!attribute [rw] train_budget_milli_node_hours
              #   @return [::Integer]
              #     Required. The train budget of creating this model, expressed in milli node
              #     hours i.e. 1,000 value in this field means 1 node hour.
              #
              #     The training cost of the model will not exceed this budget. The final cost
              #     will be attempted to be close to the budget, though may end up being (even)
              #     noticeably smaller - at the backend's discretion. This especially may
              #     happen when further model training ceases to provide any improvements.
              #
              #     If the budget is set to a value known to be insufficient to train a
              #     model for the given dataset, the training won't be attempted and
              #     will error.
              #
              #     The train budget must be between 1,000 and 72,000 milli node hours,
              #     inclusive.
              # @!attribute [rw] disable_early_stopping
              #   @return [::Boolean]
              #     Use the entire training budget. This disables the early stopping feature.
              #     By default, the early stopping feature is enabled, which means that AutoML
              #     Tables might stop training before the entire training budget has been used.
              # @!attribute [rw] weight_column_name
              #   @return [::String]
              #     Column name that should be used as the weight column.
              #     Higher values in this column give more importance to the row
              #     during model training. The column must have numeric values between 0 and
              #     10000 inclusively; 0 means the row is ignored for training. If weight
              #     column field is not set, then all rows are assumed to have equal weight
              #     of 1.
              # @!attribute [rw] export_evaluated_data_items_config
              #   @return [::Google::Cloud::AIPlatform::V1::Schema::TrainingJob::Definition::ExportEvaluatedDataItemsConfig]
              #     Configuration for exporting test set predictions to a BigQuery table. If
              #     this configuration is absent, then the export is not performed.
              # @!attribute [rw] additional_experiments
              #   @return [::Array<::String>]
              #     Additional experiment flags for the Tables training pipeline.
              class AutoMlTablesInputs
                include ::Google::Protobuf::MessageExts
                extend ::Google::Protobuf::MessageExts::ClassMethods

                # @!attribute [rw] auto
                #   @return [::Google::Cloud::AIPlatform::V1::Schema::TrainingJob::Definition::AutoMlTablesInputs::Transformation::AutoTransformation]
                #     Note: The following fields are mutually exclusive: `auto`, `numeric`, `categorical`, `timestamp`, `text`, `repeated_numeric`, `repeated_categorical`, `repeated_text`. If a field in that set is populated, all other fields in the set will automatically be cleared.
                # @!attribute [rw] numeric
                #   @return [::Google::Cloud::AIPlatform::V1::Schema::TrainingJob::Definition::AutoMlTablesInputs::Transformation::NumericTransformation]
                #     Note: The following fields are mutually exclusive: `numeric`, `auto`, `categorical`, `timestamp`, `text`, `repeated_numeric`, `repeated_categorical`, `repeated_text`. If a field in that set is populated, all other fields in the set will automatically be cleared.
                # @!attribute [rw] categorical
                #   @return [::Google::Cloud::AIPlatform::V1::Schema::TrainingJob::Definition::AutoMlTablesInputs::Transformation::CategoricalTransformation]
                #     Note: The following fields are mutually exclusive: `categorical`, `auto`, `numeric`, `timestamp`, `text`, `repeated_numeric`, `repeated_categorical`, `repeated_text`. If a field in that set is populated, all other fields in the set will automatically be cleared.
                # @!attribute [rw] timestamp
                #   @return [::Google::Cloud::AIPlatform::V1::Schema::TrainingJob::Definition::AutoMlTablesInputs::Transformation::TimestampTransformation]
                #     Note: The following fields are mutually exclusive: `timestamp`, `auto`, `numeric`, `categorical`, `text`, `repeated_numeric`, `repeated_categorical`, `repeated_text`. If a field in that set is populated, all other fields in the set will automatically be cleared.
                # @!attribute [rw] text
                #   @return [::Google::Cloud::AIPlatform::V1::Schema::TrainingJob::Definition::AutoMlTablesInputs::Transformation::TextTransformation]
                #     Note: The following fields are mutually exclusive: `text`, `auto`, `numeric`, `categorical`, `timestamp`, `repeated_numeric`, `repeated_categorical`, `repeated_text`. If a field in that set is populated, all other fields in the set will automatically be cleared.
                # @!attribute [rw] repeated_numeric
                #   @return [::Google::Cloud::AIPlatform::V1::Schema::TrainingJob::Definition::AutoMlTablesInputs::Transformation::NumericArrayTransformation]
                #     Note: The following fields are mutually exclusive: `repeated_numeric`, `auto`, `numeric`, `categorical`, `timestamp`, `text`, `repeated_categorical`, `repeated_text`. If a field in that set is populated, all other fields in the set will automatically be cleared.
                # @!attribute [rw] repeated_categorical
                #   @return [::Google::Cloud::AIPlatform::V1::Schema::TrainingJob::Definition::AutoMlTablesInputs::Transformation::CategoricalArrayTransformation]
                #     Note: The following fields are mutually exclusive: `repeated_categorical`, `auto`, `numeric`, `categorical`, `timestamp`, `text`, `repeated_numeric`, `repeated_text`. If a field in that set is populated, all other fields in the set will automatically be cleared.
                # @!attribute [rw] repeated_text
                #   @return [::Google::Cloud::AIPlatform::V1::Schema::TrainingJob::Definition::AutoMlTablesInputs::Transformation::TextArrayTransformation]
                #     Note: The following fields are mutually exclusive: `repeated_text`, `auto`, `numeric`, `categorical`, `timestamp`, `text`, `repeated_numeric`, `repeated_categorical`. If a field in that set is populated, all other fields in the set will automatically be cleared.
                class Transformation
                  include ::Google::Protobuf::MessageExts
                  extend ::Google::Protobuf::MessageExts::ClassMethods

                  # Training pipeline will infer the proper transformation based on the
                  # statistic of dataset.
                  # @!attribute [rw] column_name
                  #   @return [::String]
                  class AutoTransformation
                    include ::Google::Protobuf::MessageExts
                    extend ::Google::Protobuf::MessageExts::ClassMethods
                  end

                  # Training pipeline will perform following transformation functions.
                  # *  The value converted to float32.
                  # *  The z_score of the value.
                  # *  log(value+1) when the value is greater than or equal to 0. Otherwise,
                  #    this transformation is not applied and the value is considered a
                  #    missing value.
                  # *  z_score of log(value+1) when the value is greater than or equal to 0.
                  #    Otherwise, this transformation is not applied and the value is
                  #    considered a missing value.
                  # *  A boolean value that indicates whether the value is valid.
                  # @!attribute [rw] column_name
                  #   @return [::String]
                  # @!attribute [rw] invalid_values_allowed
                  #   @return [::Boolean]
                  #     If invalid values is allowed, the training pipeline will create a
                  #     boolean feature that indicated whether the value is valid.
                  #     Otherwise, the training pipeline will discard the input row from
                  #     trainining data.
                  class NumericTransformation
                    include ::Google::Protobuf::MessageExts
                    extend ::Google::Protobuf::MessageExts::ClassMethods
                  end

                  # Training pipeline will perform following transformation functions.
                  # *  The categorical string as is--no change to case, punctuation,
                  # spelling,
                  #    tense, and so on.
                  # *  Convert the category name to a dictionary lookup index and generate an
                  #    embedding for each index.
                  # *  Categories that appear less than 5 times in the training dataset are
                  #    treated as the "unknown" category. The "unknown" category gets its own
                  #    special lookup index and resulting embedding.
                  # @!attribute [rw] column_name
                  #   @return [::String]
                  class CategoricalTransformation
                    include ::Google::Protobuf::MessageExts
                    extend ::Google::Protobuf::MessageExts::ClassMethods
                  end

                  # Training pipeline will perform following transformation functions.
                  # *  Apply the transformation functions for Numerical columns.
                  # *  Determine the year, month, day,and weekday. Treat each value from the
                  # *  timestamp as a Categorical column.
                  # *  Invalid numerical values (for example, values that fall outside of a
                  #    typical timestamp range, or are extreme values) receive no special
                  #    treatment and are not removed.
                  # @!attribute [rw] column_name
                  #   @return [::String]
                  # @!attribute [rw] time_format
                  #   @return [::String]
                  #     The format in which that time field is expressed. The time_format must
                  #     either be one of:
                  #     * `unix-seconds`
                  #     * `unix-milliseconds`
                  #     * `unix-microseconds`
                  #     * `unix-nanoseconds`
                  #     (for respectively number of seconds, milliseconds, microseconds and
                  #     nanoseconds since start of the Unix epoch);
                  #     or be written in `strftime` syntax. If time_format is not set, then the
                  #     default format is RFC 3339 `date-time` format, where
                  #     `time-offset` = `"Z"` (e.g. 1985-04-12T23:20:50.52Z)
                  # @!attribute [rw] invalid_values_allowed
                  #   @return [::Boolean]
                  #     If invalid values is allowed, the training pipeline will create a
                  #     boolean feature that indicated whether the value is valid.
                  #     Otherwise, the training pipeline will discard the input row from
                  #     trainining data.
                  class TimestampTransformation
                    include ::Google::Protobuf::MessageExts
                    extend ::Google::Protobuf::MessageExts::ClassMethods
                  end

                  # Training pipeline will perform following transformation functions.
                  # *  The text as is--no change to case, punctuation, spelling, tense, and
                  # so
                  #    on.
                  # *  Tokenize text to words. Convert each words to a dictionary lookup
                  # index
                  #    and generate an embedding for each index. Combine the embedding of all
                  #    elements into a single embedding using the mean.
                  # *  Tokenization is based on unicode script boundaries.
                  # *  Missing values get their own lookup index and resulting embedding.
                  # *  Stop-words receive no special treatment and are not removed.
                  # @!attribute [rw] column_name
                  #   @return [::String]
                  class TextTransformation
                    include ::Google::Protobuf::MessageExts
                    extend ::Google::Protobuf::MessageExts::ClassMethods
                  end

                  # Treats the column as numerical array and performs following
                  # transformation functions.
                  # *  All transformations for Numerical types applied to the average of the
                  #    all elements.
                  # *  The average of empty arrays is treated as zero.
                  # @!attribute [rw] column_name
                  #   @return [::String]
                  # @!attribute [rw] invalid_values_allowed
                  #   @return [::Boolean]
                  #     If invalid values is allowed, the training pipeline will create a
                  #     boolean feature that indicated whether the value is valid.
                  #     Otherwise, the training pipeline will discard the input row from
                  #     trainining data.
                  class NumericArrayTransformation
                    include ::Google::Protobuf::MessageExts
                    extend ::Google::Protobuf::MessageExts::ClassMethods
                  end

                  # Treats the column as categorical array and performs following
                  # transformation functions.
                  # *  For each element in the array, convert the category name to a
                  # dictionary
                  #    lookup index and generate an embedding for each index.
                  #    Combine the embedding of all elements into a single embedding using
                  #    the mean.
                  # *  Empty arrays treated as an embedding of zeroes.
                  # @!attribute [rw] column_name
                  #   @return [::String]
                  class CategoricalArrayTransformation
                    include ::Google::Protobuf::MessageExts
                    extend ::Google::Protobuf::MessageExts::ClassMethods
                  end

                  # Treats the column as text array and performs following transformation
                  # functions.
                  # *  Concatenate all text values in the array into a single text value
                  # using
                  #    a space (" ") as a delimiter, and then treat the result as a single
                  #    text value. Apply the transformations for Text columns.
                  # *  Empty arrays treated as an empty text.
                  # @!attribute [rw] column_name
                  #   @return [::String]
                  class TextArrayTransformation
                    include ::Google::Protobuf::MessageExts
                    extend ::Google::Protobuf::MessageExts::ClassMethods
                  end
                end
              end

              # Model metadata specific to AutoML Tables.
              # @!attribute [rw] train_cost_milli_node_hours
              #   @return [::Integer]
              #     Output only. The actual training cost of the model, expressed in milli
              #     node hours, i.e. 1,000 value in this field means 1 node hour. Guaranteed
              #     to not exceed the train budget.
              class AutoMlTablesMetadata
                include ::Google::Protobuf::MessageExts
                extend ::Google::Protobuf::MessageExts::ClassMethods
              end
            end
          end
        end
      end
    end
  end
end
