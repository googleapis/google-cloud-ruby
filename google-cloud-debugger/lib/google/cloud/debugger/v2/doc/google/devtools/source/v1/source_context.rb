# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Google
  module Devtools
    module Source
      module V1
        # A SourceContext is a reference to a tree of files. A SourceContext together
        # with a path point to a unique revision of a single file or directory.
        # @!attribute [rw] cloud_repo
        #   @return [Google::Devtools::Source::V1::CloudRepoSourceContext]
        #     A SourceContext referring to a revision in a cloud repo.
        # @!attribute [rw] cloud_workspace
        #   @return [Google::Devtools::Source::V1::CloudWorkspaceSourceContext]
        #     A SourceContext referring to a snapshot in a cloud workspace.
        # @!attribute [rw] gerrit
        #   @return [Google::Devtools::Source::V1::GerritSourceContext]
        #     A SourceContext referring to a Gerrit project.
        # @!attribute [rw] git
        #   @return [Google::Devtools::Source::V1::GitSourceContext]
        #     A SourceContext referring to any third party Git repo (e.g. GitHub).
        class SourceContext; end

        # An ExtendedSourceContext is a SourceContext combined with additional
        # details describing the context.
        # @!attribute [rw] context
        #   @return [Google::Devtools::Source::V1::SourceContext]
        #     Any source context.
        # @!attribute [rw] labels
        #   @return [Hash{String => String}]
        #     Labels with user defined metadata.
        class ExtendedSourceContext; end

        # An alias to a repo revision.
        # @!attribute [rw] kind
        #   @return [Google::Devtools::Source::V1::AliasContext::Kind]
        #     The alias kind.
        # @!attribute [rw] name
        #   @return [String]
        #     The alias name.
        class AliasContext
          # The type of an Alias.
          module Kind
            # Do not use.
            ANY = 0

            # Git tag
            FIXED = 1

            # Git branch
            MOVABLE = 2

            # OTHER is used to specify non-standard aliases, those not of the kinds
            # above. For example, if a Git repo has a ref named "refs/foo/bar", it
            # is considered to be of kind OTHER.
            OTHER = 4
          end
        end

        # A CloudRepoSourceContext denotes a particular revision in a cloud
        # repo (a repo hosted by the Google Cloud Platform).
        # @!attribute [rw] repo_id
        #   @return [Google::Devtools::Source::V1::RepoId]
        #     The ID of the repo.
        # @!attribute [rw] revision_id
        #   @return [String]
        #     A revision ID.
        # @!attribute [rw] alias_name
        #   @return [String]
        #     The name of an alias (branch, tag, etc.).
        # @!attribute [rw] alias_context
        #   @return [Google::Devtools::Source::V1::AliasContext]
        #     An alias, which may be a branch or tag.
        class CloudRepoSourceContext; end

        # A CloudWorkspaceSourceContext denotes a workspace at a particular snapshot.
        # @!attribute [rw] workspace_id
        #   @return [Google::Devtools::Source::V1::CloudWorkspaceId]
        #     The ID of the workspace.
        # @!attribute [rw] snapshot_id
        #   @return [String]
        #     The ID of the snapshot.
        #     An empty snapshot_id refers to the most recent snapshot.
        class CloudWorkspaceSourceContext; end

        # A SourceContext referring to a Gerrit project.
        # @!attribute [rw] host_uri
        #   @return [String]
        #     The URI of a running Gerrit instance.
        # @!attribute [rw] gerrit_project
        #   @return [String]
        #     The full project name within the host. Projects may be nested, so
        #     "project/subproject" is a valid project name.
        #     The "repo name" is hostURI/project.
        # @!attribute [rw] revision_id
        #   @return [String]
        #     A revision (commit) ID.
        # @!attribute [rw] alias_name
        #   @return [String]
        #     The name of an alias (branch, tag, etc.).
        # @!attribute [rw] alias_context
        #   @return [Google::Devtools::Source::V1::AliasContext]
        #     An alias, which may be a branch or tag.
        class GerritSourceContext; end

        # A GitSourceContext denotes a particular revision in a third party Git
        # repository (e.g. GitHub).
        # @!attribute [rw] url
        #   @return [String]
        #     Git repository URL.
        # @!attribute [rw] revision_id
        #   @return [String]
        #     Git commit hash.
        #     required.
        class GitSourceContext; end

        # A unique identifier for a cloud repo.
        # @!attribute [rw] project_repo_id
        #   @return [Google::Devtools::Source::V1::ProjectRepoId]
        #     A combination of a project ID and a repo name.
        # @!attribute [rw] uid
        #   @return [String]
        #     A server-assigned, globally unique identifier.
        class RepoId; end

        # Selects a repo using a Google Cloud Platform project ID
        # (e.g. winged-cargo-31) and a repo name within that project.
        # @!attribute [rw] project_id
        #   @return [String]
        #     The ID of the project.
        # @!attribute [rw] repo_name
        #   @return [String]
        #     The name of the repo. Leave empty for the default repo.
        class ProjectRepoId; end

        # A CloudWorkspaceId is a unique identifier for a cloud workspace.
        # A cloud workspace is a place associated with a repo where modified files
        # can be stored before they are committed.
        # @!attribute [rw] repo_id
        #   @return [Google::Devtools::Source::V1::RepoId]
        #     The ID of the repo containing the workspace.
        # @!attribute [rw] name
        #   @return [String]
        #     The unique name of the workspace within the repo.  This is the name
        #     chosen by the client in the Source API's CreateWorkspace method.
        class CloudWorkspaceId; end
      end
    end
  end
end