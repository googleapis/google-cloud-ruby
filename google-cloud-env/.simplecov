SimpleCov.start do
  command_name "google-cloud-env"
  track_files "lib/**/*.rb"
  add_filter "test/"
  add_filter "acceptance/"
end if ENV["COVERAGE"]
