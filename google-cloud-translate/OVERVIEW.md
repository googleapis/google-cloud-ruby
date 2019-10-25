# Google Cloud Translation API

[Google Cloud Translation API](https://cloud.google.com/translation/)
provides a simple, programmatic interface for translating an arbitrary
string into any supported language. It is highly responsive, so websites
and applications can integrate with Translation API for fast, dynamic
translation of source text. Language detection is also available in cases
where the source language is unknown.

Translation API supports more than one hundred different languages, from
Afrikaans to Zulu. Used in combination, this enables translation between
thousands of language pairs. Also, you can send in HTML and receive HTML
with translated text back. You don't need to extract your source text or
reassemble the translated content.

The google-cloud-translate 2.0 gem contains a generated v3 client and a legacy hand-written v2 client.
To use the legacy v2 client, call {Google::Cloud::Translate.new} and specify `version: :v2`.
See [Migrating to Translation v3](https://cloud.google.com/translate/docs/migrate-to-v3) for details regarding differences between v2 and v3.

## Authenticating

Like other Cloud Platform services, Google Cloud Translation API supports
authentication using a project ID and OAuth 2.0 credentials. In addition,
it supports authentication using a public API access key. (If both the API
key and the project and OAuth 2.0 credentials are provided, the API key
will be used.) Instructions and configuration options are covered in the
{file:AUTHENTICATION.md Authentication Guide}.

## Using the v3 client

The Cloud Translation API v3 includes several new features and updates:

* Glossaries - Create a custom dictionary to correctly and consistently translate terms that are customer-specific.
* Batch requests - Make an asynchronous request to translate large amounts of text.
* AutoML models - Cloud Translation adds support for translating text with custom models that you create using AutoML Translation.
* Labels - The Cloud Translation API supports adding user-defined labels (key-value pairs) to requests.

### Translating texts

Cloud Translation v3 introduces support for translating text using custom AutoML Translation models, and for creating glossaries to ensure that the Cloud Translation API translates a customer's domain-specific terminology correctly.

Performing a default translation:

```ruby
require "google/cloud/translate"

client = Google::Cloud::Translate.new

project_id = "my-project-id"
location_id = "us-central1"

# The content to translate in string format
contents = ["Hello, world!"]
# Required. The BCP-47 language code to use for translation.
target_language = "fr"
parent = client.class.location_path project_id, location_id

response = client.translate_text contents, target_language, parent

# Display the translation for each input text provided
response.translations.each do |translation|
  puts "Translated text: #{translation.translated_text}"
end
```

To use AutoML custom models you enable the [AutoML API](automl.googleapis.com) for your project before translating as follows:

```ruby
require "google/cloud/translate"

client = Google::Cloud::Translate.new

project_id = "my-project-id"
location_id = "us-central1"
model_id = "my-automl-model-id"

# The `model` type requested for this translation.
model = "projects/#{project_id}/locations/#{location_id}/models/#{model_id}"
# The content to translate in string format
contents = ["Hello, world!"]
# Required. The BCP-47 language code to use for translation.
target_language = "fr"
# Optional. The BCP-47 language code of the input text.
source_language = "en"
# Optional. Can be "text/plain" or "text/html".
mime_type = "text/plain"
parent = client.class.location_path project_id, location_id

response = client.translate_text contents, target_language, parent,
  source_language_code: source_language, model: model, mime_type: mime_type

# Display the translation for each input text provided
response.translations.each do |translation|
  puts "Translated text: #{translation.translated_text}"
end
```

To use a glossary you need to create a Google Cloud Storage bucket and grant your service account access to it before translating as follows:

```ruby
require "google/cloud/translate"

client = Google::Cloud::Translate.new

project_id = "my-project-id"
location_id = "us-central1"
glossary_id = "my-glossary-id"

# The content to translate in string format
contents = ["Hello, world!"]
# Required. The BCP-47 language code to use for translation.
target_language = "fr"
# Optional. The BCP-47 language code of the input text.
source_language = "en"
glossary_config = {
  # Specifies the glossary used for this translation.
  glossary: client.class.glossary_path(project_id, location_id, glossary_id)
}
# Optional. Can be "text/plain" or "text/html".
mime_type = "text/plain"
parent = client.class.location_path project_id, location_id

response = client.translate_text contents, target_language, parent,
  source_language_code: source_language, glossary_config: glossary_config, mime_type: mime_type

# Display the translation for each input text provided
response.translations.each do |translation|
  puts "Translated text: #{translation.translated_text}"
end
```

### Batch translating texts

Batch translation allows you to translate large amounts of text (with a limit of 1,000 files per batch), and to up to 10 different target languages.
Batch translation also supports AutoML models and glossaries.
To make batch requests you need to create a Google Cloud Storage bucket and grant your service account access to it before translating as follows:

```ruby
require "google/cloud/translate"

client = Google::Cloud::Translate.new

input_uri = "gs://cloud-samples-data/text.txt"
output_uri = "gs://my-bucket-id/path_to_store_results/"
project_id = "my-project-id"
location_id = "us-central1"
source_lang = "en"
target_lang = "ja"

input_config = {
  gcs_source: {
    input_uri: input_uri
  },
  # Optional. Can be "text/plain" or "text/html".
  mime_type: "text/plain"
}
output_config = {
  gcs_destination: {
    output_uri_prefix: output_uri
  }
}
parent = client.class.location_path project_id, location_id

operation = client.batch_translate_text \
  parent, source_lang, [target_lang], [input_config], output_config

# Wait until the long running operation is done
operation.wait_until_done!

response = operation.response

puts "Total Characters: #{response.total_characters}"
puts "Translated Characters: #{response.translated_characters}"
```

### Detecting languages

You can detect the language of a text string:

```ruby
require "google/cloud/translate"

client = Google::Cloud::Translate.new

project_id = "my-project-id"
location_id = "us-central1"
# The text string for performing language detection
content = "Hello, world!"
# Optional. Can be "text/plain" or "text/html".
mime_type = "text/plain"

parent = client.class.location_path project_id, location_id

response = client.detect_language parent, content: content, mime_type: mime_type

# Display list of detected languages sorted by detection confidence.
# The most probable language is first.
response.languages.each do |language|
  # The language detected
  puts "Language Code: #{language.language_code}"
  # Confidence of detection result for this language
  puts "Confidence: #{language.confidence}"
end
```

### Listing supported languages

You can discover the [supported languages](https://cloud.google.com/translate/docs/languages) of the v3 API:

```ruby
require "google/cloud/translate"

client = Google::Cloud::Translate.new

project_id = "my-project-id"
location_id = "us-central1"

parent = client.class.location_path project_id, location_id

response = client.get_supported_languages parent

# List language codes of supported languages
response.languages.each do |language|
  puts "Language Code: #{language.language_code}"
end
```

## Using the legacy v2 client

### Translating texts

Translating text from one language to another is easy (and extremely
fast.) The only required arguments to
{Google::Cloud::Translate::V2::Api#translate} are a string and the [ISO
639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) code of the
language to which you wish to translate.

```ruby
require "google/cloud/translate"

translate = Google::Cloud::Translate.new version: :v2

translation = translate.translate "Hello world!", to: "la"

puts translation #=> Salve mundi!

translation.from #=> "en"
translation.origin #=> "Hello world!"
translation.to #=> "la"
translation.text #=> "Salve mundi!"
```

You may want to use the `from` option to specify the language of the
source text, as the following example illustrates. (Single words do not
give Translation API much to work with.)

```ruby
require "google/cloud/translate"

translate = Google::Cloud::Translate.new version: :v2

translation = translate.translate "chat", to: "en"

translation.detected? #=> true
translation.from #=> "en"
translation.text #=> "chat"

translation = translate.translate "chat", from: "fr", to: "en"

translation.detected? #=> false
translation.from #=> "fr"
translation.text #=> "cat"
```

You can pass multiple texts to {Google::Cloud::Translate::V2::Api#translate}.

```ruby
require "google/cloud/translate"

translate = Google::Cloud::Translate.new version: :v2

translations = translate.translate "chien", "chat", from: "fr", to: "en"

translations.size #=> 2
translations[0].origin #=> "chien"
translations[0].text #=> "dog"
translations[1].origin #=> "chat"
translations[1].text #=> "cat"
```

By default, any HTML in your source text will be preserved.

```ruby
require "google/cloud/translate"

translate = Google::Cloud::Translate.new version: :v2

translation = translate.translate "<strong>Hello</strong> world!",
                                  to: :la
translation.text #=> "<strong>Salve</strong> mundi!"
```

### Detecting languages

You can use {Google::Cloud::Translate::V2::Api#detect} to see which language
the Translation API ranks as the most likely source language for a text.
The `confidence` score is a float value between `0` and `1`.

```ruby
require "google/cloud/translate"

translate = Google::Cloud::Translate.new version: :v2

detection = translate.detect "chat"

detection.text #=> "chat"
detection.language #=> "en"
detection.confidence #=> 0.59922177
```

You can pass multiple texts to {Google::Cloud::Translate::V2::Api#detect}.

```ruby
require "google/cloud/translate"

translate = Google::Cloud::Translate.new version: :v2

detections = translate.detect "chien", "chat"

detections.size #=> 2
detections[0].text #=> "chien"
detections[0].language #=> "fr"
detections[0].confidence #=> 0.7109375
detections[1].text #=> "chat"
detections[1].language #=> "en"
detections[1].confidence #=> 0.59922177
```

### Listing supported languages

Translation API adds new languages frequently. You can use
{Google::Cloud::Translate::V2::Api#languages} to query the list of supported
languages.

```ruby
require "google/cloud/translate"

translate = Google::Cloud::Translate.new version: :v2

languages = translate.languages

languages.size #=> 104
languages[0].code #=> "af"
languages[0].name #=> nil
```

To receive the names of the supported languages, as well as their [ISO
639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) codes,
provide the code for the language in which you wish to receive the names.

```ruby
require "google/cloud/translate"

translate = Google::Cloud::Translate.new version: :v2

languages = translate.languages "en"

languages.size #=> 104
languages[0].code #=> "af"
languages[0].name #=> "Afrikaans"
```

### Configuring retries and timeout

You can configure how many times API requests may be automatically
retried. When an API request fails, the response will be inspected to see
if the request meets criteria indicating that it may succeed on retry,
such as `500` and `503` status codes or a specific internal error code
such as `rateLimitExceeded`. If it meets the criteria, the request will be
retried after a delay. If another error occurs, the delay will be
increased before a subsequent attempt, until the `retries` limit is
reached.

You can also set the request `timeout` value in seconds.

```ruby
require "google/cloud/translate"

translate = Google::Cloud::Translate.new version: :v2, retries: 10, timeout: 120
```
