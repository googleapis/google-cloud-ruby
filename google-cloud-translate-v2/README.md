# Ruby Client for the Cloud Translation V2 API

API Client library for the Cloud Translation V2 API

Cloud Translation can dynamically translate text between thousands of language pairs. Translation lets websites and programs programmatically integrate with the translation service.

https://github.com/googleapis/google-cloud-ruby

## Installation

```
$ gem install google-cloud-translate-v2
```

## Before You Begin

In order to use this library, you first need to go through the following steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
1. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
1. {file:AUTHENTICATION.md Set up authentication.}

## Quick Start

```ruby
require "google/cloud/translate/v2"

client = Google::Cloud::Translate::V2.new

translation = client.translate "Hello world!", to: "la"

puts translation #=> Salve mundi!

translation.from #=> "en"
translation.origin #=> "Hello world!"
translation.to #=> "la"
translation.text #=> "Salve mundi!"
```

View the [Client Library Documentation](https://googleapis.dev/ruby/google-cloud-translate-v2/latest)
for class and method documentation.

## Supported Ruby Versions

This library is supported on Ruby 2.4+.

Google provides official support for Ruby versions that are actively supported
by Ruby Core—that is, Ruby versions that are either in normal maintenance or in
security maintenance, and not end of life. Currently, this means Ruby 2.4 and
later. Older versions of Ruby _may_ still work, but are unsupported and not
recommended. See https://www.ruby-lang.org/en/downloads/branches/ for details
about the Ruby support schedule.
