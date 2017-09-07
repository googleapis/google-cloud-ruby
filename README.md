# Gcloud::Jsondoc

Generates Ruby documentation in JSON format. Docstrings are collected only from
non-private classes and modules.

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

#### Setting a different path to source code

If the source code lives in a sub-directory of the main repo, as it
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

#### Generating a TOC resource (page)

You can generate a resource (page) for the Angular site app with a special
description containing a TOC table for select classes/modules. The `package`
property will be used for the headline of the description. The `include`
property is a regex matched to jsondoc filepaths:

```ruby
require "gcloud/jsondoc"

registry = YARD::Registry.load! ".yardoc"

toc_config = {
  documents: [
    {
      type: "toc",
      title: "Google::Datastore::V1::DataTypes",
      modules: [
        {
          title: "Google::Protobuf",
          include: ["google/protobuf"]
        },
        {
          title: "Google::Datastore::V1",
          include: ["google/datastore/v1"]
        }
      ]
    }
  ]
}

generator = Gcloud::Jsondoc::Generator.new registry, nil, generate: toc_config
generator.write_to "jsondoc"
```

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

