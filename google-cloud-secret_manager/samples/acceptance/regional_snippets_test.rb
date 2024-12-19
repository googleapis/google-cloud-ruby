# Copyright 2020 Google, Inc
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

require "uri"

require_relative "regional_helper"
require_relative "../regional_snippets"

describe "Secret Manager Regional Snippets" do
  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT") }
  let(:location_id) { "us-west1" }
  let(:api_endpoint) { "secretmanager.#{location_id}.rep.googleapis.com" }
  let(:filter) { "name : ruby-quickstart-" }

  let :client do
    Google::Cloud::SecretManager.secret_manager_service do |config|
      config.endpoint = api_endpoint
    end
  end

  let(:secret_id) { "ruby-quickstart-#{(Time.now.to_f * 1000).to_i}" }
  let(:secret_name) { "projects/#{project_id}/locations/#{location_id}/secrets/#{secret_id}" }
  let(:iam_user) { "user:sarafy@google.com" }

  let :secret do
    client.create_secret(
      parent:    "projects/#{project_id}/locations/#{location_id}",
      secret_id: secret_id,
      secret:    {}
    )
  end

  let :secret_version do
    client.add_secret_version(
      parent:  secret.name,
      payload: {
        data: "hello world!"
      }
    )
  end

  let(:etag) { secret_version.etag }

  let(:version_id) { URI(secret_version.name).path.split("/").last }
  let(:version_name) { "projects/#{project_id}/locations/#{location_id}/secrets/#{secret_id}/versions/#{version_id}" }

  after do
    client.delete_secret name: secret_name
  rescue Google::Cloud::NotFoundError
    # Do nothing
  end

  describe "#access_regional_secret_version" do
    it "accesses the regional version" do
      expect {
        version = access_regional_secret_version(
          project_id:  project_id,
          location_id: location_id,
          secret_id:   secret_id,
          version_id:  version_id
        )

        expect(version).wont_be_nil
        expect(version.name).must_include(secret_id)
        expect(version.payload.data).must_equal("hello world!")
      }.must_output(/Plaintext: hello world!/)
    end
  end

  describe "#add_regional_secret_version" do
    it "adds a regional secret version" do
      o_list = client.list_secret_versions(parent: secret.name).to_a
      expect(o_list).must_be_empty

      expect {
        version = add_regional_secret_version(
          project_id:  project_id,
          location_id: location_id,
          secret_id:   secret_id
        )

        n_list = client.list_secret_versions(parent: secret.name).to_a
        expect(n_list).must_include(version)
      }.must_output(/Added regional secret version:/)
    end
  end

  describe "#create_regional_secret" do
    it "creates a regional secret" do
      expect {
        secret = create_regional_secret(
          project_id:  project_id,
          location_id: location_id,
          secret_id:   secret_id
        )

        expect(secret).wont_be_nil
        expect(secret.name).must_include(secret_id)
      }.must_output(/Created regional secret/)
    end
  end

  describe "#delete_regional_secret_with_etag" do
    it "deletes the regional secret with the passed etag" do
      expect(secret).wont_be_nil

      get_secret_reponse = client.get_secret name: secret_name
      updated_etag = get_secret_reponse.etag

      expect {
        delete_regional_secret_with_etag(
          project_id:  project_id,
          location_id: location_id,
          secret_id:   secret_id,
          etag: updated_etag
        )
      }.must_output(/Deleted regional secret/)

      expect {
        client.get_secret name: secret_name
      }.must_raise(Google::Cloud::NotFoundError)
    end
  end

  describe "#delete_regional_secret" do
    it "deletes the regional secret" do
      expect(secret).wont_be_nil

      expect {
        delete_regional_secret(
          project_id:  project_id,
          location_id: location_id,
          secret_id:   secret_id
        )
      }.must_output(/Deleted regional secret/)

      expect {
        client.get_secret name: secret_name
      }.must_raise(Google::Cloud::NotFoundError)
    end
  end

  describe "#destroy_regional_secret_version_with_etag" do
    it "destroys the regional secret version with the passed etag" do
      expect(secret_version).wont_be_nil

      expect {
        destroy_regional_secret_version_with_etag(
          project_id: project_id,
          location_id: location_id,
          secret_id:  secret_id,
          version_id: version_id,
          etag: etag
        )
      }.must_output(/Destroyed regional secret version/)

      n_version = client.get_secret_version name: version_name
      expect(n_version).wont_be_nil
      expect(n_version.state.to_s.downcase).must_equal("destroyed")
    end
  end

  describe "#destroy_regional_secret_version" do
    it "destroys the regional secret version" do
      expect(secret_version).wont_be_nil

      expect {
        destroy_regional_secret_version(
          project_id: project_id,
          location_id: location_id,
          secret_id:  secret_id,
          version_id: version_id
        )
      }.must_output(/Destroyed regional secret version/)

      n_version = client.get_secret_version name: version_name
      expect(n_version).wont_be_nil
      expect(n_version.state.to_s.downcase).must_equal("destroyed")
    end
  end

  describe "#disable_regional_secret_version_with_etag" do
    it "disables the regional secret version with the passed etag" do
      expect(secret_version).wont_be_nil

      expect {
        disable_regional_secret_version_with_etag(
          project_id:  project_id,
          location_id: location_id,
          secret_id:   secret_id,
          version_id:  version_id,
          etag: etag
        )
      }.must_output(/Disabled regional secret version/)

      n_version = client.get_secret_version name: version_name
      expect(n_version).wont_be_nil
      expect(n_version.state.to_s.downcase).must_equal("disabled")
    end
  end

  describe "#disable_regional_secret_version" do
    it "disables the regional secret version" do
      expect(secret_version).wont_be_nil

      expect {
        disable_regional_secret_version(
          project_id:  project_id,
          location_id: location_id,
          secret_id:   secret_id,
          version_id:  version_id
        )
      }.must_output(/Disabled regional secret version/)

      n_version = client.get_secret_version name: version_name
      expect(n_version).wont_be_nil
      expect(n_version.state.to_s.downcase).must_equal("disabled")
    end
  end

  describe "#enable_regional_secret_version_with_etag" do
    it "enables the regional secret version with the passed etag" do
      expect(secret_version).wont_be_nil
      disable_secret_version_response = client.disable_secret_version name: version_name

      updated_etag = disable_secret_version_response.etag

      expect {
        enable_regional_secret_version_with_etag(
          project_id:  project_id,
          location_id: location_id,
          secret_id:   secret_id,
          version_id:  version_id,
          etag: updated_etag
        )
      }.must_output(/Enabled regional secret version/)

      n_version = client.get_secret_version name: version_name
      expect(n_version).wont_be_nil
      expect(n_version.state.to_s.downcase).must_equal("enabled")
    end
  end

  describe "#enable_regional_secret_version" do
    it "enables the regional secret version" do
      expect(secret_version).wont_be_nil
      client.disable_secret_version name: version_name

      expect {
        enable_regional_secret_version(
          project_id:  project_id,
          location_id: location_id,
          secret_id:   secret_id,
          version_id:  version_id
        )
      }.must_output(/Enabled regional secret version/)

      n_version = client.get_secret_version name: version_name
      expect(n_version).wont_be_nil
      expect(n_version.state.to_s.downcase).must_equal("enabled")
    end
  end

  describe "#get_regional_secret" do
    it "gets the regional secret" do
      expect(secret).wont_be_nil
      expect {
        n_secret = get_regional_secret(
          project_id:  project_id,
          location_id: location_id,
          secret_id:   secret_id
        )

        expect(n_secret).wont_be_nil
        expect(n_secret.name).must_equal(secret.name)
      }.must_output(/Got regional secret/)
    end
  end

  describe "#get_regional_secret_version" do
    it "gets the regional secret version" do
      expect(secret_version).wont_be_nil
      expect {
        n_version = get_regional_secret_version(
          project_id:  project_id,
          location_id: location_id,
          secret_id:   secret_id,
          version_id:  version_id
        )

        expect(n_version).wont_be_nil
        expect(n_version.name).must_equal(secret_version.name)
      }.must_output(/Got regional secret version/)
    end
  end

  describe "#iam_grant_access_regional" do
    it "grants access to the regional secret" do
      expect(secret).wont_be_nil
      expect {
        policy = iam_grant_access_regional(
          project_id:  project_id,
          location_id: location_id,
          secret_id:   secret_id,
          member:      iam_user
        )

        expect(policy).wont_be_nil
        bind = policy.bindings.find do |b|
          b.role == "roles/secretmanager.secretAccessor"
        end

        expect(bind).wont_be_nil
        expect(bind.members).must_include(iam_user)
      }.must_output(/Updated regional IAM policy/)
    end
  end

  describe "#iam_revoke_access_regional" do
    it "revokes access to the regional secret" do
      expect(secret).wont_be_nil

      # Add an IAM member
      name = client.secret_path project: project_id, location: location_id, secret: secret_id
      policy = client.get_iam_policy resource: name
      policy.bindings << Google::Iam::V1::Binding.new(
        members: [iam_user],
        role:    "roles/secretmanager.secretAccessor"
      )
      client.set_iam_policy resource: name, policy: policy

      expect {
        policy = iam_revoke_access_regional(
          project_id:  project_id,
          location_id: location_id,
          secret_id:   secret_id,
          member:      iam_user
        )

        expect(policy).wont_be_nil
        bind = policy.bindings.find do |b|
          b.role == "roles/secretmanager.secretAccessor"
        end

        # The only member was iam_user, so the server will remove the binding
        # automatically.
        expect(bind).must_be_nil
      }.must_output(/Updated regional IAM policy/)
    end
  end

  describe "#list_regional_secret_versions_with_filter" do
    it "lists the regional secret versions with the passed filter" do
      expect(secret).wont_be_nil
      expect(secret_version).wont_be_nil

      expect {
        list_regional_secret_versions(
          project_id: project_id,
          location_id: location_id,
          secret_id:  secret_id
        )
      }.must_output(/Got regional secret version(.+)#{version_id}/)
    end
  end

  describe "#list_regional_secret_versions" do
    it "lists the regional secret versions with the passed filter" do
      expect(secret).wont_be_nil
      expect(secret_version).wont_be_nil

      expect {
        list_regional_secret_versions_with_filter(
          project_id: project_id,
          location_id: location_id,
          secret_id:  secret_id,
          filter: filter
        )
      }.must_output(/Got regional secret version(.+)#{version_id}/)
    end
  end

  describe "#list_regional_secrets_with_filter" do
    it "lists the regional secrets" do
      expect(secret).wont_be_nil

      expect {
        list_regional_secrets_with_filter project_id: project_id, location_id: location_id, filter: filter
      }.must_output(/Got regional secret(.+)#{secret_id}/)
    end
  end

  describe "#list_regional_secrets" do
    it "lists the regional secrets" do
      expect(secret).wont_be_nil

      expect {
        list_regional_secrets project_id: project_id, location_id: location_id
      }.must_output(/Got regional secret(.+)#{secret_id}/)
    end
  end

  describe "#update_regional_secret_with_etag" do
    it "updates the regional secret with the passed etag" do
      expect(secret).wont_be_nil

      get_secret_reponse = client.get_secret name: secret_name
      updated_etag = get_secret_reponse.etag

      expect {
        n_secret = update_regional_secret_with_etag(
          project_id: project_id,
          location_id: location_id,
          secret_id:  secret_id,
          etag: updated_etag
        )

        expect(n_secret).wont_be_nil
        expect(n_secret.labels["secretmanager"]).must_equal("rocks")
      }.must_output(/Updated regional secret/)
    end
  end

  describe "#update_regional_secret" do
    it "updates the regional secret" do
      expect(secret).wont_be_nil

      expect {
        n_secret = update_regional_secret(
          project_id: project_id,
          location_id: location_id,
          secret_id:  secret_id
        )

        expect(n_secret).wont_be_nil
        expect(n_secret.labels["secretmanager"]).must_equal("rocks")
      }.must_output(/Updated regional secret/)
    end
  end

  describe "#update_regional_secret_with_alias" do
    it "updates the regional secret" do
      expect(secret).wont_be_nil
      expect(secret_version).wont_be_nil

      expect {
        n_secret = update_regional_secret_with_alias(
          project_id: project_id,
          location_id: location_id,
          secret_id:  secret_id
        )

        expect(n_secret).wont_be_nil
        expect(n_secret.version_aliases["test"]).must_equal(1)
      }.must_output(/Updated regional secret/)
    end
  end
end
