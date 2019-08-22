# Release History

### 0.2.0 / 2019-08-22

#### Features

* Update Document
  * Add Document#document_text (TextSnippet)
  * Add Document#layout (Document::Layout)
  * Add Document#document_dimensions (DocumentDimensions)
  * Add Document#page_count
* Update PredictionServiceClient#predict response
  * Add PredictResponse#preprocessed_input (ExamplePayload)
* Add BatchPredictResult#metadata.
* Add ConfusionMatrix#display_name
* Add TableSpec#valid_row_count
* Added classes:
  * Add Document::Layout
  * Add DocumentDimensions
* Deprecate ColumnSpec#top_correlated_columns
* Update documentation

### 0.1.0 / 2019-07-15

* Initial release.
