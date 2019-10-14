SimpleCov.start do
  command_name "google-cloud-datastore"
  track_files "lib/**/*.rb"
  add_filter /lib\/(.*)\/doc\/(.*)/
  add_filter /lib\/(.*)\_pb\.rb/
  add_filter "test/"
  add_filter "acceptance/"
end if ENV["COVERAGE"]
