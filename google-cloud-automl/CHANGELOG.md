# Release History

### 0.2.0 / 2019-08-21

#### Features

* Update documentation
* Add DocumentDimensions, Layout and PredictResponse#preprocessed_input
  * Update Document
    * Add Document#document_text (TextSnippet)
    * Add Document#layout (Document::Layout)
    * Add Document#document_dimensions (DocumentDimensions)
    * Add Document#page_count
  * Update PredictionServiceClient#predict response
    * Add PredictResponse#preprocessed_input (ExamplePayload)
  * Added classes:
    * Add Document::Layout
    * Add DocumentDimensions
  * Update Documentation
* Deprecate ColumnSpec#top_correlated_columns
  * Deprecate ColumnSpec#top_correlated_columns
  * Add BatchPredictResult#metadata.
  * Add ConfusionMatrix#display_name
  * Add TableSpec#valid_row_count
  * Update documentation

### 0.1.0 / 2019-07-15

* Initial release.
