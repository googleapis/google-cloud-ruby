require "helper"
require "gcloud/datastore"

##
# Test class for running against a Datastore instance.
# Ensures that there is an active connection for the tests to use.
# Can be used to run tests against a hosted datastore or local devserver.
#
# This class can be used with the spec DSL.
# To do so, add :datastore to describe:
#
#   describe "My Datastore Test", :datastore do
#     it "does a thing" do
#       your.code.must_be :thing?
#     end
#   end
class DatastoreTest < Minitest::Test
  attr_accessor :dataset

  ##
  # Setup project based on available ENV variables
  def setup
    if ENV["DEVSERVER_PROJECT"]
      @dataset = Gcloud::Datastore.devserver
    else
      @dataset = Gcloud::Datastore.dataset
    end

    refute_nil @dataset, "You do not have an active dataset to run the tests."

    super
  end

  # Add spec DSL
  extend Minitest::Spec::DSL

  # Register this spec type for when :datastore is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :datastore
  end
end
