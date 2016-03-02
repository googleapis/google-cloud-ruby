##
# The outermost module in the test fixtures.
#
# This is a Ruby [module](http://docs.ruby-lang.org/en/2.2.0/Module.html).
#
# ```ruby
# require "gcloud"
#
# gcloud = Gcloud.new "publicdata"
# bigquery = gcloud.bigquery
# ```
#
# It lists all datasets in the project.
#
module MyModule

  ##
  # A simple class. Does nothing.
  class ReturnClass
  end

  ##
  # Creates a new object for testing this library, as explained in [this
  # article on testing](https://en.wikipedia.org/wiki/Software_testing).
  #
  # Each call creates a new instance.
  #
  # @see http://ntp.org/documentation.html NTP Documentation
  #
  # @param [String] personal_name The name, which can be any name as defined by [this
  #   article on names](https://en.wikipedia.org/wiki/Personal_name)
  # @param [String, Array<String>, nil] email The person's email or emails.
  # @param [Boolean, nil] opt_in Whether to subscribe to *all* mailing lists.
  #
  # @raise [ArgumentError] if the name is not a name as defined by [this
  #   article](https://en.wikipedia.org/wiki/Personal_name)
  #
  # @return [MyModule::ReturnClass] an empty object instance
  #
  # @example You can pass options.
  #   return_object = Mymodule.storage "my name", opt_in: true do |config|
  #     config.more = "more"
  #   end
  #
  def self.example_method personal_name, email: nil, opt_in: false
    ReturnClass.new
  end
end
