# Gcloud::Jsondoc

Generates Ruby documentation in JSON format.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gcloud-jsondoc'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gcloud-jsondoc

## Usage

### To generate JSON docs

Run `yard` task to create `.yardoc` with content. Then run the following lines
(probably in a Rake task) to generate JSON doc files for gcloud-common/site
deployment.

```ruby
require "gcloud/jsondoc"

registry = YARD::Registry.load! ".yardoc"
generator = Gcloud::Jsondoc::Generator.new registry
generator.write_to "jsondoc"
```

Note: If the source code lives in a sub-directory of the main repo, as it
currently does for `google-cloud-*` gems, be sure to provide the subdirectory
name to the `Generator` initializer:

```ruby
require "gcloud/jsondoc"

registry = YARD::Registry.load! ".yardoc"
generator = Gcloud::Jsondoc::Generator.new registry, "google-cloud-bigquery"
generator.write_to "jsondoc"
```

Without this configuration, the `source` URLs for the code on GitHub will be
incorrect. You don't need it if `lib` is in the repo root.

### To test documentation examples

Run `yard` task to create `.yardoc` with content. Then run the following lines
(probably in a Rake task) to generate JSON doc files for gcloud-common/site
deployment.

```ruby
require "gcloud/jsondoc"

registry = YARD::Registry.load! ".yardoc"
examples = Gcloud::Jsondoc::Examples.new registry
examples.test_all
```

