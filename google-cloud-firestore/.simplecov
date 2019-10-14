require "simplecov"
SimpleCov.start do
  command_name "google-cloud-firestore"
  track_files "lib/**/*.rb"
  add_filter "test/"
end if ENV["COVERAGE"]
