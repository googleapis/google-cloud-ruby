source "https://rubygems.org"

gem "rake"
# Pin minitest to 5.11.x to avoid warnings emitted by 5.12.
# See https://github.com/googleapis/google-cloud-ruby/issues/4110
gem "minitest", "~> 5.11.3"
gem "minitest-autotest", "~> 1.0"
gem "minitest-focus", "~> 1.1"
gem "minitest-rg", "~> 5.2"
gem "autotest-suffix", "~> 1.1"
gem "redcarpet", "~> 3.0"
gem "rubocop", "~> 1.8"
gem "simplecov", "~> 0.16"
gem "codecov", "~> 0.1", require: false
gem "yard", "~> 0.9"
gem "yard-doctest", "~> 0.1.13"
gem "gems", "~> 0.8"
gem "actionpack", "~> 5.0"
gem "railties", "~> 5.0"
gem "rack", ">= 0.1"

omit_gems = ["gcloud", "google-cloud"]

Dir.glob "*/*.gemspec" do |path|
  if path =~ %r{([a-z0-9_-]+)/([a-z0-9_-]+)\.gemspec}
    name = Regexp.last_match 1
    if name == Regexp.last_match(2) && !omit_gems.include?(name)
      gem name, path: name
    end
  end
end
