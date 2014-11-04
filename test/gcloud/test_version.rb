require "helper"
require "gcloud"

describe Gcloud do
  it "has a version" do
    Gcloud::VERSION.wont_be :nil?
  end
end
