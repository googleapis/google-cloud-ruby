# frozen_string_literal: true

# Copyright 2020 Google LLC
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
    module AutoML
      module V1beta1
        # Contains annotation details specific to classification.
        # @!attribute [rw] score
        #   @return [::Float]
        #     Output only. A confidence estimate between 0.0 and 1.0. A higher value
        #     means greater confidence that the annotation is positive. If a user
        #     approves an annotation as negative or positive, the score value remains
        #     unchanged. If a user creates an annotation, the score is 0 for negative or
        #     1 for positive.
        class ClassificationAnnotation
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Contains annotation details specific to video classification.
        # @!attribute [rw] type
        #   @return [::String]
        #     Output only. Expresses the type of video classification. Possible values:
        #
        #     *  `segment` - Classification done on a specified by user
        #            time segment of a video. AnnotationSpec is answered to be present
        #            in that time segment, if it is present in any part of it. The video
        #            ML model evaluations are done only for this type of classification.
        #
        #     *  `shot`- Shot-level classification.
        #            AutoML Video Intelligence determines the boundaries
        #            for each camera shot in the entire segment of the video that user
        #            specified in the request configuration. AutoML Video Intelligence
        #            then returns labels and their confidence scores for each detected
        #            shot, along with the start and end time of the shot.
        #            WARNING: Model evaluation is not done for this classification type,
        #            the quality of it depends on training data, but there are no
        #            metrics provided to describe that quality.
        #
        #     *  `1s_interval` - AutoML Video Intelligence returns labels and their
        #            confidence scores for each second of the entire segment of the video
        #            that user specified in the request configuration.
        #            WARNING: Model evaluation is not done for this classification type,
        #            the quality of it depends on training data, but there are no
        #            metrics provided to describe that quality.
        # @!attribute [rw] classification_annotation
        #   @return [::Google::Cloud::AutoML::V1beta1::ClassificationAnnotation]
        #     Output only . The classification details of this annotation.
        # @!attribute [rw] time_segment
        #   @return [::Google::Cloud::AutoML::V1beta1::TimeSegment]
        #     Output only . The time segment of the video to which the
        #     annotation applies.
        class VideoClassificationAnnotation
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Model evaluation metrics for classification problems.
        # Note: For Video Classification this metrics only describe quality of the
        # Video Classification predictions of "segment_classification" type.
        # @!attribute [rw] au_prc
        #   @return [::Float]
        #     Output only. The Area Under Precision-Recall Curve metric. Micro-averaged
        #     for the overall evaluation.
        # @!attribute [rw] base_au_prc
        #   @deprecated This field is deprecated and may be removed in the next major version update.
        #   @return [::Float]
        #     Output only. The Area Under Precision-Recall Curve metric based on priors.
        #     Micro-averaged for the overall evaluation.
        #     Deprecated.
        # @!attribute [rw] au_roc
        #   @return [::Float]
        #     Output only. The Area Under Receiver Operating Characteristic curve metric.
        #     Micro-averaged for the overall evaluation.
        # @!attribute [rw] log_loss
        #   @return [::Float]
        #     Output only. The Log Loss metric.
        # @!attribute [rw] confidence_metrics_entry
        #   @return [::Array<::Google::Cloud::AutoML::V1beta1::ClassificationEvaluationMetrics::ConfidenceMetricsEntry>]
        #     Output only. Metrics for each confidence_threshold in
        #     0.00,0.05,0.10,...,0.95,0.96,0.97,0.98,0.99 and
        #     position_threshold = INT32_MAX_VALUE.
        #     ROC and precision-recall curves, and other aggregated metrics are derived
        #     from them. The confidence metrics entries may also be supplied for
        #     additional values of position_threshold, but from these no aggregated
        #     metrics are computed.
        # @!attribute [rw] confusion_matrix
        #   @return [::Google::Cloud::AutoML::V1beta1::ClassificationEvaluationMetrics::ConfusionMatrix]
        #     Output only. Confusion matrix of the evaluation.
        #     Only set for MULTICLASS classification problems where number
        #     of labels is no more than 10.
        #     Only set for model level evaluation, not for evaluation per label.
        # @!attribute [rw] annotation_spec_id
        #   @return [::Array<::String>]
        #     Output only. The annotation spec ids used for this evaluation.
        class ClassificationEvaluationMetrics
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # Metrics for a single confidence threshold.
          # @!attribute [rw] confidence_threshold
          #   @return [::Float]
          #     Output only. Metrics are computed with an assumption that the model
          #     never returns predictions with score lower than this value.
          # @!attribute [rw] position_threshold
          #   @return [::Integer]
          #     Output only. Metrics are computed with an assumption that the model
          #     always returns at most this many predictions (ordered by their score,
          #     descendingly), but they all still need to meet the confidence_threshold.
          # @!attribute [rw] recall
          #   @return [::Float]
          #     Output only. Recall (True Positive Rate) for the given confidence
          #     threshold.
          # @!attribute [rw] precision
          #   @return [::Float]
          #     Output only. Precision for the given confidence threshold.
          # @!attribute [rw] false_positive_rate
          #   @return [::Float]
          #     Output only. False Positive Rate for the given confidence threshold.
          # @!attribute [rw] f1_score
          #   @return [::Float]
          #     Output only. The harmonic mean of recall and precision.
          # @!attribute [rw] recall_at1
          #   @return [::Float]
          #     Output only. The Recall (True Positive Rate) when only considering the
          #     label that has the highest prediction score and not below the confidence
          #     threshold for each example.
          # @!attribute [rw] precision_at1
          #   @return [::Float]
          #     Output only. The precision when only considering the label that has the
          #     highest prediction score and not below the confidence threshold for each
          #     example.
          # @!attribute [rw] false_positive_rate_at1
          #   @return [::Float]
          #     Output only. The False Positive Rate when only considering the label that
          #     has the highest prediction score and not below the confidence threshold
          #     for each example.
          # @!attribute [rw] f1_score_at1
          #   @return [::Float]
          #     Output only. The harmonic mean of {::Google::Cloud::AutoML::V1beta1::ClassificationEvaluationMetrics::ConfidenceMetricsEntry#recall_at1 recall_at1} and {::Google::Cloud::AutoML::V1beta1::ClassificationEvaluationMetrics::ConfidenceMetricsEntry#precision_at1 precision_at1}.
          # @!attribute [rw] true_positive_count
          #   @return [::Integer]
          #     Output only. The number of model created labels that match a ground truth
          #     label.
          # @!attribute [rw] false_positive_count
          #   @return [::Integer]
          #     Output only. The number of model created labels that do not match a
          #     ground truth label.
          # @!attribute [rw] false_negative_count
          #   @return [::Integer]
          #     Output only. The number of ground truth labels that are not matched
          #     by a model created label.
          # @!attribute [rw] true_negative_count
          #   @return [::Integer]
          #     Output only. The number of labels that were not created by the model,
          #     but if they would, they would not match a ground truth label.
          class ConfidenceMetricsEntry
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Confusion matrix of the model running the classification.
          # @!attribute [rw] annotation_spec_id
          #   @return [::Array<::String>]
          #     Output only. IDs of the annotation specs used in the confusion matrix.
          #     For Tables CLASSIFICATION
          #
          #     [prediction_type][google.cloud.automl.v1beta1.TablesModelMetadata.prediction_type]
          #     only list of [annotation_spec_display_name-s][] is populated.
          # @!attribute [rw] display_name
          #   @return [::Array<::String>]
          #     Output only. Display name of the annotation specs used in the confusion
          #     matrix, as they were at the moment of the evaluation. For Tables
          #     CLASSIFICATION
          #
          #     [prediction_type-s][google.cloud.automl.v1beta1.TablesModelMetadata.prediction_type],
          #     distinct values of the target column at the moment of the model
          #     evaluation are populated here.
          # @!attribute [rw] row
          #   @return [::Array<::Google::Cloud::AutoML::V1beta1::ClassificationEvaluationMetrics::ConfusionMatrix::Row>]
          #     Output only. Rows in the confusion matrix. The number of rows is equal to
          #     the size of `annotation_spec_id`.
          #     `row[i].example_count[j]` is the number of examples that have ground
          #     truth of the `annotation_spec_id[i]` and are predicted as
          #     `annotation_spec_id[j]` by the model being evaluated.
          class ConfusionMatrix
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods

            # Output only. A row in the confusion matrix.
            # @!attribute [rw] example_count
            #   @return [::Array<::Integer>]
            #     Output only. Value of the specific cell in the confusion matrix.
            #     The number of values each row has (i.e. the length of the row) is equal
            #     to the length of the `annotation_spec_id` field or, if that one is not
            #     populated, length of the {::Google::Cloud::AutoML::V1beta1::ClassificationEvaluationMetrics::ConfusionMatrix#display_name display_name} field.
            class Row
              include ::Google::Protobuf::MessageExts
              extend ::Google::Protobuf::MessageExts::ClassMethods
            end
          end
        end

        # Type of the classification problem.
        module ClassificationType
          # An un-set value of this enum.
          CLASSIFICATION_TYPE_UNSPECIFIED = 0

          # At most one label is allowed per example.
          MULTICLASS = 1

          # Multiple labels are allowed for one example.
          MULTILABEL = 2
        end
      end
    end
  end
end
