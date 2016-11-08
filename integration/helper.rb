# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "fileutils"
require "open3"

##
# Keep trying a block of code until the code of block yield a true statement or
# raise error after timeout
def keep_trying_till_true timeout = 30
  t_begin = Time.now
  loop do
    if yield
      break
    elsif (Time.now - t_begin) > timeout
      fail "Timeout after trying for #{timeout} seconds"
    else
      sleep 1
    end
  end
end

##
# Setup the app.yaml file and deploy this directory to GAE. When run from repo
# root directory, this will deploy the integration/classic_sinatra_app.rb onto
# GAE for testing use.
def deploy_gae_flex app_dir
  unless File.file? "app.yaml"
    FileUtils.cp "#{app_dir}/app.yaml.example", "app.yaml"
    temp_app_yaml = true
  end

  begin
    last_gae_version = get_gae_versions.last
    sh "gcloud app deploy -q" do |ok, res|
      if ok
        yield

        # Delete the last version of Google App Engine if successfully deployed
        unless last_gae_version.empty?
          puts "gcloud app versions delete #{last_gae_version} -q"
          `gcloud app versions delete #{last_gae_version} -q`
        end
      else
        fail "'gcloud app deploy' failed with status = #{res.exitstatus}"
      end
    end
  ensure
    FileUtils.rm "app.yaml" if temp_app_yaml
  end
end

##
# Get all the Google App Engine Versions
def get_gae_versions
  stdout = `gcloud app versions list`
  stdout.scan(/default\s+(\S*)\s/).flatten.sort
end

##
# Setup the Dockerfile file, build the docker image, run a block of code, and
# then clean up afterwards.
def build_docker_image app_dir, project_id
  image_name = "google-cloud-ruby-test-%.08x" % rand(0x100000000)
  image_location = "us.gcr.io/#{project_id}/#{image_name}"
  begin
    # Create default Dockerfile if one doesn't already exist
    if File.file? "Dockerfile"
      fail "The Dockerfile file already exists. Please omit it and try again."
    else
      FileUtils.cp "#{app_dir}/Dockerfile.example", "Dockerfile"
      temp_dockerfile = true
    end

    sh "docker build -t #{image_location} ."
    yield image_name, image_location
  ensure
    sh "docker rmi #{image_location}"
    FileUtils.rm "Dockerfile" if temp_dockerfile
  end
end

##
# Push a Docker image to Google Container Registry. Then clean up after running
# the yield block
def push_docker_image project_id, image_name, image_location
  begin
    sh "gcloud docker -- push #{image_location}"
    yield image_name, image_location
  ensure
    `gsutil rm -r gs://us.artifacts.#{project_id}.appspot.com/containers/repositories/library/#{image_name}/`
  end
end

##
# Given an docker image name and full url (location) that already exists on
# Google Container Registry, deploy the GKE service using that image and verify
# it's running.
def deploy_gke_image image_name, image_location
  return unless image_name && image_location

  # Create default acceptace_rc.yaml if one doesn't already exist
  rc_yaml_file_name = "integration_rc.yaml"
  if File.file? rc_yaml_file_name
    fail "The #{rc_yaml_file_name} file already exist. Please omit it and " \
      "try again."
  else
    # Copy example yaml file and update with correct content
    File.open "integration/integration_rc.yaml.example" do |source_file|
      File.open rc_yaml_file_name, "w" do |dest_file|
        file_content = source_file.read
        new_content = file_content.gsub(/\[\[image_location\]\]/, image_location)
        new_content = new_content.gsub(/\[\[image_name\]\]/, image_name)
        dest_file.puts new_content
      end
    end
    temp_rc_yaml = true
  end

  # Use kubectl to deploy GKE service and validate the GKE pods is running
  begin
    sh "kubectl create -f #{rc_yaml_file_name}"

    # Keep polling for GKE pod status till it's "Running"
    pod_name = nil
    pod_status = nil
    keep_trying_till_true 300 do
      stdout = `kubectl get pods`
      pods_info = stdout.split("\n").drop(1)
      pods_info.each do |pod_info|
        pod_info = pod_info.split
        if pod_info[0].match image_name
          pod_name = pod_info[0]
          pod_status = pod_info[2] == "Running"
          break
        end
      end
      pod_status
    end
    yield pod_name
  ensure
    # Clean up GKE services
    FileUtils.rm "integration_rc.yaml" if temp_rc_yaml
    sh "kubectl delete rc #{image_name}"
  end
end

##
# Get GCP project id from Gcloud SDK
def gcloud_project_id
  stdout = Open3.capture3("gcloud config list project").first
  stdout.scan(/project = (.*)/).first.first
end

##
# Check if an executable exists
def executable_exists? executable
  !`which #{executable}`.empty?
end
