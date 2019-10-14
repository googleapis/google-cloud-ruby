SimpleCov.start do
  command_name "stackdriver-core"
  track_files "lib/**/*.rb"
  add_filter "test/"
  add_filter "acceptance/"
end if ENV["COVERAGE"]
