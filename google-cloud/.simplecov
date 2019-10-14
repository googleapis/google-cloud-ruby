SimpleCov.start do
  command_name "google-cloud"
  track_files "lib/**/*.rb"
  add_filter "test/"
  add_filter "acceptance/"
end if ENV["COVERAGE"]
