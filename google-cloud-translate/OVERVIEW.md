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

## Authenticating

Like other Cloud Platform services, Google Cloud Translation API supports
authentication using a project ID and OAuth 2.0 credentials. In addition,
it supports authentication using a public API access key. (If both the API
key and the project and OAuth 2.0 credentials are provided, the API key
will be used.) Instructions and configuration options are covered in the
{file:AUTHENTICATION.md Authentication Guide}.

## Translating texts

Translating text from one language to another is easy (and extremely
fast.) The only required arguments to
{Google::Cloud::Translate::Api#translate} are a string and the [ISO
639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) code of the
language to which you wish to translate.

```ruby
require "google/cloud/translate"

translate = Google::Cloud::Translate.new

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

translate = Google::Cloud::Translate.new

translation = translate.translate "chat", to: "en"

translation.detected? #=> true
translation.from #=> "en"
translation.text #=> "chat"

translation = translate.translate "chat", from: "fr", to: "en"

translation.detected? #=> false
translation.from #=> "fr"
translation.text #=> "cat"
```

You can pass multiple texts to {Google::Cloud::Translate::Api#translate}.

```ruby
require "google/cloud/translate"

translate = Google::Cloud::Translate.new

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

translate = Google::Cloud::Translate.new

translation = translate.translate "<strong>Hello</strong> world!",
                                  to: :la
translation.text #=> "<strong>Salve</strong> mundi!"
```

## Detecting languages

You can use {Google::Cloud::Translate::Api#detect} to see which language
the Translation API ranks as the most likely source language for a text.
The `confidence` score is a float value between `0` and `1`.

```ruby
require "google/cloud/translate"

translate = Google::Cloud::Translate.new

detection = translate.detect "chat"

detection.text #=> "chat"
detection.language #=> "en"
detection.confidence #=> 0.59922177
```

You can pass multiple texts to {Google::Cloud::Translate::Api#detect}.

```ruby
require "google/cloud/translate"

translate = Google::Cloud::Translate.new

detections = translate.detect "chien", "chat"

detections.size #=> 2
detections[0].text #=> "chien"
detections[0].language #=> "fr"
detections[0].confidence #=> 0.7109375
detections[1].text #=> "chat"
detections[1].language #=> "en"
detections[1].confidence #=> 0.59922177
```

## Listing supported languages

Translation API adds new languages frequently. You can use
{Google::Cloud::Translate::Api#languages} to query the list of supported
languages.

```ruby
require "google/cloud/translate"

translate = Google::Cloud::Translate.new

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

translate = Google::Cloud::Translate.new

languages = translate.languages "en"

languages.size #=> 104
languages[0].code #=> "af"
languages[0].name #=> "Afrikaans"
```

## Configuring retries and timeout

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

translate = Google::Cloud::Translate.new retries: 10, timeout: 120
```
