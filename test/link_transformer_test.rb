require_relative "test_helper"

describe LinkTransformer do 
  let (:link_transformer) {LinkTransformer.new}
  describe "transform_links_in_text" do 

    it "can handle empty text inputs" do
      transformed_text = link_transformer.transform_links_in_text("")
      expect(transformed_text).must_be_empty
    end
    
    it "keeps text the same if there's no matching markdown links" do
  
      text = <<~TEXT
      The 3.0 release of the google-cloud-translate client is a significant upgrade
      based on a [next-gen code generator](https://github.com/googleapis/gapic-generator-ruby),
      and includes substantial interface changes. Existing code written for earlier
      versions of this library will likely require updates to use this version.
      TEXT

      transformed_text = link_transformer.transform_links_in_text(text)

      expect(transformed_text).must_equal text
    end

    it "keeps text the same if there's no links " do 
      text = <<~TEXT 
      This library is supported on Ruby 2.5+.
      Google provides official support for Ruby versions that are actively supported
      by Ruby Core—that is, Ruby versions that are either in normal maintenance or
      in security maintenance, and not end of life. Currently, this means Ruby 2.5
      and later. Older versions of Ruby _may_ still work, but are unsupported and not
      recommended. See https://www.ruby-lang.org/en/downloads/branches/ for details
      about the Ruby support schedule.
      TEXT

      transformed_text = link_transformer.transform_links_in_text(text)

      expect(transformed_text).must_equal text
    end

    it "transform multiple md links on same line" do 
      text = <<~TEXT
      The 3.0 release of the google-cloud-translate client is a significant upgrade
      based on a [next-gen code generator](https://github.com/googleapis/gapic-generator-ruby),
      and includes substantial interface changes. [Set up authentication](AUTHENTICATION.md),
      [Set up authentication](AUTHENTICATION.md) [MIGRATION.md](MIGRATING.md)
      TEXT

      transformed_text = link_transformer.transform_links_in_text(text)

      yard_text = <<~TEXT
      The 3.0 release of the google-cloud-translate client is a significant upgrade
      based on a [next-gen code generator](https://github.com/googleapis/gapic-generator-ruby),
      and includes substantial interface changes. {file:AUTHENTICATION.md Set up authentication},
      {file:AUTHENTICATION.md Set up authentication} {file:MIGRATING.md MIGRATION.md}
      TEXT

      expect(transformed_text).must_equal yard_text
    end

    it "tranforms all the instances of md links to yard links in text" do
      text = <<~TEXT
      In order to use this library, you first need to go through the following steps:

      1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
      1. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
      1. [Enable the API.](https://console.cloud.google.com/apis/library/translate.googleapis.com)
      1. [Set up authentication](AUTHENTICATION.md)
      
      ## Migrating from 2.x versions
      
      The 3.0 release of the google-cloud-translate client is a significant upgrade
      based on a [next-gen code generator](https://github.com/googleapis/gapic-generator-ruby),
      and includes substantial interface changes. Existing code written for earlier
      versions of this library will likely require updates to use this version.
      See the [MIGRATION.md](MIGRATING.md) document for more information.
      TEXT
      
      transformed_text = link_transformer.transform_links_in_text(text)

      expect(transformed_text).must_include "{file:AUTHENTICATION.md Set up authentication}"
      expect(transformed_text).must_include "{file:MIGRATING.md MIGRATION.md} "
    end

  end
end
